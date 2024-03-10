---
title: "Androidアプリのエラーハンドリング（例外の扱い方）を考える（WIP版）"
date: 2024-03-10T22:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["android", "error-handling", "architecture", "thinking"]
---

最近、Androidアプリのエラーハンドリングの実装方法について考えることがあったので、とりあえずいま頭に浮かんでいる内容をアウトプットしてみることにしました。

## ざっくりとした前提

[公式が紹介しているアプリ アーキテクチャ ガイド](https://developer.android.com/topic/architecture?hl=ja)にのっとって作られていることを前提とする。

基本的には例外の扱い方を記述する。
なぜならそれ以外のエラーと呼ばれるものは、基本的にUIレイヤ（ユーザー操作）でしか発生しないものだと認識しているため。

## 各レイヤのエラーの扱い方

### データレイヤ

データレイヤにもリポジトリとデータソースが存在するが、データソースに関しては発生したExceptionは、そのままリポジトリに投げる。
リポジトリも基本的に、発生したExceptionはそのままドメインレイヤに投げる。

ただし、ここでRetrofitやRoomなどが独自定義しているExceptionに関しては、アプリ内の共通化したExceptionに変換して投げたい。
これは関心の分離の話で、ドメインレイヤが具体的にデータソースが何でデータを引っ張っているかを認識させたくないため。

また、データソースがネットワークから取得する場合、サーバレスポンスを考慮する必要がある。
サーバレスポンスの仕様はサーバによっては独自の仕様みたいなものがある。
よくあるのは、あらゆるレスポンスは200で返し、返却値の中身でエラー判別をするようなタイプ。
このあたりの独自仕様を丸めて、アプリ内で標準化させるためにも共通のExceptionを作成して、これを投げるようにしたい。

```kotlin
class ApiResponseException(
    val statusCode: Int,
    val errorMessage: String?,
    val errorBody: String? = null
) : Exception("$statusCode: $errorMessage")
```

たとえばこんな感じのException。

### ドメインレイヤ

ここが微妙に悩ましい。
基本的にはここもリポジトリから受け取ったthrowがあれば、そのままUIレイヤに流してよさそうな気がする。
先にUIレイヤの話を書くと、たとえばデータレイヤから401エラーのような認証エラーが飛んできた場合、ユーザーに再認証の操作を要求する必要が出てくることもある。
そうなると、ここで認証エラーを握りつぶすとUIレイヤでは何のエラーかを知ることができなくなってしまう。
さらにドメインレイヤ用に別のエラークラスを用意するのも、設計としては冗長だし、分離としても半端な感じがする。
関心の分離とは言うものの、「どんなエラーが出ているか」を知るためには、これはそのままUIレイヤまで流すのが妥当そうに思える。

### UIレイヤ

UIレイヤでは、これまで上がってきた例外をどうやってユーザーに伝えるかという点を考慮する必要がある。
さらにそのうえで、アプリ内の動作を制御するエラーがあることも考慮しなければいけない。

ここからはExceptionのまま管理するのは冗長というか、最終的にユーザーに伝える手段（ダイアログやスナックバー）の選択が分かりづらくなってしまう。
そのため、ここからは別のクラスに変換するのが丸そう。
具体的には、ユーザーへの通知やアプリ内部の動作を考慮して、UIエラー用のsealed classで管理するのが良さそう。

```kotlin
sealed class ErrorUiData {
    // 通常表示・ダイアログを表示
    data class NormalError(
        val title: String,
        val message: String,
    ): ErrorUiData()

    // 簡易表示・スナックバーを表示
    data class SimpleError(
        val message: String,
    ): ErrorUiData()

    // 注釈付きのダイアログで表示
    data class RichError(
        val title: String,
        val message: String,
        val description: String,
    ): ErrorUiData()

    // 認証エラー・ユーザーに通知しつつログアウトを実施
    data class UnauthorizedError(
        val title: String,
        val message: String,
    ): ErrorUiData()
}
```

たとえば、こんな感じ。
Exceptionからエラー用クラスへの変換は拡張メソッドなどで実装してもよいが、画面によって扱いが異なる場合もある可能性があるため、頭の隅にいれておく。
また当然ながら、この変換はViewModel内で実施する。

## WIPから完成に向けて考えること

- 具体的なコードの記載
- ローカル（DBなど）周りの例外の考慮で漏れがないか