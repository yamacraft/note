---
title: "Activityの再起動にはrecreate()がある"
date: 2025-10-30T18:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android"]
---

## Activityには再生成用のrecreate()がある

AndroidでActivityを再起動したいとき、どのような実装が考えられるでしょうか。

```kotlin
finish()
startActivity(intent)
```

これが浮かぶ人がわりと多いんじゃないでしょうか。
なんなら検索してもこういうコードばかりでてくるし、自分の過去の経験でもこのコードばかり見ます。
そういう自分も長いこと、これしかないと思っていました。

実は `Activity.recreate()` というActivity再生成用のメソッドが用意されています。
しかもAPI 11（Android 3.0！）の頃に追加済み。

https://developer.android.com/reference/android/app/Activity#recreate()

> Cause this Activity to be recreated with a new instance. This results in essentially the same flow as when the Activity is created due to a configuration change -- the current instance will go through its lifecycle to onDestroy() and a new instance then created after it.

ということで、ちゃんとonDestroy()を経由して、新しいインスタンスでActivityを作成するよという説明が書かれています。

ちなみにテスト用の `ActivityScenario.recreate()` も存在します。

https://developer.android.com/reference/androidx/test/core/app/ActivityScenario

お恥ずかしながら、最近までこのメソッドの存在を知りませんでした。

## recreate()の中身

ではrecreate()の中身はどのように実装されているのでしょうか。
とりあえずサクッと該当のコードだけ引用します。

https://cs.android.com/android/platform/superproject/main/+/main:frameworks/base/core/java/android/app/Activity.java;l=7298

```java
/**
 * Cause this Activity to be recreated with a new instance.  This results
 * in essentially the same flow as when the Activity is created due to
 * a configuration change -- the current instance will go through its
 * lifecycle to {@link #onDestroy} and a new instance then created after it.
 */
public void recreate() {
    if (mParent != null) {
        throw new IllegalStateException("Can only be called on top-level activity");
    }
    if (Looper.myLooper() != mMainThread.getLooper()) {
        throw new IllegalStateException("Must be called from main thread");
    }
    mMainThread.scheduleRelaunchActivity(mToken);
}
```

https://cs.android.com/android/platform/superproject/main/+/main:frameworks/base/core/java/android/app/ActivityThread.java;drc=b4d6320e2ae398b36f0aaafb2ecd83609d2d99af;l=6200

```java
void scheduleRelaunchActivity(IBinder token) {
    final ActivityClientRecord r = mActivities.get(token);
    if (r != null) {
        Log.i(TAG, "Schedule relaunch activity: " + r.activityInfo.name);
        scheduleRelaunchActivityIfPossible(r, !r.stopped /* preserveWindow */);
    }
}
```

内部の動作をより詳細に見てはいませんが、処理の内容と関数名から、OS内のスケジュール処理に再起動の実行を登録しているようです。
つまり、単純に自身をfinishしてstartActivityしているわけではないことがわかります。

## ライフサイクルの動きに注意

ということで、じゃあ現在再起動している処理を全部recreateに置き換えようかと考えている人たちに注意点だけ記載します。
実はfinish〜startActivityで再起動しているものは、（IntentのFlagやタイミング次第ですが）Activityが閉じきる前に新しいActivityが生成されています。

以下、各ライフサイクルの先頭にログを吐き出した状態での再起動ログ。

```kotlin
Log.d("MainActivity", "action_restart")
finish()
startActivity(intent)
```

```log
action_restart
MainFragment.onPause
MainActivity.onPause
MainActivity.onCreate  <-- 次のActivityが生まれている
MainFragment.onCreate
MainFragment.onCreateView
MainFragment.onCreate
MainActivity.onStart
MainActivity.onResume
MainFragment.onResume
MainFragment.onStop
MainActivity.onStop
MainFragment.onDestroyView
MainFragment.onDestroy
MainActivity.onDestroy
```

recreateの場合は、ちゃんとonDestroyまで処理が完了してから新しいActivityが立ち上がります。

```kotlin
Log.d("MainActivity", "action_recreate")
recreate()
```

```log
action_recreate
MainFragment.onPause
MainActivity.onPause
MainFragment.onStop
MainActivity.onStop
MainFragment.onDestroyView
MainFragment.onDestroy
MainActivity.onDestroy
MainActivity.onCreate  <-- 前のActivityが閉じてから立ち上がっている
MainFragment.onCreate
MainFragment.onCreateView
MainFragment.onCreate
MainActivity.onStart
MainActivity.onResume
MainFragment.onResume
```

このライフサイクルの違いが、動作に影響する可能性があります。
気をつけて置き換えを行いましょう。

こう書くとrecreateでの再起動が特殊なように見えますが、要は画面回転等の再生成と同じ動きが起きているだけです。
こうした点からも、Activityを正しく再起動させたい場合はrecreateを使うのが良さそうです。

## さいごに

Activityを再起動させたい時は、 `recreate()` を使いましょう。