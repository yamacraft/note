---
title: "Flutterの勉強を始めたのと今後のFlutterとの付き合い方"
date: 2022-05-06T20:00:00+09:00
draft: false
categories: ["tech", "work"]
tags: ["tech", "work", "flutter", "web"]
---

GWの大半は休日返上して午前中にプロダクト開発、午後にFlutter（＋Jetpack Compose）の勉強をやっていました。

勉強といっても、自分の場合はコード書きながら覚えていくのが手っ取り早いという理由から、ひたすらGoogle Codelabsをやり続けていました。

## Flutterを勉強し始めたわけ

ここ数ヵ月、Flutter開発の需要が高まっているのを肌で感じていました。
私個人のFlutterに感じる将来性とか期待値とかはさておき、今後会社を何年も存続させていく（＝食べていく）ためには、新たな武器が必要になると感じたのが大きな理由です。（まだ自社開発関連の収入なんてものはないため）

あとはそろそろ、個人でWebサービスを開発するための基盤が１つ欲しかったのもあります。

## 使ったCodelabsのコンテンツと雑感

* [Write your first Flutter app, part 1](https://codelabs.developers.google.com/codelabs/first-flutter-app-pt1#0)
* [Write Your First Flutter App, part 2](https://codelabs.developers.google.com/codelabs/first-flutter-app-pt2#0)

まずはこの２つがFlutterの基礎の基礎っぽい内容。
リスト表示とタップによるアイテムの表示変更、Navigationを使った画面遷移が学べる。
特にPart1に関しては、[Flutterの公式ドキュメントのチュートリアル](https://docs.flutter.dev/get-started/codelab)と同じ。

* [Building beautiful UIs with Flutter](https://codelabs.developers.google.com/codelabs/flutter#0)

こちらもほぼ上記と同レベルのレイアウト基礎＋αな内容。
ただこちらはAndroid Studioの利用を前提しているので注意。
それも込みで、若干指示の内容が雑になるのが気になった。

* [MDC\-101 Flutter: Material Components \(MDC\) Basics](https://codelabs.developers.google.com/codelabs/mdc-101-flutter#0)
* [MDC\-102 Flutter: Material Structure and Layout](https://codelabs.developers.google.com/codelabs/mdc-102-flutter#0)
* [MDC\-103 Flutter: Material Theming with Color, Shape, Elevation, and Type](https://codelabs.developers.google.com/codelabs/mdc-103-flutter#0)
* [MDC\-104 Flutter: Material Advanced Components](https://codelabs.developers.google.com/codelabs/mdc-104-flutter#0)

FlutterでMaterial Designを使ったレイアウト設定が主な内容。
ただしベースとなるコードにはカスタムViewのコードがいくつもあるので参考になりそう（ちゃんと読んでないので断言はできない）。

## 上記のコンテンツでは学べなかった内容

### 個人的に必須で学びたいもの

* APIとのHTTP通信とJSONのパース周り
* Firebaseとの連携（特にAuthenticationとFirestore）
* Navigationで遷移する際のデータの相互受け渡し
  + Androidで言うところのExtras関連
* 状態（ステータス）保存
  + たとえばログイン状態を画面遷移しても保持＆監視できる方法

とりあえずFirebaseに関しては[「FlutterのFirebaseを知る」](https://firebase.google.com/codelabs/firebase-get-to-know-flutter#0)というのがあったので、次回触ってみることにします。

### 現状必須ではないが、覚えておきたいもの

* develop、releaseなどの環境切り替え
* CIでのLintチェックやデプロイ対応

ひとり開発ではそこまで急いで覚える必要はないけれど、会社規模での開発になると必要になってくるもの。
ぜひ覚えて活用できるようにしたい。

## プライベートと自社開発でFlutterをどう扱うか

いまのところ、Webアプリの開発に使うことは検討していますが、AndroidやiOSのアプリ開発で使う予定はありません。

* コードは１つで済んだとしても、リリース後のストア対応や動作チェックの手間が増える
* 現状Webアプリで提供できるものであれば、アプリ版としてリリースする必要性を感じない
* アプリで作りたいものは自分の欲しいものになるので、Androidアプリの選択肢しかない

とりあえずしばらくは、Flutterの基本的な使い方を覚えることを最優先に付き合っていく予定です。
