---
title: "Simple Mobile Toolsが売却されたので、Fossifyに移行した"
date: 2024-03-09T14:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["diary"]
tags: ["android", "oss"]
---

オープンソースで開発が進められていたSimple Mobile Toolsが、ZipoApps社へ売却されることが去年の12月に判明しました。
これはプロジェクトを立ち上げたtibbi氏が認めています。

[Simple Mobile Tools bought by ZipoApps? · Issue \#241 · SimpleMobileTools/General\-Discussion](https://github.com/SimpleMobileTools/General-Discussion/issues/241)

この件は現在の主要開発者の一人であるnaveensingh氏がこの話について聞かされていないなど、個人的になんだかきな臭い感じの売却となっています。
さらにZipoAppsによって買収されたアプリが、その後悲惨な改修を施されているという情報も載せられています。
また、今後このプロジェクトがオープンソースでなくなる可能性を、tibbi氏が回答しています。

こうしたこともあり、naveensingh氏によってSimple Mobile Toolからフォークされた、[Fossifyプロジェクトが立ち上がりました](https://github.com/FossifyOrg)。
アプリは一部がF-DroidとGoogle Playによって配布されています。
Google Playの方は審査などでリリースできていないアプリもあるようですので、F-Droid版経由で取得するのがよさそうです。

- [F\-Droid Search: Fossify](https://search.f-droid.org/?q=+Fossify&lang=ja)
- [Google Play での Fossify の Android アプリ](https://play.google.com/store/apps/dev?id=7297838378654322558)

また2024年3月現在の話ですが、Simple Mobile ToolsすべてのアプリがF-Droidで配信されていないようです。
とはいえ、各リポジトリはすべて移行されています。
このブログを普段見ている人の9割ぐらいはITエンジニアの人だと認識していますので、ストアになくてほしいアプリがあれば、各自でコードからビルドすればよいでしょう。

今回の売却についてはいろいろと感じることがありますが、とりあえず共有がてら記事を書きました。
以上です。