---
title: "Firebase AuthenticationとAndroid推奨アーキテクチャと画面遷移"
date: 2021-11-12T21:00:00+09:00
draft: false
tags: ["tech", "homete", "android", "firebase"]
---

## この記事について

[Homete](https://homete.yamaglo.jp/)のユーザー認証には、Firebase Authenticationを使っています。
また、基本的な設計は公式が推奨しているアーキテクチャにのっとっています。

[アプリ アーキテクチャ ガイド  \|  Android デベロッパー  \|  Android Developers](https://developer.android.com/jetpack/guide)

この記事は、HometeでFirebase Authenticationをどう実装し、特にログイン状態での画面遷移をどう実装しているかを紹介している記事になります。

[内容について気になることなどがあれば、Twitterなどにご連絡ください。](https://twitter.com/yamacraft)

なお、Firebase Authenticationの基本的な概要や、推奨アーキテクチャの話はご存じの前提で書いています。

## FirebaseAuthの認証情報管理

Firebase Authenticationでは `FirebaseAuth` のインスタンスを取得するだけで、ユーザー認証の状態を簡単に取得できます。
ちなみにシングルトンで作られているので、呼び出すタイミングで値が異なるような事はありません。

``` kt
val auth = FirebaseAuth.getInstance()

// Firebase.CurrentUserからUIDや匿名ユーザーの有無などを確認できる
// currentUserがnullであれば、非ログイン状態
auth.currentUser?.uid
auth.currentUser?.isAnonymous
auth.currentUser?.email
```

またContextを必要としないので、ViewModelからでも問題なく利用できます。
FirebaseAuthの状態変化は `AuthStateListener` で通知されるので、これを利用すればLiveDataを使うなりして、ログイン状態の変化をViewに伝えることが可能です。

``` kt
val auth = FirebaseAuth.getInstance()
val userLiveData =  MutableLiveData<FirebaseUser>()

// ログインすればユーザー情報が入るし、ログアウトすればユーザー情報は消える
// MutableLiveData<FirebaseUser?> じゃないとログアウトでぬるぽするかも
auth.addAuthStateListener { 
    userLiveData.value = it.currentUser
}
```

普通に考えればユーザーの認証方法をリリース後に変えることはありません。
ですがユニットテスト時のmock化や、正しくアーキテクチャに合わせた設計で考えれば、Firebase Authenticationの処理はRepository内で完結させてしまいたいです。

Hometeの場合、この `AuthStateListener` を `callbackFlow` でFlowに変えたものを、ViewModelへ返すようにしています。
さらにユーザー情報も専用のdata classに置き換えることで、ViewModel側ではRepositoryが何を使ってユーザー認証しているかを意識する必要のない作りにしています。

```kt
// 例: User情報を格納するdata class
data class User(
    val uid: String,
    val mail: String,
    val isAnonymous: Boolean
)

// 例: Repositoryのユーザー情報取得メソッド
override fun syncAuthData(): Flow<User> {
    return callbackFlow {
        val listener = FirebaseAuth.AuthStateListener { firebaseAuth ->
            val user = User(
                uid = firebaseAuth.currentUser?.uid.orEmpty(),
                mail = firebaseAuth.currentUser?.email.orEmpty(),
                isAnonymous = firebaseAuth.currentUser?.isAnonymous ?: true
            )
            offer(user)
        }
        auth.addAuthStateListener(listener)

        awaitClose {
            auth.removeAuthStateListener(listener)
        }
    }
}
```

あとは、ViewModel側でこのFlowをcollectして、取得したUserクラスをLiveDataに投げるだけです。

```kt
authRepository.syncAuthData().collect { user ->
    _userLiveData.postValue(user)
}
```

これで該当のViewModelとつながったViewであれば、各画面でユーザーのログイン状態を監視できるようになりました。

StateFlowではなくLiveDataを使っているのに深い意味はありません。
実装においてStateFlowを使うメリットが勝っているのであれば、そちらを使ってください。

## ログイン状態の監視と画面遷移

監視できるようになったログイン状態ですが、View側でこの情報を使ってやることは、ログイン状態に合わせた画面遷移です。

HometeはSingleActivityではありません。
いくつかの機能に分けてActivityを作成することにしました。
すべてのActivityではログイン状態を取得する `AuthViewModel` を参照し、画面ごとに次の遷移を実装しています。

- スプラッシュ画面
  - ログインしていればメイン画面、そうでなければトップ画面へ遷移
- トップ（ログイン）画面
  - ログインすれば自身を閉じてメイン画面へ遷移
- メイン画面（投稿の閲覧や設定など）
  - ログアウトしたタイミングで自身を閉じて、メイン画面へ遷移
- 投稿画面
  - ログアウトしたタイミングで自身を閉じる


![Hometeの画面遷移図](/note/image/homete-architecture-firebase-auth/transition_map.png)

ログイン状態の監視で行う処理は `startActivity()` と `finish()` 程度のシンプルな実装しかしていません。
さらにActivityでは、こうしたログイン状態の監視程度の実装にとどめています。
各画面の機能は、Fragment側で実装します。

いくつかのActivityに分けたのは、この構成でないと制御できないから、という理由ではありません。
おそらくSingleActivityでも実装できるはずです。

逆に細かい機能もActivityごとに分けた場合は、そのぶんだけログイン状態の監視処理を入れる必要があるので大きな手間がかかります。
ですので、ある程度はActivityをまとめた設計にするのがよいでしょう。

## 締め

以上がHometeにおける、Firebase Authenticationを推奨アーキテクチャに落とし込んだ設計となります。

あまりこの手の実装例を目にしないので、これが正しい作りかと聞かれると自信がありません。
ほかにも公開してくれる人たちが増えるとうれしいですね。

## 余談

この記事はもともとスライド資料にして、LTとして動画に取ってYouTubeに公開する予定でした。
ですが、ちょっと資料作成等に手間がかかりすぎたので、先に文章として公開するに至りました。
そのうち動画版も上がる予定です。