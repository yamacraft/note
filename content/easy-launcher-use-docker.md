---
title: "easylauncherをdocker上でも使えるようにする"
date: 2020-06-01T13:00:00+09:00
draft: false
tags: ["tech", "Android", "Docker", "CI", "easylauncher"]
---

ただの覚書です。

自分が開発しているAndroidアプリのプロダクトには、アプリのバリアントを可視化しやすいようにeasylauncherを導入しています。

[akaita/easylauncher\-gradle\-plugin: Add a different ribbon to each of your Android app variants using this gradle plugin\. Of course, configure it as you will](https://github.com/akaita/easylauncher-gradle-plugin)

![easylauncherを利用したアイコン（debug版）](/note/image/easy-launcher-use-docker/001.png)

easylauncherはビルド環境にインストールされているフォントを使ってリボンを作ります。
そのため、たとえばDocker上で行うとフォントが見つからず、`NullPointerException`でビルドが失敗してしまいます。

そのため、Docker上で実行する際はあらかじめ生成に使えるフォントをインストールしておく必要があります。

[Build failed on the latest gradle plugin, getFont suddenly caused NPE · Issue \#37 · akaita/easylauncher\-gradle\-plugin](https://github.com/akaita/easylauncher-gradle-plugin/issues/37)

issue先では`ttf-dejavu`というフォントが指定されていますが、`fonts-ipafont`でも問題ありませんし、英数字しか使わないのであればほかの軽量なフォントを指定するのもよいです。

下記は、CircleCIのconfigファイルに記載する場合の例です。

```yml
steps:
    - run:
        name: add fontconfig for easylauncher
        command: sudo apt-get update && sudo apt-get install -y fontconfig fonts-ipafont
```


