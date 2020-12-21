---
title: "FirebaseをCIでデプロイできるようにする（2020年版）"
date: 2020-12-21T00:00:00+09:00
draft: false
tags: ["tech", "firebase"]
---

この記事は、 [QiitaのFirebase Advent Calendar 2020](https://qiita.com/advent-calendar/2020/firebase)の21日目の記事になります。

また、Qiitaに投稿した[Firebaseプロジェクトのデプロイについて](https://qiita.com/yamacraft/items/d8b623cceb5c91692b65)の2020年版の記事になります。

## 前提条件

CIでデプロイを行う上で、次の条件を満たせるようにしています。

- 開発、ステージング、本番などにデプロイ先を切り替えられる
- 秘匿情報はリポジトリに組み込まない
- CIでデプロイ可能にする

## Firebase CLIについて

その名の通り、CLI上でFirebaseを利用するためのツールです。
本記事ではこのツールを使うことを前提としています。

Firebase CLI自体の詳細な解説は、公式のドキュメントを参照してください。

[Firebase CLI リファレンス](https://firebase.google.com/docs/cli/?hl=ja)

## デプロイ先を切り替えられるようにする

Firebaseで開発環境と本番環境を用意したい場合、２つのFirebaseプロジェクトを用意する必要があります。

作成したFirebaseプロジェクトの追加は `$firebase use --add` が用意されていますが、対象のプロジェクトの `.firebserc` を直接編集するのが手っ取り早くお勧めです。

``` json
// .firebaserc
{
  "projects": {
    "release": "project-id",
    "develop": "develop-project-id"
  }
}
```

デフォルトでFirebaseプロジェクトを設定した場合、 defaultが設定されているので意図的に削除します。
こうすることでデプロイ先を明示的に指定する必要が出てくるので、デプロイ先を間違える事故をある程度防げます。

``` sh
# develop環境へdeployを実施する
$ firebase use develop
$ firebase deploy
```

## CI用の認証トークンを用意する

CIでデプロイを行うためには、事前に対象のFirebaseプロジェクトへデプロイ可能な権限を持つユーザーの認証トークンを取得しなければいけません。
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
Firebase CLIで `--token 1//xxx...` を追加することで、ログインしていない環境でもFirebase CLIを使うことができます。

``` sh
# tokenを利用してdevelop環境でdeployを実施
$ firebase use develop --token 1/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
$ firebase deploy --token 1/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 作成したtokenを無効化する

生成したtokenは `firebase logout` によって無効化（ログアウト）できます。

``` sh
$ firebase logout --token 1//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
✔  Logged out token "1//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### 過去に発行した認証トークンの確認方法

2020年現在も、あいかわらず確認はできないようです。
ですので、発行したトークンの管理はきちんとしておきましょう。

### ユーザーと認証トークンの注意事項

ここで発行している認証トークンは、Firebaseプロジェクトに紐付いたものではなく、Googleアカウントに紐付いたトークンです。
ここで取得の際に選択したGoogleアカウントが、ほかのFirebaseプロジェクトにもdeploy可能な権限を持っていた場合、トークンが使い回せるということです。

たとえば、「開発（ステージング）環境用のトークンと本番環境のトークンを別にしてデプロイの事故を防ぎたい」といったケースが考えられます。
この場合は、それぞれの環境のFirebaseプロジェクトにしか権限のないGoogleアカウントを用意して、それぞれで認証トークンを発行しなければいけません。

また、発行時に使用したGoogleアカウントが削除された場合、当然トークンは利用できなくなります。

## Dockerでデプロイ環境を作る

個人的意見ですが、CI環境はいざというときにローカル環境でも動作したいので、Dockerfileで環境を構築します。
実際にCIで運用する場合、デプロイの前にビルドなどの作業も行うので、そうした環境を用意しておきたいためです。

``` dockerfile
# deploy.dockerfile
FROM node:12-buster-slim

RUN npm install -g firebase-tools

RUN mkdir app
WORKDIR app

CMD tail -f /dev/null
```

``` yml
# deploy-compose.yml
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
    command: /bin/sh -c "firebase use release --token $FIREBASE_TOKEN && firebase deploy --token=$FIREBASE_TOKEN"
```

これで、次のコマンドを実行することでreleaseへデプロイできます。

``` sh
$ export FIREBASE_TOKEN=1//xxxxxxxx....
$ docker-compose -f ./deploy-compose.yml up --build
```

## Circle CIでデプロイする

Circle CIでは、前述のコマンドを実行するymlを用意するだけです。
`FIREBASE_TOKEN` 自体はCircle CIの環境変数に登録しておきます。

``` yml
# .circleci/config.yml
# masterブランチの更新でreleaseにデプロイする
version: 2.1

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

v2.1であればOrbsでも実装可能ですが、 `firebase use *` も備えたものがパッと見当たらなかったので紹介しませんでした。

## GitHub Actionsでdeployする

GitHub Actionsの場合、[GitHub Action for Firebase](https://github.com/marketplace/actions/github-action-for-firebase)というworkflowを使うことで、とても簡単に実装できます。

GitHub Actionsの場合でも、環境変数 `FIREBASE_TOKEN` の設定が必要です。

``` yml
# .github/workflows/deploy.yml
# masterブランチの更新でreleaseにデプロイする
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
          fetch-depth: 0

      - name: Deploy to Firebase
        uses: w9jds/firebase-action@master
        with:
          args: deploy
        env:
          PROJECT_ID: release
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

以上です。