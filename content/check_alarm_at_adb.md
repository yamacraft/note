---
title: "adbでAlarmManagerの登録内容を確認する"
date: 2022-08-11T22:30:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android", "adb"]
---

Androidアプリにおいてアプリ自身で特定の時間に何かしらの処理（以下、アラーム処理）を行いたい場合は、`AlarmManager`を使う方法が考えられます。
さらに`setInexactRepeating()`を使うことで、（タイミングに制限がありますが）一定間隔でアラーム処理を行うことが可能です。

この処理の実装方法自体は公式のドキュメントを参照してください。

[反復アラームのスケジュール設定  \|  Android デベロッパー  \|  Android Developers](https://developer.android.com/training/scheduling/alarms?hl=ja)

で、実際にAlarmManagerを設定しても、それが正しく設定されたかどうかを確認するためのAPIは用意されていません。
そのため、登録の確認方法は実際に動くところを見るか、adbのdumpsysを使う方法があります。
今回はadbを使った方法を紹介します。

なお、調べてみるとadbのバージョンによって表記に違いがあるっぽいです。
この記事では33.0.2で確認しています。

```sh
$ adb version
Android Debug Bridge version 1.0.41
Version 33.0.2-8557947
```

adbで確認する方法は `adb shell dumpsys alarm` を使います。
ただこれだけでは無関係なalarmの設定まで出てきてしまうので、対象のアプリのpackage名でgrepをかけた方がよいです。

``` sh
$ adb shell dumpsys alarm | grep io.github.yamacraft.app.sample
    RTC #10: Alarm{5df5b50 type 1 origWhen 1660210860000 whenElapsed 14518909 io.github.yamacraft.app.sample}
      tag=*alarm*:io.github.yamacraft.app.sample/.ui.NotificationReceiver
      operation=PendingIntent{dcc7149: PendingIntentRecord{e7c097b io.github.yamacraft.app.sample broadcastIntent}}
    io.github.yamacraft.app.sample, u0: -4m18s426ms, 
  u0a147:io.github.yamacraft.app.sample +93ms running, 0 wakeups:
      *alarm*:io.github.yamacraft.app.sample/.ui.NotificationReceiver
```

今回のサンプルはRTCで設定していたので、`RTC #XX: Alarm{}`という設定が表示されています。
つまり対象となるアプリのパッケージ名でのAlarm登録が出てきたので、登録自体は無事できたことが確認できました。

15分おきにアラーム処理を呼び出した場合の、それぞれのdumpsysの結果も記載します。

```sh
$ adb shell dumpsys alarm | grep io.github.yamacraft.app.sample
    RTC #10: Alarm{5df5b50 type 1 origWhen 1660210860000 whenElapsed 14518909 io.github.yamacraft.app.sample}
      tag=*alarm*:io.github.yamacraft.app.sample/.ui.NotificationReceiver
      operation=PendingIntent{dcc7149: PendingIntentRecord{e7c097b io.github.yamacraft.app.sample broadcastIntent}}
    io.github.yamacraft.app.sample, u0: -4m18s426ms, 
  u0a147:io.github.yamacraft.app.sample +93ms running, 0 wakeups:
      *alarm*:io.github.yamacraft.app.sample/.ui.NotificationReceiver

$ adb shell dumpsys alarm | grep io.github.yamacraft.app.sample
    RTC #3: Alarm{1c5475f type 1 origWhen 1660211760000 whenElapsed 15418909 io.github.yamacraft.app.sample}
      tag=*alarm*:io.github.yamacraft.app.sample/.ui.NotificationReceiver
      operation=PendingIntent{dcc7149: PendingIntentRecord{e7c097b io.github.yamacraft.app.sample broadcastIntent}}
    io.github.yamacraft.app.sample, u0: -14m46s57ms, -29m20s476ms, 
  u0a147:io.github.yamacraft.app.sample +153ms running, 0 wakeups:
      *alarm*:io.github.yamacraft.app.sample/.ui.NotificationReceiver

$ adb shell dumpsys alarm | grep io.github.yamacraft.app.sample
    RTC #8: Alarm{a951a2c type 1 origWhen 1660212660000 whenElapsed 16318909 io.github.yamacraft.app.sample}
      tag=*alarm*:io.github.yamacraft.app.sample/.ui.NotificationReceiver
      operation=PendingIntent{dcc7149: PendingIntentRecord{e7c097b io.github.yamacraft.app.sample broadcastIntent}}
    io.github.yamacraft.app.sample, u0: -6m19s496ms, -21m13s180ms, -35m47s599ms, 
  u0a147:io.github.yamacraft.app.sample +197ms running, 0 wakeups:
      *alarm*:io.github.yamacraft.app.sample/.ui.NotificationReceiver
```

これを見る限り、`origWhen`には次のAlarmが呼び出される時刻をUNIXタイムスタンプで表記しているようです。

一方で同じように何か時間を示しているような`whenElapsed`の値はいまいちよくわかりません…。
名前だけ見れば経過時間を意味するように見えますし、実際にそれぞれの`whenElapsed`の値を引くと900000ミリ秒（=15分）になります。
ただ初回設定時の値が、現在時刻と実行時刻の差分にしては異様に大きな値が設定されています。

とりあえず`origWhen`だけ見ていれば大丈夫そうですので、`whenElapsed`のことは忘れることにします。

以上、自分用のメモでした。