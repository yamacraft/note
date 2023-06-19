---
title: "Now in Android調査 #1 - 2つのapplicationモジュール"
date: 2023-06-19T12:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android", "nowinandroid"]
---

最近、Android公式のアプリアーキテクチャガイドを読み直していて、その流れで[Now in Android](https://github.com/android/nowinandroid)のプロジェクトの構成を調べています。
公式ドキュメントや公式のブログ記事、YouTubeのフィードを表示してくれるアプリで、プロジェクトはマルチモジュールで構成されています。
アプリアーキテクチャガイドでも、「モジュール化機能を備えた、完全に機能するAndroidアプリ」として取り上げられています。

![Now in Android](/note/image/research-now-in-android-1/research-now-in-android-1-1.png)

## appとapp-nia-catalog

Now in Androidプロジェクトにはapplicationモジュールが2つあります。
`app`は通常のアプリを生成するためのapplicationモジュールです。

一方で`app-nia-catalog`は、アプリ内で作成したコンポーネントの一部を閲覧するためのapplicationモジュールになります。

![NiA Catalog](/note/image/research-now-in-android-1/research-now-in-android-1-2.png)

`app-nia-catalog`自体は、UIに関係する部分（`core/designsystem`と`core/ui`）の2つしか参照していません。
そのためそれ以外のモジュールでどれだけ変更があっても、NiAカタログには影響を受けない作りになっています。
まさにマルチモジュールのメリットが活きています。

またこのカタログアプリ自体、これだけでデザイナーやディレクター陣にもUIのチェックができるし、通常のアプリとも完全に切り離せるので個人的には良いアイデアだと思いました。
マルチモジュール構成しているのであれば、積極的に取り入れたいところです。

## あとがき

とりあえずしばらくブログの更新が滞っていたので、いまやっていることを小出しに書きながら、また更新を再開できればと考えています。