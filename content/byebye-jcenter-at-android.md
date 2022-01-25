---
title: "JCenter、Bintray終了に伴うヤマグロ提供のAndroidアプリの対応状況"
date: 2021-02-08T15:00:00+09:00
draft: false
categories: ["tech"]
tags: ["tech", "work", "yamadajirushi", "android"]
---

JFrogから、JCenterやBintrayを含めたサービスの閉鎖が5/1に行われることが発表されました。

[Service End for Bintray, JCenter, GoCenter, and ChartCenter \| JFrog](https://jfrog.com/blog/into-the-sunset-bintray-jcenter-gocenter-and-chartcenter/)

余談ですが、この記事の見出しには「Into the Sunset on May 1st」と書かれています。
個人的にこういう重大なニュースに関しては、Sunsetなんてお洒落な表現はやらずに、ちゃんとCloseって書くべきだろう派です。

話を戻して、閉鎖までの期間がたいへんに短いこともあり、本日は急遽提供しているAndroidアプリのjcenter脱却対応（主に調査周り）を行いました。
結論を先に書くと、必要なライブラリはすでにMavenCentralから取得できることが確認できたので、特に大きな対応は行っておりません。
ただし、Android Gradle Pluginは一部Bintrayに依存している部分があるため、現時点で完全な脱却の対応はできません。

これに関しては、すでに記事にまとめている方がいらっしゃるので、リンクだけ張っておきます。

<!-- textlint-disable -->
[JCenter が2021年5月1日にシャットダウンすることになったので Android アプリエンジニア観点でメモをまとめた \- BattleProgrammerShibata](https://bps-tomoya.hateblo.jp/entry/2021/02/04/184317)
<!-- textlint-enable -->

## 簡単な確認方法

とりあえずgradleファイルの `repositories` にある `jcenter()` をコメントアウトします。
そしてjCenterの代わりに `mavenCentral()` を入れてビルドと動作ができるかチェックするのが一番簡単です。

``` gradle
buildscript {
    repositories {
        google()
        // TODO: Android Gradle Pluginがまだ対応していない
        //jcenter()
        mavenCentral()
    }
}

allprojects {
    repositories {
        google()
        //jcenter()
        mavenCentral()
    }
}
```

あとはビルドエラーになったライブラリの提供元（リポジトリなど）を確認して、対応の予定があるか、すでに対応されているかをチェックすればおしまいです。

## 利用しているサードパーティライブラリについて

基本的にGoogleやKotlin公式が提供しているライブラリの大半は、ほぼGoogleリポジトリかMavenCentralに上がっているので気にしなくてよさそうです。

なのでサードパーティライブラリだけ気にすれば良さそうですが、現在提供しているアプリで使っているライブラリは次のものしかありませんでした。

* [JakeWharton/timber: A logger with a small, extensible API which provides utility on top of Android's normal Log class\.](https://github.com/JakeWharton/timber)
* [akaita/easylauncher\-gradle\-plugin: Add a different ribbon to each of your Android app variants using this gradle plugin\. Of course, configure it as you will](https://github.com/akaita/easylauncher-gradle-plugin)

Timberは、[最初からSonatype（MavenCentral）にアップロードされていました](https://github.com/JakeWharton/timber/blob/master/gradle/gradle-mvn-push.gradle#L42)。
どうやらJCenter経由で取得できていたのが、そもそもよくなかったようです。

一方でeasylauncherは、[Bintrayにのみリリースしている](https://github.com/akaita/easylauncher-gradle-plugin/blob/master/plugin/build.gradle#L30)ため、JCenterを削除すると使えなくなります。
また、リポジトリのissueやPRの状況を見る限り、メンテナンスは数年レベルで止まっています。
ただこれに関しては、すでに提供しているアプリがどちらもAdaptiveIcon対応していることもあって、easylauncherがないと困ることはほぼなくなっています。
ですので、こちらに関してはライブラリそのものの脱却という対応を予定しています。
どちらにしろ、リリースするアプリへの影響がないため、それほど急ぐ必要はありませんでした。

ということで、こうして情報共有の記事をアップロードして、一時対応完了です。

以上。