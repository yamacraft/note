---
title: "Androidアプリの署名に使う鍵ファイルをコマンドライン（CLI）で生成する"
date: 2022-04-11T17:30:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android"]
---

Gistの方で以前書いたメモですが、わりと何度も見直す機会があったので、あらためて少し解説を挟みながら記事を書くことにしました。

[Androidとかで使う証明書鍵をコマンドラインで生成する](https://gist.github.com/yamacraft/ed03bdcf08cc64bd82cbb82c6d06b9ae)

## 基本

Androidアプリの署名に使う鍵ファイルを生成したい場合、 `keytool` を使います。

``` sh
$ keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias
```

鍵アルゴリズムはRSA、キーサイズは2048を指定する必要があるみたいです。
また、エイリアスや有効日数の設定は後述する質問で聞かれないため、それらもここで設定する必要があります。

上記のコマンドの場合、キーストアのパスワード含め署名者情報の質問があるため、必要な情報を入力することで鍵が生成されます。

``` sh
$ keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-alias
キーストアのパスワードを入力してください:  
新規パスワードを再入力してください: 
姓名は何ですか。
  [Unknown]:  
組織単位名は何ですか。
  [Unknown]:  
組織名は何ですか。
  [Unknown]:  
都市名または地域名は何ですか。
  [Unknown]:  
都道府県名または州名は何ですか。
  [Unknown]:  
この単位に該当する2文字の国コードは何ですか。
  [Unknown]:  
CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknownでよろしいですか。
  [いいえ]:  y

10,000日間有効な2,048ビットのRSAのキー・ペアと自己署名型証明書(SHA256withRSA)を生成しています
        ディレクトリ名: CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=Unknown
[my-release-key.jksを格納中]
```

ちなみに、Androidアプリのgradleファイルで言う`keyPassword`と`storePassword`は同じものになります。
「キーストアのパスワード」と聞いているので、そういうことなんでしょうね。

また署名情報は何も入力しないとUnknownとして設定されます。
開発用の鍵ファイルなら問題ないでしょうが、本番用の鍵ファイルには信頼性を高めるためにもちゃんと入力しておきましょう。

## すべてをオプションですませたいあなたへ

上記のコマンドから応答形式で記述したパスワードや署名情報ですが、これらもkeytoolのオプションで設定できます。
パスワードの方も`-storepass`と`-keypass`でそれぞれ別のパスワードを指定できます。

署名情報は`-dname`オプションを使って、まとめて設定します。

署名情報はとにかく、パスワードに関しては端末の入力履歴に残ってしまうので、よく考えて使用を判断してください。

## debug.keystoreをCLIでまとめて作る

開発用でお馴染みの`debug.keystore`は、パスワードが`android`でエイリアスが`androiddebugkey`、署名情報は全部Unknownでされていることが多いです。
これをCLIで生成すると、次の記述になります。

``` sh
$ keytool -genkey -v -keystore app/debug.keystore \
    -keyalg RSA -keysize 2048 \
    -alias androiddebugkey -keypass android -storepass android \
    -validity 36500
    -dname "cn=Unknown, ou=Unknown, l=Unknown, st=Unknown, c=Unknown"

# one liner
$ keytool -genkey -v -keystore app/debug.keystore -keyalg RSA -keysize 2048  -alias androiddebugkey -keypass android -storepass android -validity 36500 -dname "cn=Unknown, ou=Unknown, l=Unknown, st=Unknown, c=Unknown"
```

以上です。