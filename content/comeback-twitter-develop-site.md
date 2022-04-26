---
title: "Twitter開発者ポータルの出禁が解除されてた"
date: 2022-04-26T20:00:00+09:00
draft: false
categories: ["tech"]
tags: ["tech", "twitter"]
---

Twitterに書いてある内容がすべてなんですが、知らないうちにTwitter開発者ポータルのサイトがリニューアルされて、出禁も解除されていました。

{{< tweet 1518747336398508032 >}}

## （唐突な宣伝）

Hometeという、SNS系のアプリをオープンテストで公開しています。

[Homete | 匿名でお互いを褒め合う、優しいコミュニケーションツール](https://homete.yamaglo.jp/)

## 出禁に（おそらく）至った経緯

[TwitterAPIを申請して一発で承認されるまでの手順まとめ（例文あり）＋APIキー、アクセストークン取得方法 \| DevelopersIO](https://dev.classmethod.jp/articles/twitter-api-approved-way/)

数年前からTwitterのAPIを利用するためには申請が必要で、その申請をした結果出禁になりました。
何を言っているのか分からないかと思われるでしょうが、私にもわかりません。
おそらく申請内容がリジェクトされ、そのまま再申請もできない状態になったのだと判断しています。

{{< tweet 1290170932779053056 >}}

こんな感じで開発者ポータルのTOPページから、申請するためのリンクが消えてなくなっていました。

この当時は申請するとTwitterから申請受け付けのメールが来ていたのですが、確認したところ2019年9月でした。
約2年半の出禁でした。

## 突然の出禁解除

[いきなりの方針転換？ Twitter、サードパーティ製のアドオンを集めた専用サイトをオープン【やじうまWatch】 \- INTERNET Watch](https://internet.watch.impress.co.jp/docs/yajiuma/1405545.html)

今朝方、上記のニュースを見かけたので久しぶりに開発者ポータルを覗いたところ、出禁が解除されていることに気が付きました（記事冒頭のツイート参照）。

[Twitter Developers](https://developer.twitter.com/en/portal/dashboard)

開発者ポータルのデザインもリニューアルされていました。
いつリニューアルされていたのかはわかりませんが、ちょっと検索してみたところ、去年末あたりの時点ではまだ紫カラーのポータルサイトだったようです。

プロジェクトの追加に関してはこれまで通り説明の記述が必要ですが、審査をまたずにTokenが発行されました。

``` sh
$ curl -X POST 'https://api.twitter.com/2/tweets/search/stream/rules' \
-H "Content-type: application/json" \
-H "Authorization: Bearer *************" -d \
'{
  "add": [
    {"value": "from:twitterdev from:twitterapi has:links"}
  ]
}'

{"meta":{"sent":"2022-04-26T10:58:29.668Z","summary":{"created":0,"not_created":1,"valid":0,"invalid":1}},"errors":[{"value":"from:twitterdev from:twitterapi has:links","id":"1518831215612096512","title":"DuplicateRule","type":"https://api.twitter.com/2/problems/duplicate-rules"}]}%
```

無事に動きました。

### 作れるプロジェクト数について

確認でProjectを１つ作ったところ、Create Projectのボタンが消えました。
まだドキュメントの方をチェックしてないので理由は不明です。
１ユーザー１プロジェクトの可能性がありますね。

![見当たらなくなったCreate Project](/note/image/comeback-twitter-develop-site/create_project_list.png)

## イーロン・マスクのおかげなの？

個人的見解ですが、関係ないんじゃないでしょうか。
サイトのリニューアル含め、やれと言われて数日で誕生するとはとても思えないの、で早くて数ヵ月ぐらい前からAPIの制限を軟化する動きがあったんじゃないかなと。

その時からイーロン・マスクの買収の話が裏で進んでいたのなら。そうかもしれませんね。

## さいごに

何気なくつぶやいたつぶやきが丸一日中ずっとRTされてたりして驚きました。

Twitterの反応を見る限り、意外と自分と同じように出禁状態だった人がそれなりにいたこともわかりました。
ただ今回の件で全員が出禁解除されているわけではないようで、何がきっかけで出禁解除になったのかはなんともわかりません。
もしかしたら一定期間が2年以上というレベルだった可能性もあります。

ちなみにTwitterコミュニティを作成する権利は提供されていません。
欲しい。

以上です。