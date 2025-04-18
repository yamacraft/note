---
title: "D.I.C. レストア記録 #2 - コードをkotlinに置き換える"
date: 2020-10-12T20:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "work", "app_restore", "dic_restore", "android"]
---

## D.I.C.レストア記録記事一覧

- [#0 - レストアの方針](/note/restore-dic-00/)
- [#1 - 開発環境を整える](/note/restore-dic-01/)
- [#2 - コードをkotlinに置き換える](/note/restore-dic-02/)
- [#3 - マテリアルデザインとダークテーマへの対応](/note/restore-dic-03/)

## コードをKotlinに変えるということ

Kotlinは2017年にAndroidアプリの開発公式言語として採用されました。
現在は公式のドキュメントのサンプルもKotlinでの記載が優先して表示されるなど、メインの開発公式言語の地位を築いています。
この記事ではKotlinという言語の優劣に関して触れませんが、人気やシェアという点を考えれば、今後のメンテナンスを考えてKotlinに早急に置き換えてしまいたいです。

## D.I.C.でやったこと

D.I.C.はもともとコードの少ないアプリだったので、今回を機に、すべてのコードをKotlinに置き換えました。

## Androidアプリアーキテクチャへの置き換え

現在はAndroidが公式で推奨している、アプリのアーキテクチャが存在します。

![Androidアプリの推奨アーキテクチャ図（引用）](/note/image/restore-dic-02/final-architecture.png)
> 公式のアーキテクチャガイドより引用

公式でLiveDataとViewModelを用意してくれたおかげで、MVVMモデルでの開発がとてもやりやすくなりました。
公式が推奨するアーキテクチャもMVVMをベースにしたようなものとなっています。

<!-- textlint-disable prh -->
D.I.C.は当時とりあえず動けばという感覚で作っていたので、いわゆる「Activity全部乗せ」で実装していました。

せっかくなのでD.I.C.もこのアーキテクチャに合わせた形でリファクタリングを行いました。
ただし、まだD.I.C.にはRepositoryまで必要とするような処理がありません。
またリファクタリングの方に時間をかけすぎるといつまでたっても改修が終わらないので、いったん「Activity全部乗せ」を「ViewModelにView以外の処理全部乗せ」に変えました。
Viewで完結させるべき処理とそれ以外を分けるだけでも、コード自体の可読性はかなり良くなりました。
<!-- textlint-enable prh -->

![Androidアプリの推奨アーキテクチャ図（引用）](/note/image/restore-dic-02/restore-dic-02-architecture.png)

私の大好きな、WVVM（Whatever-View-ViewModel）というやつです。
といっても、今回はWhateverに該当するものすらありませんが。

## 採用するライブラリについて

今回の対応で、合わせてバックグラウンドの処理をCoroutineに変更しました。

基本的に実装内容は、なるべくAndroidが公式で用意されたもので実装するように置き換えていきます。
okHttpやRetrofitといった、もはや公式ライブラリと遜色ないレベルで使われているものはそのままでもよいです。
ですが、枯れたとも言えないような更新の止まったサードパーティ製のライブラリは、このタイミングで取り外しておきたいです。

以上です。