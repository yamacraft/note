---
title: "Sample（サンプル）"
date: 2020-05-05T00:00:00+09:00
draft: true
author: ["yamacraft"]
categories: ["diary"]
tags: ["サンプル"]
images: ["/note/image/dummy.png"]
---

表示確認用の記事です。

## 各種記法

* リスト1
* リスト2
  * リスト2-1
  * リスト2-2
* リスト3

1. リスト1
2. リスト2
3. リスト3

> あのイーハトーヴォのすきとおった風、夏でも底に冷たさをもつ青いそら、うつくしい森で飾られたモリーオ市、郊外のぎらぎらひかる草の波。 またそのなかでいっしょになったたくさんのひとたち、ファゼーロとロザーロ、羊飼のミーロや、顔の赤いこどもたち、地主のテーモ、山猫博士のボーガント・デストゥパーゴなど、いまこの暗い巨きな石の建物のなかで考えていると、みんなむかし風のなつかしい青い幻燈のように思われます。では、わたくしはいつかの小さなみだしをつけながら、しずかにあの年のイーハトーヴォの五月から十月までを書きつけましょう。

項目1 | 項目2 | 項目3
:--- | :--: | --: 
テキスト1 | テキスト2 | テキスト3
テキスト1 | テキスト2 | テキスト3

**強調** *斜体* ~~取り消し~~

インラインコード -> `Discord.Client()`

```
const Discord = require('discord.js')
const admin = require("firebase-admin");
const client = new Discord.Client()

var getFirebaseDatabase = function() {
    let serviceAccount = require(`./serviceAccountKey.json`)
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://{project-id}.firebaseio.com/"
    })
    return admin.database()
}
```

```js
const Discord = require('discord.js')
const admin = require("firebase-admin");
const client = new Discord.Client()

var getFirebaseDatabase = function() {
    let serviceAccount = require(`./serviceAccountKey.json`)
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        databaseURL: "https://{project-id}.firebaseio.com/"
    })
    return admin.database()
}
```

## 各種埋め込み表示

{{< tweet user="i" id="1247107110636150786" >}}

{{< youtube yi1TbzML2cU >}}

:joy: :thinking: :pray: :bow:

## だしの取り方 - 北大路魯山人

<!-- textlint-disable -->

かつおぶしはどういうふうに選択し、どういうふうにして削るか。まず、かつおぶしの良否の簡単な選択法をご披露しよう。よいかつおぶしは、かつおぶしとかつおぶしとを叩《たた》き合わすと、カンカンといってまるで拍子木か、ある種の石を鳴らすみたいな音がするもの。虫の入った木のように、ポトポトと音のする湿《しめ》っぽい匂《にお》いのするものは悪いかつおぶし。

本節と亀節ならば、亀節がよい。見た目に小さくとも、刺身にして美味い大きいものがやはりかつおぶしにしても美味だ。見たところ、堂々としていても、本節は大味で、値も亀節の方が安く手に入る。

次に削り方だが、まず切れ味のよい鉋《かんな》を持つこと。切れ味の悪い鉋ではかつおぶしを削ることはむずかしい。赤錆《あかさび》になったり刃の鈍くなったもので、ゴリゴリとごつく削っていたのでは、かつおぶしがたとえ百円のものでも、五十円の値打ちすらないものになる。

どんなふうに削ったのがいいだしになるかというと、削ったかつおぶしがまるで雁皮紙《がんぴし》のごとく薄く、ガラスのように光沢のあるものでなければならない。こういうのでないと、よいだしが出ない。削り下手なかつおぶしは、死んだだしが出る。生きたいいだしを作るには、どうしても上等のよく切れる鉋を持たねばならない。そしてだしをとる時は、グラグラッと湯のたぎるところへ、サッと入れた瞬間、充分にだしができている。それをいつまでも入れておいて、クタクタ煮るのではろくなだしは出ず、かえって味をそこなうばかりである。いわゆる二番だしというようなものにしてはいけない。

そこで、まず第一に、刃の切れる、台の平らな鉋をお持ちになることをお勧めしたい。かつおぶしを非常に薄く削るということは経済的であり、能率的でもある。

―― [青空文庫より引用](https://www.aozora.gr.jp/cards/001403/card49986.html)

<!-- textlint-enable -->
