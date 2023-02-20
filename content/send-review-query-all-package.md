---
title: "D.I.C.のQUERY_ALL_PACKAGES利用許可申請の対応メモ"
date: 2022-07-18T17:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android", "Google Play"]
---

ヤマグロでリリースしている[D.I.C.](https://play.google.com/store/apps/details?id=jp.yamaglo.dic)には、端末がインストールしているアプリの一覧を表示し、各アプリのtargetSdkVersionを確認できる機能があります。

この機能を実装するために、アプリでは `PackageManager.queryIntentActivities()` を使っています。

``` kotlin
val packageManager = getApplication<Application>().packageManager

val intent = Intent(Intent.ACTION_MAIN).apply {
    addCategory(Intent.CATEGORY_LAUNCHER)
}

// 該当するActivity（アプリ）の一覧を取得
val activities = packageManager.queryIntentActivities(intent, 0)
```

このAPIを使うためには、 `QUERY_ALL_PACKAGES` 権限の利用が必要です。
設定しなかった場合APIがExceptionを吐くことはありませんが、空の情報が返却されます。

この権限の利用は現在Googleが厳しくチェックしていて、既存のアプリで利用していた場合、利用内容を申告して審査が必要になっています。

[プレビュー: パッケージ（アプリ）の広範な一覧取得（QUERY\_ALL\_PACKAGES）権限の使用 \- Play Console ヘルプ](https://support.google.com/googleplay/android-developer/answer/10158779?hl=ja)

D.I.C.もそうした理由で申告が必要となってしまいました。
使っている機能は別に削除しても問題ないのですが、せっかく新たなノウハウを得られる機会ですので、対応することにしました。

以下はその作業メモです。

## 機密情報にかかわる権限とAPIの申告

権限の申告はGoogle Playコンソールから該当のアプリを選択し、メニューの「アプリのコンテンツ」から先にある、『機密情報にかかわる権限とAPI』の欄から申請が可能です。

![機密情報にかかわる権限とAPI](/note/image/send-review-query-all-package/review1.png)

申告内容はシンプルで、利用する機能の説明と用途の種別にチェックを入れるだけです。
また、該当部分の機能を動画で見せるための項目（YouTubeのアドレスもしくはMP4のダウンロードリンクを記載）も用意されています。

### 実際の申告内容

D.I.C.では次のように記載しました。

>・端末にインストールされたアプリの一覧と情報を表示
>
>インストールアプリ一覧画面を使うことで、ユーザーが自分の端末にインストールされているアプリのtargetVersionを調べることができます。
>これはアプリ開発者のユーザーのために作られた機能で、ここで取得した情報をサーバにアップロードすることはありません。

![申告内容](/note/image/send-review-query-all-package/review2.png)

用途はアプリの一覧を見るだけの機能ですので、「アプリの機能」だけにチェックを入れています。

### 申告用の動画の用意

D.I.C.におけるQUERY_ALL_PACKAGES権限の利用用途はちょっと特殊だと思ったので、動画の方も用意しました。
これはAndroid StudioのScreen Recordを使って録画した動画を、そのままYouTubeにアップロードしただけです。
いちおうffmpegを使って、Webmからmp4へ変換しています。

``` sh
# ffmpegによるmp4への変換
$ ffmpeg -i device-2022-07-18-170608.webm  -r 60 device-2022-07-18-170608.mp4
```

![申告に使った動画のサンプル（GIF）](/note/image/send-review-query-all-package/install_apps.gif)

*参考画像（実際にアップロードした動画には、あまり見せたくない情報が含まれていたのでサンプルで撮り直したものになります）*

### 申告の完了（審査の終了）

申告するとアプリのアップデート同様、『機密情報にかかわる権限とAPI』のステータスが「審査中」になりました。
7月頭に申告して、18日現在「送信しました」に変わっているので、チェックは無事通ったという認識でいます。

以上です。