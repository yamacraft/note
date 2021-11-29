---
title: "HometeのtargetSdkVersionを31に上げています"
date: 2021-11-29T18:30:00+09:00
draft: false
tags: ["work", "homete", "android"]
---

Android 12が正式リリースされ、自分の手元にもPixel6 Proが届いたこともあり、HometeのtargetSdkVersionを31に上げる作業をしています。

といっても作業自体はすでに完了し、現在は内部テストで簡単な動作チェック中です。
遅くとも来週の月曜日にはアップデートを行う予定です。

以下、31に上げる際の備忘録です。

## buildToolsVersion について

buildToolsVersionは現在 `31.0.0` がリリースされていますが、どうもバグがあるようで、これを導入するとビルドが失敗します。
自分の場合は `Could not create task ':app:minifyReleaseWithR8'.` というエラーが発生しました。
ですがstackoverflowなどを調べてみると、プロジェクトによってエラーが異なる場合もあるみたいです。

公式のリリースノートでも `30.0.2` が最新版扱いされているみたいですので、buildToolsVersionの31へのアップデートはしばらくやめたほうがよさそうです。

https://developer.android.com/studio/releases/build-tools

## AGP 7.0とHilt

HometeではまだAGPが4（4.1.3）だったので、今回を機に7（7.0.3）へアップデートしました。
Hiltが2.38を使っている場合は、AGP 7+に対応した2.38.1以上へアップデートする必要があります。

https://github.com/google/dagger/releases/tag/dagger-2.38.1

## Kotlin stdlibの削除

Kotlin 1.4からstdlib（`org.jetbrains.kotlin:kotlin-stdlib `）が不要になっていたのですが、そのまま残していたのでこの機会に削除しました。

https://kotlinlang.org/docs/whatsnew14.html#module-info-descriptors-for-stdlib-artifacts

以上です。