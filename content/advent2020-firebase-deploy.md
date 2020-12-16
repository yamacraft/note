---
title: "FirebaseをCIでDeployできるようにする（2020年版）"
date: 2020-12-16T00:00:00+09:00
draft: false
tags: ["tech"]
---

この記事は、 [QiitaのFirebase Advent Calendar 2020](https://qiita.com/advent-calendar/2020/firebase)の21日目の記事になります。

また、Qiitaに投稿した[Firebaseプロジェクトのデプロイについて](https://qiita.com/yamacraft/items/d8b623cceb5c91692b65)の2020年版の記事になります。

``` json
{
  "projects": {
    "release": "project-id",
    "develop": "develop-project-id"
  }
}
```

``` sh
# develop環境へdeployを実施する
$ firebase use develop
$ firebase deploy
```

CIでdeployを行うためには、事前に対象のFirebaseプロジェクトにdeploy可能な権限を持つユーザーの認証トークンを取得しなければいけません。
あらかじめ対象のユーザーにログイン可能なローカルマシンなどで `firebase login:ci` を行い、トークンを取得してください。

``` sh
$ firebase login:ci

Visit this URL on this device to log in:
https://accounts.google.com/o/oauth2/auth?client_id=xxxxxxxxx.apps.googleusercontent.com&...

Waiting for authentication...

✔  Success! Use this token to login on a CI server:

1//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

Example: firebase deploy --token "$FIREBASE_TOKEN"
```

ここで表示されている、 `1//xxxxx...` が、認証トークンです。


生成したtokenは `firebase logout` によって無効化（ログアウト）できます。

``` sh
$ firebase logout --token 1//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
✔  Logged out token "1//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### ユーザーと認証トークンの注意事項

ここで発行している認証トークンは、Firebaseプロジェクトに紐付いたものではなく、Googleアカウントに紐付いたトークンです。
ここで取得の際に選択したGoogleアカウントがほかのFirebaseプロジェクトにもdeploy可能な権限を持っていた場合、トークンが使い回せるということです。

たとえば、「開発（ステージング）環境用のトークンと本番環境のトークンを別にしてdeployの事故を防ぎたい」といったケースが考えられます。
この場合は、それぞれの環境のFirebaseプロジェクトにしか権限のないGoogleアカウントを用意して、それぞれで認証トークンを発行しなければいけません。

また、発行時に使用したGoogleアカウントが削除された場合、当然トークンは利用できなくなります。

### 過去に発行した認証トークンの確認方法

2020年現在も、あいかわらず確認はできないようです。
ですので、発行したトークンの管理はきちんとしておきましょう。


``` dockerfile
FROM node:12.17.0-buster-slim

RUN npm install -g firebase-tools

RUN mkdir app
WORKDIR app

CMD tail -f /dev/null
```

``` yml
version: '2'
services:
  deploy:
    environment:
      - FIREBASE_TOKEN
    build:
      context: ./
      dockerfile: deploy.dockerfile
    volumes:
      - ./:/app
    command: /bin/sh -c "firebase deploy --token=$FIREBASE_TOKEN"
```

``` yml
version: 2.1

orbs:
  slack: circleci/slack@4.0.2

jobs:
  deploy:
    working_directory: ~/sample
    machine: true
    steps:
      - checkout
      - run:
          name: deploy
          command: docker-compose -f ./deploy-compose.yml up --build
workflows:
  version: 2
  deploy_workflow:
    jobs:
      - deploy:
          filters:
            branches:
              only: master
```

### GitHub Actionsでdeployする

``` yml
name: Deploy

on:
  push:
    branches:
      - master

jobs:
  deploy:
    runs-on: ubuntu-18.04
    steps:
      - uses: actions/checkout@v2
        with:
          submodules: true
          fetch-depth: 0

      - name: Deploy to Firebase
        uses: w9jds/firebase-action@master
        with:
          args: deploy
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```