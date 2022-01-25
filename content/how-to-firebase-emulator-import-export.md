---
title: "Firebase local emulatorのfirestoreのデータインポート／エクスポートについてのメモ"
date: 2021-05-10T18:00:00+09:00
draft: false
categories: ["tech"]
tags: ["tech", "firebase"]
---

## 現在のFirebase local emulatorのデータをエクスポートする

Firebase local emulatorが起動中の状態で、 `firebase emulators:export` コマンドを呼び出すことで、データをエクスポートできます。

``` sh
$ firebase emulators:export export-path
```

`export-path` 先に、現在のemulatorの内容がエクスポートされます。
`--only firestore` のオプションを付けることで、firestoreのデータだけをエクスポートできます。

## 既存のFirebaseプロジェクトからデータをエクスポートする

既存のFirebaseプロジェクトのfirestoreのデータをエクスポートする方法もあります。
Firebase CLIとGoogle Cloud SDKとFirebase Storageを利用します。

詳細は次の記事に詳しく書かれています。
ここは日本語で手っ取り早く内容を知りたい人向けに書きます。

[How to Import Production Data From Cloud Firestore to the Local Emulator \| Firebase Developers](https://medium.com/firebase-developers/how-to-import-production-data-from-cloud-firestore-to-the-local-emulator-e82ae1c6ed8)

なお、エクスポートする対象のFirebaseプロジェクトが従量課金プランになっている必要があります。
無料プランの場合パーミッションエラーになります。

### firebaseとgcloudの認証とプロジェクト設定を行う

gcloudの認証ユーザーは、対象のFirebaseプロジェクトのオーナーアカウントを選択してください。
少なくとも編集者ユーザーでは、この後のStorageバックアップがパーミッションエラーで失敗します。

``` sh
$ firebase login
$ gcloud auth login

$ firebase use your-project-id
$ gcloud config set project your-project-id
```

`your-project-id` は、プロジェクト名ではなくプロジェクトIDなので注意してください。

### Storageにデータをエクスポートする

`gcloud firestore export` コマンドを使って、firestoreのデータをStorageにエクスポートします。

``` sh
$ gcloud firestore export gs://your-project-id.appspot.com/folder-name
```

成功すると、対象のFirebaseプロジェクトのStorageの `folder-name` 以下にデータがエクスポートされます。
`folder-name` のフォルダはなければ勝手に作ってくれるので安心してください。

### ローカルにStorageのデータをダウンロードする

`gsutil` を使って、Storageのデータをダウンロードします。
保存先のフォルダはあらかじめ用意しておいてください。
ダウンロードファイルは複数あるので、専用のexport先フォルダを用意しておくのが無難です。

``` sh
$ gsutil -m cp -r gs://your-project-id.appspot.com/folder-name export-path
```

## データをインポートする

emulator起動時に、 `--import` オプションを追加することで、データをインポートして立ち上げてくれます。

``` sh
$ firebase emulators:start --import ./folder-name
```

## エクスポートされたデータの加工について

エクスポートされたFirestoreはテキストファイルっぽいけど、そうではないバイナリファイルのような形式で出力されるので、テキストエディタでの加工はできません（注）。

<!-- textlint-disable ja-no-weak-phrase -->
そのためマスクデータを作成したい場合は、次の手段でやるのが無難かもしれません。

* 一度エクスポートしたデータをそのままemulatorで読み込む
* emulatorのコンソール画面から手動、またはAdmin SDKなどを利用したパッチで必要なデータをマスクする
* マスクし終わったfirestoreのデータをexportする

（注）下記の記事を読む限り、LevelDBログ形式というやつかもしれないので、何らかの手段で加工はできるかも。
<!-- textlint-enable ja-no-weak-phrase -->

https://firebase.google.com/docs/firestore/manage-data/export-import?hl=ja#export_format_and_metadata_files

以上です。
