---
title: "HometeにAIリプライ機能を搭載した話を動画にしました"
date: 2023-04-17T12:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "youtube", "homete"]
---

すっかりこのブログに書いた気でいましたが、書いていませんでした。（なので書きます。）

表題の通り、先日[Homete](https://homete.yamaglo.jp)に実装したAIリプライ機能に関する話を動画にして、YouTubeに投稿しました。

{{< youtube _P_2amfe_wQ >}}
[HometeにAIのリプライを追加した話【5分LT】 \- YouTube](https://www.youtube.com/watch?v=_P_2amfe_wQ)

以前からYouTubeも活用していきたいという話をしていましたが、ようやく第一歩を踏み出すことができました。

## 音声について

音声は[VOICEVOX](https://voicevox.hiroshiba.jp/)を利用しています。

![VOICEVOX](/note/image/post-youtube-homete-ai-reply/voicevox_ai_reply.png)

自身の肉声で収録しなかったのは、収録を含めた動画編集の手間を減らすためと、聞き取りやすさを重視したためです。
動画のコンセプトも動画単体のおもしろさではなく、中身の情報を伝えることを最優先と考えていたので、個性をわざわざ出す必要はないと判断しました。

そうした理由から、音声もなるべく高すぎず低すぎず、聞き取りやすさを重視して選んでいます。
最終的に[No.7（アナウンス）](https://voicevox.hiroshiba.jp/product/number_seven/)と[剣崎雌雄](https://voicevox.hiroshiba.jp/product/kenzaki_mesuo/)の2つに絞りましたが、明らかに合成音声を利用していると判断してもらいたかったので、女性声のNo.7を採用しました。

## 画像について

![Googleスライド](/note/image/post-youtube-homete-ai-reply/presentation_ai_reply.png)

普段の勉強会の発表資料を作るのと同じ感覚で、Googleドライブのスライドで作成し、ページごとにPNG画像を出力して使っています。
デフォルトのページ設定（4:3だろうと16:9だろうと）では画像の出力の解像度が低めですが、カスタムでピクセル指定にしておけばその解像度で画像を出力できます。

あらかじめ字幕をつけることを前提としていたので、その領域だけは確保しつつ、また字幕をつける前提のため資料からはテキストをなるべく省くようにしました。
ちなみに途中のシーケンス図は、mermaidで作成し[公式エディタ](https://mermaid-js.github.io/mermaid-live-editor/)から画像を出力して使っています。

## 編集について

編集はAdobe Premiere Proを使っています。
ですが、独自機能はほぼ使っていないので、DaVinci Resolveでもほぼ同じものが作れるはずです。

## 今後の展望

動画のタイトルにもあるように、YouTube文化に合わせたLTというイメージで今回の動画を作成し公開しました。
ようやく各種勉強会が復活の兆しにありますが、その前からLT募集のある勉強会は減りつつあったため、こうした発表をする機会はなかなかありませんでした。

今後もこうした形で、気軽に以前勉強会でやっていたようなことを、YouTube上でも発信できたらなと考えています。