---
title: "2022 2Qやったこと"
date: 2022-07-04T17:30:00+09:00
draft: false
categories: ["work"]
tags: ["work", "done-report"]
---

四半期ごとにやっている報告的なものです。

## 2022年のまとめ

* [2022 1Q](/note/yamacraft-2022-1q-done/)

## 仕事

[合同会社ヤマダ印](https://yamadajirushi.co.jp/)の代表社員兼ITエンジニアとして仕事をしています。

### 開発支援業務

これまで同様、継続して契約しているクライアントさんのところでAndroidアプリの開発案件をやっていました（週４日）。
ちなみにフルリモート勤務です。

こちらのクライアントさんとは、一部契約内容の見直し等を行ったので、例外的に2Q期間内で11月末までの契約にもサインしています。（基本的にどの取引先であっても、契約期間は3ヵ月単位で更新しています）

### 自社開発

* リリース中の各アプリのライブラリアップデートを実施しました
* AAびゅーわで、これまでベータテスターでリリースしていた機能をマージしたアップデートを行いました
  * [AAびゅーわ v1\.8\.0をリリースしました \| team Y\.G\.E\. blog](https://yge.yamaglo.jp/posts/20220627-release-aaviewer-1-8-0/)
* 長いことヤマグロ関連のプロジェクトをyamacraftの個人GitHubアカウントで管理していましたが、ヤマグロのorganizationを作成し、そちらにすべて移行しました
* 上記に伴い、CIの挙動の見直しと改修しました
  * CircleCIの利用を廃止し、GitHub Actionsへの全面移行を実施

以下はCI改修の副産物として書いたブログ記事です。

* [個人（小規模）アプリ開発のブランチモデルとCI利用方法のアイデア](/note/idea-branch-model-and-ci/)
* [GitHub Actionsでtagをpushするための下準備と実行](/note/output_tagname_android/)
* [Androidアプリの署名に使う鍵ファイルをコマンドライン（CLI）で生成する](/note/create-keystore-cli/)

## プライベート方面のトピック

* [ブラジリアン柔術をはじめました](/note/restart-bjj/)
* ゲーム方面は、気がつけばGT7ばかりやっていました

### 体重の推移

![体重推移（2022年/2Q）](/note/image/yamacraft-2022-2q-done/year_chart_weight.png)

![体脂肪率推移（2022年/2Q）](/note/image/yamacraft-2022-2q-done/year_chart_bfp.png)

![除脂肪重推移（2022年/2Q）](/note/image/yamacraft-2022-2q-done/year_chart_lbm.png)

4月から5月にかけて緩やかに体重が上昇していたので、食事を少し見直しました。
結果的に除脂肪重（おそらく筋肉）が増えて脂肪が微減という、理想的な変化になっていました。

ブラジリアン柔術は5月から開始しましたが、まだ2Q時点ではスパーリングを含んだレッスンまで通っていません（6月末から）。
ですので、3Qでまた大きな変化が起こる可能性はあります。

## 売上／支援報告

6月に[『Androidアプリで始めるFirebase Authentication導入ガイド』](https://team-yge.booth.pm/items/1585068)の購入が2件ありました（合計1,000円）。
ありがとうございます。

## 振り返り／次Qの予定など

次の四半期に関しては、わりと目標立てしやすいものがあるので、そちらへ絞ることにします。

### 次Qにやりたいこと

* DroidKaigiのCFP応募、並びに当選時の資料作成／DroidKaigiアプリのコントリビュート参加
* 9月上旬に向けて、『Androidアプリで始めるFirebase Authentication導入ガイド』の大型アップデート
  * [Zennに作業メモを残すスクラップ記事を作りました](https://zenn.dev/yamacraft/scraps/a089e39a984879)
* 7月末〜8月中旬の間にHometeを正式リリース
* 新規アプリ開発に向けて、検証用のプロトタイプ作成

あとは気になっている技術絡みを雑多に、コツコツ触ることにします。
具体的にはFlutterとUnityとCameraX関連のコードラボを中心に。

あと3Q中に近辺で引っ越し先を探すことにします。
できれば年内に引っ越しも終わらせたい。

## さいごに

お仕事（開発支援業務の案件など）等のご連絡は、合同会社ヤマダ印へのご連絡は次のお問い合わせフォームなどをご利用ください。

* [開発支援業務の詳細について \| 合同会社ヤマダ印](https://yamadajirushi.co.jp/development-support-detail/)
* [Contact \| 合同会社ヤマダ印](https://yamadajirushi.co.jp/contact/)

カジュアル面談の窓口として、meetyもやっています。

* [yamacraftの趣味とつぶやいた話に深堀りできる1on1](https://meety.net/matches/iTroNLuBJEIr)
* [ヤマダ印の開発支援って何してくれるの？をお答えします](https://meety.net/matches/iTroNLuBJEIr)

{{< tweet 1514069667538935808 >}}