---
title: "AndroidはCSVをサポートしていないので導入は避けようという資料"
date: 2022-12-02T00:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android", "advent2022"]
---

いまプライベートで作っているアプリでCSVインポート機能を実装しようとして、「これは安易に導入しちゃだめだな…」と感じたのでまとめた資料です。

## 公式SDK（API33時点）のCSV対応状況について

現時点で公式SDKはCSVファイルの読み込みに対応していません。

また、ストレージアクセスフレームワーク（SAF）を使ってファイルを読み込もうとした場合、typeを `text/csv` にするとCSVファイルがそもそも選択できません。
`text/*` にしてテキストファイルというくくりでSAFを呼び出す必要があります。

## AndroidのCSV読み込みライブラリについて

Android用に最適化されたCSVの読み込みライブラリはないようです。
opencsvやCommons CSVあたりが現実的な選択肢になりそうです。

- [opencsv](https://opencsv.sourceforge.net/)
- [Commons CSV – Home](https://commons.apache.org/proper/commons-csv/)

## 手動で読み込みを行いたい場合

上記に書いた、SAFでファイルを読み込んで、特定のClassにパースして返すまでのサンプルコードです。

``` kotlin
private val openCsvFileResult =
    registerForActivityResult(ActivityResultContracts.StartActivityForResult()) { result ->
        if (result.resultCode == Activity.RESULT_OK) {
            result.data?.data?.let {
                val stringBuilder = StringBuilder()
                contentResolver.openInputStream(it)?.use { inputStream ->
                    BufferedReader(InputStreamReader(inputStream)).use { reader ->
                        var line: String? = reader.readLine()
                        while (line != null) {
                            stringBuilder.append("$line\n")
                            line = reader.readLine()
                        }
                    }
                }
                convertCsvTextToItems(stringBuilder.toString())
            }
        }
    }

private fun openCsvFileForPicker() {
    val intent = Intent(Intent.ACTION_GET_CONTENT, null).apply {
        type = "text/*"
    }
    openCsvFileResult.launch(intent)
}

private fun convertCsvTextToItems(text: String): List<Item> {
    val textLines = text.split("\r\n", "\r", "\n")
    val items = textLines
        .map {
            val data = it.split(",")
            // TODO: Itemに変換
        }
    return items
}
```

ただ、このコードは問題点があります。

- 選択したファイルがCSVファイルであることを前提にしている
- 区切り文字がカンマ前提となっている
- 1行目からデータが書かれていることを前提としている

## そもそもCSVファイルの仕様はどうなっているのか

CSVファイルの仕様はRFC 4180で書かれています。

[RFC 4180: Common Format and MIME Type for Comma\-Separated Values \(CSV\) Files](https://www.rfc-editor.org/rfc/rfc4180)

RFC 4180では区切り文字がカンマであり、改行コードはCRLFであることが定義されていますが、ヘッダ行の存在や各項目をダブルクォーテーションで囲むかは自由とされています。

そのため、「最低限RFC 4180に対応したCSVのみ読み込みます」とした場合でも、これらの対応をコードに落とし込む必要があります。

## CSVがダメなら何を使うか

どうしてもテキストファイルでデータを読み込みたいなら、JSONファイルに変換したものを読み込めばよいのではないでしょうか。
JSONならKotlin SerializationやMoshiやGsonなどのAndroid対応ライブラリが用意されているので、読み込みはめちゃくちゃ楽になるはずです。

## 個人的結論

* 完全に決められた形式のCSVファイル（たとえば自社コンテンツのインポートファイルなど）だけを読み込ませるなら、まあ良し
  * この場合エラーハンドリングはちゃんとやっておくこと
* 何かしらのテキストデータを読み込ませる機能を使いたいなら、まだJSONファイルの方が個人的によい
* どうしても使いたいなら、opencsvやCommon CSVを使う