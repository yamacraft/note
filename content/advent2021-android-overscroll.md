---
title: "Android 12におけるOverScroll表現の雑多なメモ"
date: 2021-12-14T00:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android"]
---

この記事は、 [QiitaのAndroid Advent Calendar 2021](https://qiita.com/advent-calendar/2021/android)の14日目の記事になります。

## Android 12のOverScroll

Android 12では、オーバースクロールの表現方法が変わりました。
いわゆる「伸びる（ストレッチ）」やつです。

Android 11 | Android 12
:--- | :---
![Android 11のオーバースクロール](/note/image/advent2021-android-overscroll/vertical_android11.gif) | ![Android 12のオーバースクロール](/note/image/advent2021-android-overscroll/vertical_android12.gif)

上記のGIFを見てもらえればわかるように、ストレッチ自体はAndroid 12の新たな機能ではありません。
過去にあったオーバースクロールの表現が変わったものになります。

## 縦以外にも伸びるOverScroll

公式の紹介などは、多くが縦のリストビューでストレッチする様子を紹介しています。
しかしこの表現は、既存のオーバースクロールで呼び出されるものです。
つまり横にも伸びます。

Android 11 | Android 12
:--- | :---
![Android 11のオーバースクロール（横）](/note/image/advent2021-android-overscroll/horizontal_android11.gif) | ![Android 12のオーバースクロール（横）](/note/image/advent2021-android-overscroll/horizontal_android12.gif)

また、過去にオーバースクロールの表現の対象外にあったものも、Android 12ではストレッチする場合もあるようです。
具体的にいうと、WebViewで確認しています。

Android 11 | Android 12
:--- | :---
![Android 11のオーバースクロール（WebView）](/note/image/advent2021-android-overscroll/webview_android11.gif) | ![Android 12のオーバースクロール（WebView）](/note/image/advent2021-android-overscroll/webview_android12.gif)

WebViewはAndroid11ではオーバースクロール時の表現がありませんでしたが、Android 12ではストレッチ効果が出ていました。

## 伸ばしたくない場合の対応方法と注意

オーバースクロールによって伸びることを防ぎたい場合は、オーバースクロール自体をとめる必要があります。
これは対象のViewの `overScrollMode` を `never` にすれば解決します。

``` xml
<ScrollView
  android:overScrollMode="never"
>
```

Android 11 | Android 12
:--- | :---
![OverScrollを排除した状態（Android 11）](/note/image/advent2021-android-overscroll/overscroll_never_android11.gif) | ![OverScrollを排除した状態（Android 12）](/note/image/advent2021-android-overscroll/overscroll_never_android12.gif)

当然ですが、Android 12ではストレッチすることがオーバースクロールの表現になっています。
ですので、これをとめたことで過去のオーバースクロールの表現が戻ってくる訳ではありません。
当然、Android 11以前でアプリを動かした場合でもオーバースクロールの表現が出てこなくなります。

## ストレッチの調整？について

この伸びる表現は、公式の解説によると `EdgeEffect` を使って実現しているようです。

つまりストレッチの効果を調整するには、各Viewの `EdgeEffect` を変更すればよいのですが、これを設定できるAPIはすべてのViewに用意されているわけではないようです。
具体的に言うと `RecyclerView` には `edgeEffectFactory` というプロパティでEdgeEffectを設定できます。
しかしScrollViewには同様のAPIが見当たりませんでした。

また、公式の解説には `EdgeEffect.onPull(deltaDistance, displacement)` にてストレッチの効果を調整できるという記述があります。
ですが、このAPI自体は31（Android 12）以降でないと呼び出すことはできません。

さらに公式の解説では「正の値と負の値」という解説がありますが、実際のドキュメントでは0〜1までの間で設定しないといけません。
`deltaDistance` は初回のストレッチ時の位置を変えることしかできませんし、 `displacement` の値は変えても正直違いがわかりません。

``` kotlin
binding.recyclerView.edgeEffectFactory = object : RecyclerView.EdgeEffectFactory() {
    override fun createEdgeEffect(view: RecyclerView, direction: Int): EdgeEffect {
        val edgeEffect = EdgeEffect(view.context)
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            edgeEffect.onPullDistance(1f, 0f)
        }
        return edgeEffect
    }
}
```

![OverScrollを排除した状態（Android 12）](/note/image/advent2021-android-overscroll/create_edgeeffect.gif)

`deltaDistance` を変えたことで、最初のストレッチ時に変化はありましたが、二度目以降のストレッチに変化がありませんでした。
さらに設定を変えることでカクついたような印象を持ちました。

私の設定方法に問題がありそうですが、現状EdgeEffectをいじるメリットはないような気がします。

## やりたかったができなかったこと

- `EdgeEffect` をいじればすごいストレッチする（逆に全然しない）Viewを見れるかと思ったが、できなかった
- どのスクロール可能なViewでもストレッチを調整できるかと思ったが、できなさそう
  - CustomViewにすれば対応できそうな気がするが、そこまで挑戦する気力が湧きませんでした

## 結論

オーバースクロールのストレッチ効果を甘んじて受け入れましょう。

## 参考

[オーバースクロール効果 \| Android 12 \| Android Developers](https://developer.android.google.cn/about/versions/12/overscroll)