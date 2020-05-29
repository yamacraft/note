---
title: "ブログのデプロイをGitHub Actionsで行うようにした"
date: 2020-05-29T18:30:00+09:00
draft: false
tags: ["tech", "CI", "GitHub Actions"]
---

このブログはHugoとGitHub Pagesを使って公開しています。

これまでは手動で `hugo` コマンドを叩いてサイトを生成し、それもリポジトリに加えてpushするやり方で更新していました。

さすがにそれだと面倒な手順がひとつ増えるし、抜け漏れが発生しやすいという懸念もあり、GitHub Actionsで自動化することにしました。

ちなみに、これが初GitHub Actionsです。

## GitHub Actionsの設定ファイル

```yml
name: Build and Deploy

on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-18.04
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: true
          fetch-depth: 0

      - name: Setup Hugo
        uses: peaceiris/actions-hugo@v2
        with:
          hugo-version: "0.70.0"

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

動作内容としては、以下のとおりです。

1. コードのチェックアウト
2. Hugoが使える環境の準備
3. `hugo` を実行してサイト生成
4. 生成したサイトのデータのみを `gh-pages` ブランチにpush
5. 生成したサイトのデータをActionsのartifactで保存
6. Slackに完了の通知

全体の動作時間は30秒〜1分で、hugoの環境の生成等も考えると、CIツールの中ではかなり高速な印象があります。

今回はガッツリとMarketplaceで公開されているものを使いましたが、 `hugo --minify` の部分でも分かるように、 `run` でコマンドが実行できます。
ですので、ほかのCIツールからの機能も（元の方にある機能へ激しく依存していなければ）比較的簡単に移植できるんじゃないかと思いました。

## 備考と締め

今回初めてGitHub Actionsを使うにあたってドキュメントを読んで知りましたが、無料プランでもmacOSでの実行が可能なんですね。
さすがMSがバックにいるだけあって、気前が非常に良いなと思いました。

[GitHub Actionsについて \- GitHub ヘルプ](https://help.github.com/ja/actions/getting-started-with-github-actions/about-github-actions#usage-limits)

これまでCircle CIを積極的に採用していましたが、GitHubで管理しているものはGitHub Actionsを優先的に使うのもありかなと感じました。

ただ、今回のようにあまりMarketplace任せで作っていると、いざ何か起きたときに修正や移行ができなくなるという懸念点もあります。

すべて自作しろというわけではありませんが、それぞれのstepがどう動いているかの理解をしておくのが、GitHub Actionsに限らずCIと長く付き合っていくコツではないかと思っています。