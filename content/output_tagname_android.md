---
title: "GitHub Actionsでtagをpushするための下準備と実行"
date: 2022-05-25T19:30:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android", "git", "GitHub Actions", "ci"]
---

[個人（小規模）アプリ開発のブランチモデルとCI利用方法のアイデア](/note/idea-branch-model-and-ci/)の続きみたいな記事です。

masterブランチが更新されたタイミングで、tagの作成とtag pushをCI上でやろうとしていました。
この作業自体は、Gitコマンドを２つたたくだけで実装できます。

``` sh
git tag $TAG_NAME
git push origin $TAG_NAME
```

問題は、tag名をどうやって生成するかです。

自分のプロジェクトで開発しているアプリは、gradle内の変数でversionNameとversionCodeを生成するようにしているので、tag名もここから作るようにします。

具体的に書くと、まずはtag名をファイルにアウトプットするtaskをgradleに追加します。

``` gradle
// この３つの変数からversionNameとversionCodeを生成している
def versionMajor = 1
def versionMinor = 0
def versionPatch = 0

// 中略

task outputTagName() {
    doLast {
        def tagName = "v${versionMajor}.${versionMinor}.${versionPatch}"
        file('../TAG_NAME').write(tagName, 'UTF-8')
    }
}
```

あとはGitHub Actionsでこのtaskを実行しつつ、出力されたファイルの中身を使ってtagを作ってpushするだけです。

``` yml
name: create_release_aab

on:
  workflow_dispatch:
  push:
    branches:
      - master
jobs:
  build_release_and_create_tag:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0

# 中略

- name: create tag
        run: |
          ./gradlew --stacktrace outputTagName
          git tag $(cat TAG_NAME)
          git push origin $(cat TAG_NAME)
```

もともとはAABファイルの作成も兼ねたjobだったので、bundletoolを使ってAABファイルからversionNameを取り出してtag名に使う方法も浮かびました。
ただbundletoolのインストールの手間等も考えると、自分のプロジェクトはこれが一番シンプルでわかりやすいと判断しました。

以上です。

## 参考

[GitHub Actionsでgit tagを自動生成 \- ohbarye](https://scrapbox.io/ohbarye/GitHub_Actions%E3%81%A7git_tag%E3%82%92%E8%87%AA%E5%8B%95%E7%94%9F%E6%88%90)