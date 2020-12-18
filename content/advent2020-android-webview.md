---
title: "WebViewで表示しているWebページのHTMLを取得する(deprecated)"
date: 2020-12-19T00:00:00+09:00
draft: false
tags: ["tech", "android"]
---

この記事は、 [QiitaのAndroid Advent Calendar 2020](https://qiita.com/advent-calendar/2020/android)の19日目の記事になります。

## 言いたいこと

**WebViewで表示しているWebページのHTMLを取得しようとするのは、セキュリティ懸念からお勧めできません**

## WebViewとは何か

その名のとおり、Webページ（HTML）を表示するためのViewです。
おそらく大半の端末では、ChromeまたはChromiumのコンポーネントを利用して表示しています。

現在のAndroidではCustom Tabsというしくみが用意されていますが、昔はアプリ内でWebページを表示するために、よくWebViewが使われていました。

## Custom Tabsとは何が違うのか

Custom Tabsは、端末内のブラウザアプリを利用して、Webページを表示するためのしくみです。
この時、Custom Tabsで利用可能なアプリが複数あった場合、ユーザーにどのブラウザを使用するか選択してもらうことになります。

Custom TabsはこうしたWebページを（ユーザーにとって）安全に表示するために作られたしくみですので、それ以外にどんな処理も追加できません。
開いたWebページに対して何か処理を行いたいのであれば、WebViewを使って実装する必要があります。

## WebViewで開いたWebページのHTMLソースを取得する

結論から書くと、WebView自体には開いているWebページのHTMLを取得できるようなAPIはありません。
ですので、JavaScriptを使って読み込みを行うことになります。

``` kotlin
@SuppressLint("JavascriptInterface")
override fun onCreate(savedInstanceState: Bundle?) {

    // ...

    @SuppressLint("SetJavaScriptEnabled")
    binding.webView.settings.javaScriptEnabled = true

    binding.webView.apply {
        addJavascriptInterface(this@WebViewSampleActivity, JS_INTERFACE_NAME)

        webViewClient = object : WebViewClient() {

            // Webページ読み込み完了時に呼ばれる
            override fun onPageFinished(view: WebView?, url: String?) {        
                // 今回は読み込み完了時点で呼び出すが、ボタンなどで任意に実行してもよい
                view?.loadUrl(JS_CODE_GET_INNER_HTML)
                super.onPageFinished(view, url)
            }
        }
    }
}

@Suppress("unused")
@JavascriptInterface
fun processJs(text: String?) {
    // バックグラウンドで呼び出されるので、UIスレッドで呼ばれる場合は注意
    runOnUiThread {
        binding.sourceTextView.text = "${text.orEmpty()}"
    }
}

companion object {
    private const val JS_INTERFACE_NAME = "Android"

    // htmlソースを取得する
    private const val JS_CODE_GET_INNER_HTML =
        "javascript:${JS_INTERFACE_NAME}.processJs(document.getElementsByTagName('html')[0].outerHTML);"
}
```

その昔、AndroidのWebViewにはJavaScript越しに任意のメソッドが実行されるという脆弱性がありました。
その脆弱性に関してはAndroid 4.2以降からは `@JavascriptInterface` アノテーションが付与されたメソッドしか呼ばれないように対策が取られています。
今回のサンプルコードの場合、 `processJs()` メソッド以外は呼ばれることがありません。

現在はminSdkVersionが16以下に設定されているアプリはだいぶ減りましたが、もしそうしたアプリでWebViewからHTMLソースを取得したい場合は **諦めてください。**

そもそも、これに限らずWebView自体は自社管理外からのコンテンツ（Webページ）を表示する場合、JavaScriptを有効にさせるべきではありません。
アプリネイティブのメソッド実行以外にも、JavaScript自体を利用した悪意ある攻撃をされる可能性があるためです。
これはJSSECが提供している、[『Androidアプリのセキュア設計・セキュアコーディングガイド』](https://www.jssec.org/report/securecoding.html)でも取り上げられています。

[4\. 安全にテクノロジーを活用する — Androidアプリのセキュア設計・セキュアコーディングガイド 2020\-11\-01 ドキュメント](https://www.jssec.org/dl/android_securecoding/4_using_technology_in_a_safe_way.html#webview%E3%82%92%E4%BD%BF%E3%81%86)

自社コンテンツのHTMLソースを取得したいのであれば、それ用のAPIを用意した方が安全です。
こうした処理を実装したいということは、デベロッパー側が制御できないようなWebページへのアクセスをするということを意味します。
ですので、私自身はこうした処理を実装すること自体はお勧めしません。

## 補足：通信処理でHTMLコードを取得することについて

単純なWebページであれば、OkHttpなりでGET通信すれば、JavaScriptなどを考慮せずにHTMLコードをそのまま取得できます。
ただこの場合、単純なGET通信だけではJavaScriptを使った後からコンテンツを取得し生成するようなWebページが、正しく取得できないはずです。

## 結論（再掲）

**WebViewで表示しているWebページのHTMLを取得しようとするのは、セキュリティ懸念からお勧めできません**