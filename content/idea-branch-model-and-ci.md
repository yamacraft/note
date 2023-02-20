---
title: "個人（小規模）アプリ開発のブランチモデルとCI利用方法のアイデア"
date: 2022-05-16T17:30:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "poem", "ci", "Android", "Firebase"]
---

長いこと個人アカウントで管理していたヤマグロの各種プロジェクトを、ヤマグロのGitHub Organizationにまとめる作業を始めました。

ついでに使っているCIがCircle CIだったりGitHub Actionsだったりと統一感がなかったのでGitHub Actionに一元化、CIでやる内容の改修も行っています。

そしてその改修内容について、頭の中で考えている指針を後からメモとして使えるように、文書化してアウトプットしたものがこの記事です。

## ブランチモデルについて

[Gitflow ワークフロー \| Atlassian Git Tutorial](https://www.atlassian.com/ja/git/tutorials/comparing-workflows/gitflow-workflow)

<!-- textlint-disable prh -->
自分の場合、アプリ開発は基本的にgit-flowモデルを採用しています。
<!-- textlint-enable prh -->

* コードを更新するたびにアプリをリリースできない（したくない）ので、developとmasterでブランチを分けたい
* リリースチェックが日を跨ぐ可能性があるので、Push中のブランチから状況を把握できるようにしたい
* masterブランチはリリース時のコミットだけに絞ることで、後からリリースごとの変更点を追いやすくしたい

だいたいこうした理由です。
３つ目に関してはreleaseタグの管理がしっかりできていれば考える必要はなさそうですが、自分（人間）の行動を信じていないので、後からカバーしやすくなることも念頭に入れています。

ただ、このブランチモデルをそのままやると、releaseブランチからmasterブランチとdevelopブランチへそれぞれPull Requestを作ることになります。
それだとGitHubの場合、ずっとmasterブランチからdevelopブランチ（または逆）にPull Requestの提案が出て気になります。
という理由から、自分の場合はreleaseブランチからはmasterブランチのみPull Requestを行います。
その後masterブランチからdevelopブランチにPull Requestを行う形をとるようにしています。

## CIの利用方法について

* Pull Requestの作成・更新時に各種テストの実行
* release→masterへのPull Requestの場合、リリース版のAPKをApp Distributionへアップロードする
* masterブランチが更新（push）された時、tagの作成とリリース版のaabをartifactにアップロードする

個人レベルで開発している場合、結局動作チェックする人が自分しかいないので、開発版をApp Distributionへ頻繁に飛ばす必要がないのでCIの動作からは省きます。
どうしても複数の実機で動作確認したいケースがあれば、ローカルでApp Distributionへアップロードすればよいという判断です。

masterブランチの更新でGoogle Playにaabをそのままアップロードしないのは、自分でアップロードするタイミングを調整したいからです。
とはいえ、そのうち[gradle-play-publisher](https://github.com/Triple-T/gradle-play-publisher)を使ってもよいかなとは考えています。

そんな感じで作業を月曜日と平日夜の空いた時間に進めています。
できれば今月には終わらせたい。

以上です。