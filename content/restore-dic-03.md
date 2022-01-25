---
title: "D.I.C. レストア記録 #3 - マテリアルデザインとダークテーマへの対応"
date: 2020-10-14T18:00:00+09:00
draft: false
categories: ["tech"]
tags: ["tech", "work", "app_restore", "dic_restore", "android"]
---

## D.I.C.レストア記録記事一覧

- [#0 - レストアの方針](/note/restore-dic-00/)
- [#1 - 開発環境を整える](/note/restore-dic-01/)
- [#2 - コードをkotlinに置き換える](/note/restore-dic-02/)
- [#3 - マテリアルデザインとダークテーマへの対応](/note/restore-dic-03/)

## D.I.C. v2.0.0を公開しました

本記事で解説している内容を実装済みのD.I.C.は、現在公開中です。

[D\.I\.C\. \- Google Play のアプリ](https://play.google.com/store/apps/details?id=jp.yamaglo.dic)

本アプリは合同会社ヤマダ印、並びに@yamacraftの技術的なプロモーションとして開発しています。
また、コードはすべてGitHubにて近日公開予定です。

正式な公開前にも、業務案件のご依頼に関係した理由で閲覧をご希望の場合は、別途対応します。
ぜひ、[合同会社ヤマダ印の問い合わせフォーム](https://yamadajirushi.co.jp/contact/)よりご連絡ください。

## マテリアルデザインへの対応

せっかく中身を新しくしたので、外側も新しくします。
マテリアルデザインのガイドラインは公式が用意してくれているので、がんばって解読しながら実装していきます。

[Material Design](https://material.io/)

また、今回を機にテーマカラーを設定しました。
色自体はカラーユニバーサルデザインの推奨配色から採用しました。

[カラーユニバーサルデザイン推奨配色セット](https://jfly.uni-koeln.de/colorset/)

### 実装の参考

style周りは正直なところベストプラクティスという書き方が自分の中で確立できていないので、ioschedやDroidKaigi公式アプリのコードを参考にしています。

- [google/iosched: The Google I/O 2019 Android App](https://github.com/google/iosched)
- [DroidKaigi/conference\-app\-2020: The Official Conference App for DroidKaigi 2020 Tokyo](https://github.com/DroidKaigi/conference-app-2020)

## UIの再選定

今回のような古いアプリを突然新しく改修する場合、特に使っているサードパーティ製のライブラリが正常動作しなくなりがちです。
だいたいがアプリ同様にライブラリのメンテナンスも止まっているケースがほとんどですので、それらの使用を取りやめるしかありません。

この場合はケースバイケースですが、基本的には公式のUIのみを使う形に改修していきます。
そもそもメンテナンスは今後も頻繁にできるかわかりません。
なるべく公式のUIを利用するようにして、特にtargetSdkVersionのアップデートの際に、そもそもビルドできないような状況は避けるようにします。

ちなみにD.I.C.に関してはサードパーティ製のUIライブラリは使用していないので、そのまま公式のUIで実装を続けていきます。

## フォントサイズの設定

公式のガイドラインでは、各テキストとフォントサイズに関する細かいガイドラインが指定されています。

[The type system \- Material Design](https://material.io/design/typography/the-type-system.html#type-scale)

`TextAppearance.MaterialComponents.*` に、このガイドラインに沿ったTextAppearanceが用意されているので、これを使います。
そのまま使うのではなく、これをベースに文字色などを設定して統一化させます。

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="TextAppearance.DIC.Headline5" parent="@style/TextAppearance.MaterialComponents.Headline5">
        <item name="android:textColor">?colorOnBackground</item>
    </style>

    <style name="TextAppearance.DIC.Headline6" parent="@style/TextAppearance.MaterialComponents.Headline6">
        <item name="android:textColor">?colorOnBackground</item>
    </style>

    <style name="TextAppearance.DIC.Subtitle1" parent="@style/TextAppearance.MaterialComponents.Subtitle1">
        <item name="android:textColor">?colorOnBackground</item>
    </style>

    <style name="TextAppearance.DIC.Subtitle2" parent="@style/TextAppearance.MaterialComponents.Subtitle2">
        <item name="android:textColor">?colorOnBackground</item>
    </style>

    <style name="TextAppearance.DIC.Body1" parent="@style/TextAppearance.MaterialComponents.Body1">
        <item name="android:textColor">?colorOnBackground</item>
    </style>

    <style name="TextAppearance.DIC.Body2" parent="@style/TextAppearance.MaterialComponents.Body2">
        <item name="android:textColor">?colorOnBackground</item>
    </style>

    <style name="TextAppearance.DIC.Caption" parent="@style/TextAppearance.MaterialComponents.Caption">
        <item name="android:textColor">?colorOnBackground</item>
    </style>

    <style name="TextAppearance.DIC.Button" parent="@style/TextAppearance.MaterialComponents.Button">
        <item name="android:textColor">?colorOnBackground</item>
        <item name="textAllCaps">false</item>
    </style>
</resources>
```

ちなみにDroidKaigi公式アプリではNoto Sansを設定しているのですが、本アプリでは手間的な意味と容量的な意味でやりすぎなように感じたので、文字色の設定のみとしています。

アプリに合わせてHeadline1〜3を修正すべきではないかと最初思いましたが、weight設定の違い等もあるので、下手にアプリに合わせて数字をいじるのはやめた方が良さそうです。

## スペースの設定

スペースは意識しないと画面ごとに統一感がでなくなりがちな部分です。
D.I.C.では共通化したリソースを定義して、全体で使い回す設定値を個別のリソース名で設定することにしました。

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <dimen name="item_app_icon_size">48dp</dimen>

    <dimen name="tiny">4dp</dimen>
    <dimen name="small">8dp</dimen>
    <dimen name="medium">16dp</dimen>
    <dimen name="large">32dp</dimen>
    <dimen name="huge">64dp</dimen>

    <dimen name="section_padding_height">@dimen/medium</dimen>
    <dimen name="section_padding_width">@dimen/medium</dimen>
    <dimen name="separate_padding_height">@dimen/small</dimen>

    <dimen name="scroll_bottom_space">@dimen/large</dimen>
</resources>
```

## ダークテーマの設定

ダークテーマに関しては、とりあえずそれっぽく対応だけさせておきたかったので、DroidKaigi公式アプリのTheme設定をそのまま当て込んでいます。

[conference\-app\-2020/themes\.xml at master · DroidKaigi/conference\-app\-2020](https://github.com/DroidKaigi/conference-app-2020/blob/master/corecomponent/androidcomponent/src/main/res/values-night/themes.xml)

多少なり最近のGoogleアプリにそろえようと思って調べて気付きましたが、最近のGoogleアプリはActionBarをそもそも使っていませんでした。
とりあえずあんまりPrimaryColorが主張してもよろしくなさそうですので、ActionBarは黒色としました。

## 最終的なデザイン

改修前と改修後、ダークテーマ版を並べます。

![改修前のD.I.C.の画面](/note/image/restore-dic-03/restore-before-dic.png)

![改修後のD.I.C.の画面](/note/image/restore-dic-03/restore-after-dic.png)

![ダークテーマ適用時のD.I.C.の画面](/note/image/restore-dic-03/restore-after-dic-dark.png)

以上です。