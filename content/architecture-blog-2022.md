---
title: "yamacraftのブログを支えるシステム（2022年版）"
date: 2022-12-01T12:30:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "advent2022", "blog"]
---

- [山田航空ネットワーク3rd \| 山田航空ネットワーク3rd](https://yamacraft.github.io/note/)
- [山田航空ネットワークフロント](https://yamacraft.github.io/)
- [合同会社ヤマダ印](https://yamadajirushi.co.jp/)

このブログを含めた、yamacraftが管理しているWebサイトの構築内容などをまとめました。

## 利用しているシステム・アプリ

- [Hugo](https://gohugo.io/)
- GitHub Actions
- GitHub Pages / Firebase Hosting
- [textlint](https://textlint.github.io/) + VSCode

## 各システム・アプリの詳細

### Hugo

静的サイトジェネレータです。
Markdownでコンテンツ部分を作成できます。
静的サイトジェネレータはいくつか種類がありますが、利用者の数とバイナリファイルで動作する点から決めました。

文字通り静的ファイル一式で出力されるのでデプロイ先に困りませんし、サイトマップやRSS等もまとめて出力してくれるのも気に入っています。

当初、1ページしかないようなWebサイトは直接HTMLで書いていましたが、ほぼすべてHugoに置き換えました。

名前の通りHugoで作られてバイナリファイルが提供されているため、各OSで動いてNodeなどのビルド環境に影響しないのも個人的にうれしいポイントです。
一方でLinuxはHomebrew経由かGitHubのリリースから直接落とさないといけないというデメリットがあったはずでしたが、どうも[APT等にも対応するようになっていたみたいです](https://gohugo.io/installation/linux/)。

### GitHub Actions

ビルドからデプロイ作業までをCIで行うために利用しています。

Firebase HostingへデプロイするプロジェクトはCircle CIを使っていたこともありましたが、Circle CIはログイン周りのUIで不便なことがありました。
そういった経緯から、現在はGitHub Actionsへすべて移行しました。

サンプルとしては以下の感じです。
やっていることは何も難しいことはなく、ビルドとデプロイを行いビルド結果はArtifactsで残して結果はSlackで通知しています。

[note/deploy\.yml at master · yamacraft/note](https://github.com/yamacraft/note/blob/master/.github/workflows/deploy.yml)

blogの方は予約投稿をある程度対応できるように、毎日0時（ただしくは0時5分以降）に実行するスケジュールを追加しています。
ただ現状は何も変更がなくてもデプロイしてしまっているので、これは今後、ビルド結果の差分を見て必要があればデプロイをするという形に修正していく予定です。

とりあえず現状ではデプロイまでやっても1分かからないので良しとしています。

https://github.com/yamacraft/note/actions/workflows/deploy.yml

### GitHub Pages / Firebase Hosting

デプロイ先に利用しています。
Firebase Hostingはすべて無料プランを使っています。
無料プランの制限を超えることはおそらく一生ないので何も問題はありません。

### textlint + VSCode

ブログ等の記述はVSCodeを使っています。
せっかくなのでtextlintとvscode-textlintを使って書いています。
用語のルールファイルは[techboosterで公開していたWEB+DB PRESSのルールファイル](https://github.com/TechBooster/ReVIEW-Template/blob/master/prh-rules/media/WEB%2BDB_PRESS.yml)を利用しています。

## 2023年に向けてやっておきたいこと

- [職務経歴書のプロジェクト](https://github.com/yamacraft/cv)がGitHub Actions移行していないことに気付いたので、対応する
  - ついでにGitHub Pagesへ移行してURLを `https://yamacraft.github.io/cv` あたりに変える
- ブログの毎日ビルドはビルド結果を見てデプロイする／しないの判断をさせる
