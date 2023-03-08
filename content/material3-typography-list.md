---
title: "Material Design3でTypographyが変わった"
date: 2022-01-20T20:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android", "Material Design3", "Material Design"]
---

## Material3の正式リリース

先日、Android版のmaterial-componentsの1.5.0がリリースされました。
このリリースバージョンから[Material Design3](https://m3.material.io/)が含まれるようになりました。

[Release 1\.5\.0 · material\-components/material\-components\-android](https://github.com/material-components/material-components-android/releases/tag/1.5.0)

## Material3のテキスト（Typography）について

Material3（Material Design3対応のテーマ）といえば色周りが（多分）注目されがちですが、Typographyにも大きな変更が入っています。
これまではHeadline / Subtitle / Body / Captionで分けられていた名称がDisplay / Headline / Title / Labelの項目に変わりました。
さらにそれぞれ、Large / Medium / Smallの3種類の大きさが用意されています。

ただしこれらのテキスト設定は、完全に新規で作られたというわけではなく、既存のMaterial Componentsがベースになっています。
今後既存のMaterial Designからのマイグレーションをやったときの事を考え、Material3のそれぞれの設定が過去の何の設定をベースにしているか一覧にしてみました。

Material3 | Material Components | Default Size(M3)
:---|:---|:---
DisplayLarge | Headline2 | Regular 57sp
DisplayMedium | Headline3 | Regular 45sp
DisplaySmall | Headline4 | Regular 36sp
HeadlineLarge | Headline4 | Regular 32sp
HeadlineMedium | Headline5 | Regular 28sp
HeadlineSmall | Headline6 | Regular 24sp
TitleLarge | Headline6 | Regular 22sp
TitleMedium | Subtitle1 | Medium 16sp
TitleSmall | Subtitle2 | Medium 14sp
BodyLarge | Body1 | Regular 16sp
BodyMedium | Body2 | Regular 14sp
BodySmall | Caption | Regular 12sp
LabelLarge | Body2 | Medium 14sp
LabelMedium | Caption | Medium 12sp
LabelSmall | Caption | Medium 11sp

とはいえ、これは1.5.0時点での対応表になるので、今後変わる可能性はあります。
またベースと言っても、フォントサイズはMaterial3で微妙に変わっています。
注意してください。

## 参考

* [Material3に関するTypographyの公式ドキュメント](https://github.com/material-components/material-components-android/blob/master/docs/theming/Typography.md)
* [Material3のstyle.xml](https://github.com/material-components/material-components-android/blob/master/lib/java/com/google/android/material/typography/res/values/styles.xml)
