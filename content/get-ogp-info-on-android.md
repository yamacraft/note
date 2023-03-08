---
title: "AndroidでOGP情報を取得する（OkHttp3+Jsoup）"
date: 2023-01-23T18:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android"]
---

対象のWebサイトのOGP情報を取得する方法ですが、私には対象のサイトのHTMLを読み込んでからmetaタグのOGP情報を取得する方法しか浮かびませんでした。

ということで、その実装方法のメモです。

## 使用するライブラリ

- [OkHttp3](https://github.com/square/okhttp)
- [Jsoup](https://jsoup.org/)

OGP情報を取得するだけならJsoupを使わずに、正規表現だけで済む気もしますが、こっちの知識には疎くどんな罠が潜んでいるか私にはわかりません。
ですので、素直にHTMLパーサを使います。

``` gradle
implementation platform("com.squareup.okhttp3:okhttp-bom:4.10.0")
implementation "com.squareup.okhttp3:okhttp"
implementation "com.squareup.okhttp3:logging-interceptor"
implementation 'org.jsoup:jsoup:1.15.3'
```

## 実装部分

特に何か難しいことをしているわけではなく、素直にOkHttp3の機能でHTMLを取得し、JsoupでOGPの情報を取得しています。

Androidの推奨アーキテクチャにのっとり、Repositoryで実装しています。
UnitTestの実装までやっていないので、DI部分の作りは甘い可能性があります。

``` kotlin
class DefaultWebSiteRepository @Inject constructor(
    private val okHttpClient: OkHttpClient,
) : WebSiteRepository {

    // OkHttp3でURL先のhtmlを取得する
    override suspend fun loadHtml(url: String): Result<String> {
        val request = Request.Builder().url(url).build()
        val response = okHttpClient
            .newCall(request)
            .execute()
        if (response.isSuccessful) {
            response.body?.string()?.let {
                return Result.success(it)
            } ?: return Result.failure(Exception("body is empty"))
        } else {
            return Result.failure(Exception("response code ${response.code}"))
        }
    }

    // html内のOGP情報を取得する
    override suspend fun getOgpData(html: String): Result<OgpData> {
        var siteName = ""
        var title = ""
        var url = ""
        var image = ""
        var description = ""

        val document = Jsoup.parse(html)
        val elements = document.select("meta[property~=og:*]")
        elements.forEach { element ->
            val property = element.attr("property")
            val content = element.attr("content")
            when (property) {
                "og:site_name" -> {
                    siteName = content
                }
                "og:title" -> {
                    title = content
                }
                "og:url" -> {
                    url = content
                }
                "og:image" -> {
                    image = content
                }
                "og:description" -> {
                    description = content
                }
            }
        }
        val ogpData = OgpData(
            siteName = siteName,
            title = title,
            url = url,
            image = image,
            description = description
        )
        return Result.success(ogpData)
    }
}
```

なぜHTMLのロードとOGPの取得を分けているかですが、その２つをまとめるのはビジネスロジック側の話と判断しているからです。
実際に `loadHtml()` と `gatOgpData()` を使って対象のURLからOGP情報を取得するまでの実装は、ドメインレイヤでやればよいという判断です。

以上、メモでした。