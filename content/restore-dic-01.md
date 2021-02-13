---
title: "D.I.C. レストア記録 #1 - 開発環境を整える"
date: 2020-10-12T15:00:00+09:00
draft: false
tags: ["tech", "work", "app_restore", "dic_restore", "android"]
---

## D.I.C.レストア記録記事一覧

- [#0 - レストアの方針](/note/restore-dic-00/)
- [#1 - 開発環境を整える](/note/restore-dic-01/)
- [#2 - コードをkotlinに置き換える](/note/restore-dic-02/)
- [#3 - マテリアルデザインとダークテーマへの対応](/note/restore-dic-03/)

## 開発環境を整えるということについて

メンテナンスが長期に渡って放置されていたプロダクトの改修は、コードを一部修正しては動作確認といった作業をこまめに繰り返しがちです。
早々にコーディング以外の作業は、自動化なり、せめてコンソールでコマンドを実行するだけで完結できるようにしてしまいます。

## 開発環境を整える前にすること

これは前回の記事で書くべきことでしたが、改修を始める前にぜひやっておきたいことがあります。

### そもそもリリース版に使っていた証明書（keystore）が残っていることを確認する

これは本当にありえる話ですが（実際に1回遭遇したことがある）、リリース版に使っていた証明書ファイルが失われてしまっている可能性があります。
実際失ってしまうと、既存のアプリをアップデートする形で配信できなくなります。
こうなってしまうとapplicationIdを変えて、新規アプリとして配信することになります。

できれば既存のアプリからのアップデートの方が引き続き残ったユーザーに届きやすいので、見当たらない場合は本当に失われてしまったか必死で探しましょう。
それでも見つからなければ諦めます。

### 改修前のアプリにAnalyticsもしくはCrashlyticsを導入しておく

もし改修前のアプリにAnalyticsやCrashlyticsがなかった場合は、改修前に簡単な導入でもよいので、導入したバージョンを配信することをお勧めします。
前者は主に残っているユーザーの属性（OSや端末の種類）の把握に使い、後者は改修後の動作確認として見るべき部分のリストアップの参考にするためです。

## D.I.C.でやったこと

* buildTypes.debugを追加して、リリース版とデバッグ版を1つの端末で共存できるようにした
* easylauncher（サードパーティ製）を導入して、デバッグ版とリリース版のアイコンを可視化
* Firebase App Distributionを導入
* Circle CIを導入し、各ブランチのpush時にデバッグ版をFirebase App Distributionで自動配布するようにした

## 解説

### 開発環境で整えること

Androidアプリのレストアというのは、予定外の修正が発生しがちです。
また、ちょっとした修正でも想定外の部分に影響がでることも多いので、頻繁に動作確認をすることがあります。

こうした理由から、コーディング以外の作業に作業や集中力を奪われないように、早々に自動化できるものは自動化してしまいます。

主にやることとしては、次の通りです。

<!-- textlint-disable prh -->
* Gradleでビルドができるようにしておくこと
  * そもそもADT時代のプロジェクトなら、プロジェクトは新規作成の方向で進める
  * Android StudioのStableチャンネルの最新版で動くようにする
* デバッグ（開発）版とリリース版のapplicationIdを分けて同端末で共存できるようにする
* Firebase App DistributionもしくはDeployGateを使えるようにする
* CIでFirebase App Distribution（もしくはDeployGate）にアップロードするまでを実装する
<!-- textlint-enable prh -->

もしgradlewすらない、つまりADT時代に作られたプロジェクトが対象の場合、素直にAndroid Studioから新規でプロジェクトを作成してソースコードを丸ごと移植すべきです。
下手にADT時代のプロジェクトを弄っても時間がかかるだけですし、あとあとのメンテナンスのしづらさの原因にもなることでしょう。

あとはテスト関連がちゃんと実装されているのなら、そちらもCLI（gradlew）で実行できることを確認しておきます。

### easylauncherを利用した、アイコンによるbuildTypeの可視化

[akaita/easylauncher\-gradle\-plugin](https://github.com/akaita/easylauncher-gradle-plugin)

easylauncherを導入することで、buildType（＋Flavors）ごとにアプリアイコンへリボン表記を追加できます。
デバッグ版とリリース版を区別しやすくする方法として、文字列リソースを使ってアプリタイトルを変える方法もありますが、こちらも導入することでより分かりやすくなります。

ちなみにeasylauncherはビルドするマシンがインストールしているフォントを利用してリボンを生成するので、事前にCI環境へフォントをインストールする必要があります。
Dockerでの対応方法に関しては、以前に記事で書いているので、こちらをご参照ください。

[easylauncherをdocker上でも使えるようにする \| 山田航空ネットワーク3rd](/note/easy-launcher-use-docker/)

なお、アダプティブアイコンを導入している（する）のであれば、backgroundをbuildTypeごとに変えてしまうという手もあります。
ほかにもアイコンのリソースそのものをbuildTypeごとに変えてしまうのもよいでしょう。
そのあたりの判断は、ケースバイケースです。

[Adaptive icons  \|  Android Developers](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)

### Firebase App DistributionとDeployGateのどちらを採用すべきか

社内の開発アプリ配布ツールを選択する上でメジャーどころといえばこの2つですが、個人的にはどちらでも（開発者視点では）問題ありません。
Androidアプリに関して言えば、どちらもgradleプラグインが用意されていて、どちらもCLIでデプロイが可能だからです。

Firebase App DistributionはGoogleが開発していることと、金銭的なコストは一切発生しない点が大きなメリットですが、配布ページや専用アプリがローカライズされていません。
また、不特定多数向けた配布も行えません。
一方DeployGateは国内サービスということもあり、英語アレルギーな方への配慮は考慮されていますが、ビジネス利用の場合は有料になるので注意が必要です。

* [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
* [DeployGate](https://deploygate.com/)

### CIは何を選ぶか、どこまでやるか

個人的にはCLIで実行ができるようになっているので、Circle CI・Jenkins・GitHub Actions、そのほかのCI環境でも問題ないと考えています。
そもそも環境によってはCIが用意できない場合もあります。
そのために、事前にgradleでやりたいことがすべて解決できるようにしているわけです。

CIでやりたいことはたくさんありますが、今回のようなケースとタイミングでは、ユニットテストの実行とApp Distributionへの自動配信だけにとどめます。

```sh
./gradlew --stacktrace clean testDebugUnitTest assembleDebug appDistributionUploadDebug
```

とりあえずこれを実行するだけです。
これならCIがなくても、コマンド1つで済みます。
あとはCI環境で実行するなら、テスト結果やビルドされたapkをartifactとしてアップロードするぐらいです。

以上です。