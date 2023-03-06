---
title: "FlutterでOpenAI APIを利用するときの備忘録"
date: 2023-03-06T17:30:00+09:00
draft: false
categories: ["tech"]
tags: ["tech", "flutter", "openai"]
---

表題の通りです。

自分はFlutterの経験がたいへんに浅いので、その点をご留意ください。

## 利用方法

Flutterの場合、[OpenAIを利用するためのpackageが配布されているようですが](https://pub.dev/packages/openai_client)、公式から提供されているものではありません。
ですので、httpパッケージを使っての実装することにしました。

なお、ここでは下準備であるOpenAIのアカウント登録やAPI Keyの取得は省略します。

* [Overview \- OpenAI API](https://platform.openai.com/overview)

## GPT-3へのアクセス

受け取ったメッセージを送り、返答を返すメソッドとして記述しています。

* [https://platform.openai.com/docs/api-reference/completions](https://platform.openai.com/docs/api-reference/completions)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> requestOpenAiApi(String message) async {
    Uri url = Uri.parse('https://api.openai.com/v1/completions');
    Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer XXXXXXXXXX',
    };
    String body = json.encode({
        'model': 'text-davinci-003',
        'prompt': message,
    });

    var answer = "";
    try {
        var response = await http.post(url, headers: headers, body: body);

        if (response.statusCode != 200) {
            // TODO: エラーハンドリング
        } else {
            const jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
            answer = jsonResponse['choices'][0]['text'];
        }
    } catch (e) {
        logger.e(e);
    }
    return answer;
}
```

## gpt-3.5 turboへのアクセス

GPT-3との主な違いは次の通りです。

* エンドポイントの変更（`/v1/completions` -> `/v1/chat/completions`）
* 送るデータがStringから、Json配列へ変更
* レスポンスの構造も少し変更あり（主に返答部分）

Json配列を使う関係上、そのためのデータClassが（おそらく）必要です。

* [https://platform.openai.com/docs/api-reference/chat](https://platform.openai.com/docs/api-reference/chat)

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> requestOpenAiApi(String message) async {
    Uri url = Uri.parse('https://api.openai.com/v1/chat/completions');
    Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer XXXXXXXXXX',
    };
    List<ChatGptMessage> messages = [
        ChatGptMessage("user", message),
    ];
    String body = json.encode({
        'model': 'gpt-3.5-turbo',
        'messages': messages,
    });

    var answer = "";
    try {
        var response = await http.post(url, headers: headers, body: body);

        if (response.statusCode != 200) {
            // TODO: エラーハンドリング
        } else {
        const jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        answer = jsonResponse['choices'][0]['message']['content'];
        }
    } catch (e) {
        logger.e(e);
    }

    return answer;
}

class ChatGptMessage {
    String role;
    String content;

    ChatGptMessage(this.role, this.content);

    Map toJson() => {
        'role': role,
        'content': content,
    };
}
```

## メモ

gpt-3.5 turboはいろいろと拡張性が高いと思っていましたが、ちょっとsystemや会話履歴を混ぜるとすぐにmaxTokenの4000をオーバーしてしまいました。

履歴ありきのAPIだと考えているので、これがほとんど送れないとあまりこのモデルの真価が発揮できません。
とはいえ、これは自分の送り方の問題という可能性があります。
もう少し、いろいろと試してみる予定です。