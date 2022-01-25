---
title: "山田航空ネットワーク3rdを支える技術"
date: 2021-12-06T18:30:00+09:00
draft: false
categories: ["tech"]
tags: ["tech", "blog", "hugo", "github"]
---

今月中に、現在使っているブログのしくみについての振り返り記事を書こうと考えています。
その補足として、現在のブログはどういうしくみで運用しているのかを、あらためてまとめることにしました。

- [ブログを移転した | 山田航空ネットワーク3rd](/note/start-blog-3rd/)
- [ブログのデプロイをGitHub Actionsで行うようにした | 山田航空ネットワーク3rd](/note/blog-generate-by-github-actions/)

これらの記事をまとめたような内容になります。

## 自分がブログに求めているもの

- Markdown形式でブログを書きたい
- デザインを気軽に改修できるよう、本文に不要なHTMLタグが混ざってほしくない
- まだブログを書くモチベーションがあるうちに、管理サイト自体が閉鎖されるのは困る

基本はこの３点です。
３点目の時点で、どこかのブログサービスを利用できない（したくない）と考えていたので、最終的に[Hugo](https://gohugo.io/)＋GitHub Pagesで運用する決断に至りました。

## 現在のブログシステムの構築

[Hugo](https://gohugo.io/)は、マークダウンファイルでコンテンツを作成できるサイトジェネレータです。
出力するサイトも公式やサードパーティが用意してくれたテーマを適用することで簡単にデザインを変えることができ、このブログでは[Mediumish](https://github.com/lgaida/mediumish-gohugo-theme)というテーマを使っています。

ただ、このテーマをそのまま使っているわけではなく、次のブログを参考に不要な部分を削除したり改修したりしています。

[HugoのテーマをMediumishにした \| Ken's blog @teaplanet](https://blog.teapla.net/2018/11/changed-the-theme-to-mediumish/)

基本的な執筆の流れは次のような形で行っています。

1. 新規記事の作成は、都度masterブランチから作業ブランチを切って執筆する
2. 書き終わったところでPull Requestを作成＋そのままPR上でマージを行う
3. masterブランチ更新のタイミングでGitHub Actionsが働き、GitHub Pageでアップロードが行われる
4. アップロードが完了したところで、Slackへ通知する

こちらが、現在使っているGitHub Actionsのymlになります。

```yml
name: Build and Deploy

on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-20.04
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: true
          fetch-depth: 0

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: 'latest'

      - name: Build
        run: hugo --minify

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
          publish_branch: gh-pages

      - name: Upload Archive
        uses: actions/upload-artifact@v1
        with:
          name: gh-pages
          path: public

      - name: Notify Slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          author_name: yamacraft-note deploy
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        if: always()
```

`peaceiris/actions-gh-pages@v3` は、Hugoで生成したサイトを `publish_branch` で指定したブランチへそのままpushするしくみになっています。
あとはGitHub Pagesで、指定したブランチ（今回は`gh-pages`）をGitHub Pagesで利用するブランチして指定すれば、後は何もせず設定した内容で公開してくれます。

念のため、生成したサイトはArtifactにもアップロードするようにしています。
これ自体が、そのままブログのバックアップファイルとして利用できます。

Secrets情報に関しては、 `SLACK_WEBHOOK_URL` しか設定していません。

以上です。
