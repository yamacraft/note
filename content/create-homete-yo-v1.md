---
title: "GPT-3に褒めてもらうプロトタイプを作った"
date: 2023-02-07T18:30:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "flutter", "gpt-3"]
---

## 作ったもの紹介

{{< tweet user="yamacraft" id="1622399516317216769" >}}

chatGPTで特定人物の口調を真似させたり、決められたルールで会話させている人たちを見かけたことがきっかけで、上記のツイートを投稿しました。
その後GPT-3のAPIで再現できそうだという情報をいただいたので、試しにFlutterでプロトタイプを作ってみました。

{{< tweet user="yamacraft" id="1622518573032955905" >}}

とりあえず思ったことができるかの確認レベルですので、Flutterから直接Open AIのAPIを叩いています。
そのため後述する理由で一般的な公開もまだできないのですが、いずれ反響を見ながらテスト版を公開できるところまでやれたらなと考えています。

## 考えること

- APIはバックエンド経由でアクセスしたい（バリデーションも含めたセキュリティ的な理由で）
  - とりあえずnodejsでのアクセスも確認したので、Cloud Functionの利用を検討
- レスポンスまでに時間がかかるので、その対応
- APIの利用料金対応
- Flutterの正しい設計方法がわからない！

## 参考資料

- [ChatGPT: Optimizing Language Models for Dialogue](https://openai.com/blog/chatgpt/)
- [OpenAI API](https://openai.com/api/)

個人的にはチュートリアルをちょっとだけ触ったflutterを久しぶりに動かして、思いついたその日のうちにプロトタイプまで作れたことに感動しました。

作業記録的な雑多なメモですが、以上です。