---
title: "CIでAndroidのSecretファイルをどう扱うか（2022年最新版）"
date: 2022-03-07T17:30:00+09:00
draft: false
categories: ["tech"]
tags: ["tech", "ci", "android", "GitHub Actions", "Circle CI"]
---

AndroidアプリのCIでアプリのデプロイ作業などを行いたい場合、Secret（秘匿情報）なファイルの扱いを避けることはできません。
たとえばリリース用のkeystoreファイルだったり、そのファイル関連のパスワード情報などです。

単純なテキストデータであれば、CIの環境変数（GitHub Actionsで言うならActions secrets）に保存するのが一般的です。
バイナリデータの場合はどう扱うべきでしょうか。

以前自分はバイナリデータであればOpenSSLで暗号化してリポジトリに保存、CIで複合するという手段を取っていました。
ただOpenSSLは何度か大きな脆弱性が発見されるようになったため、採用は避けるようにしました。
その後、特にCI上でアプリをデプロイする必要がなくなったこともあり、代替手段は特に考えていませんでした。

ですが最近、CI上でアプリをデプロイするしくみがまた欲しくなってきたので、あらためてこの対応策を考えることにしました。

考えるといっても、ゼロから考えたところでよい手段は見つかりません。
そこでエンジニアの集合知を利用するため、DroidKaigiの公式カンファレンスアプリのプロジェクトを参考とすることにしました。
調べたところ、2020年版、2021年版ともにシークレットファイルを[GnuPG](https://gnupg.org/)で暗号化したものをリポジトリに加えています。

- https://github.com/DroidKaigi/conference-app-2020/tree/master/.encrypted
- https://github.com/DroidKaigi/conference-app-2021/tree/main/android

2020年版では[複合シェルスクリプトの内容](https://github.com/DroidKaigi/conference-app-2020/blob/master/.github/android/decrypt-files.bash)から、リリース用のkeystoreとgoogle-services.jsonをzipでアーカイブしたものを暗号化しているようです。
一方2021年版では、ファイルごとに同じパスフレーズで暗号化を施しています。
また、keystoreのaliasやパスワード情報を、`signing.properties`に保存して、これも暗号化を施しています。
これは2020年版同様に、2021年版の[複合シェルスクリプトの内容](https://github.com/DroidKaigi/conference-app-2021/blob/main/scripts/decrypt_secrets.sh)から判断が可能です。
個人的な好き嫌いの話であれば、2021年版のやり方の方が私は好みです。

``` properties
# おそらくsigning.propertiesは、このような内容になっている
storePassword=XXXXXXXXXXX
keyAlias=XXXXXXXXXXXX
keyPassword=XXXXXXXXXXXX
```

``` gradle
// android/build.gradle
signingConfigs {
    // ...
    release {
        def signingPropertyFile = file('signing.properties')
        if (signingPropertyFile.exists()) {
            def fileInputStream = new FileInputStream(signingPropertyFile)
            def props = new Properties()
            props.load(fileInputStream)
            fileInputStream.close()

            storeFile file("release.keystore")
            storePassword props['storePassword']
            keyAlias props['keyAlias']
            keyPassword  props['keyPassword']
        }
    }
}
```

特にsigning.propertiesの読み込み方が好きです。
signingConfigsの中でプロパティファイルを読み込むことで、コントリビューターは開発に関係のないファイルを意識する必要がありません。

実は2020年版が公開された時点で、シークレットファイルの暗号化にGnuPGを使っていることは把握していました。
ただ、なぜこれを採用理由まで把握していなかったのですが、GitHubの方で採用されていたようですね。

[暗号化されたシークレット - GitHub Docs](https://docs.github.com/ja/actions/security-guides/encrypted-secrets)  

ちなみに小さなバイナリデータであれば、BASE64にしたものを環境変数に保存してもヨシとしているようです。

## サンプル

ということで、私的なメモ代わりにCircle CIとGitHub Actionsのサンプルを掲載します。

### 専用のプロパティファイルの作成

keystoreのAliasやパスワードは、専用のプロパティファイル（`signing.properties`）に記述します。

``` properties
storePassword=XXXXXXXXXXX
keyAlias=XXXXXXXXXXXX
keyPassword=XXXXXXXXXXXX
```

そして`signingConfigs.release`内でのみ、このプロパティファイルを読むようにします。
DroidKaigi2021のカンファレンスアプリとまったく同じです。

``` gradle
    signingConfigs {
        debug {
            // ...
        }
        release {
            def signingPropertyFile = file('signing.properties')
            if (signingPropertyFile.exists()) {
                def fileInputStream = new FileInputStream(signingPropertyFile)
                def props = new Properties()
                props.load(fileInputStream)
                fileInputStream.close()

                storeFile file("release.keystore")
                storePassword props['RELEASE_STORE_PASSWORD']
                keyAlias props['RELEASE_KEY_ALIAS']
                keyPassword props['RELEASE_KEY_PASSWORD']
            }
        }
    }
```

### 暗号化

そして必要なファイルを暗号化します。
なお暗号化と複合部分も、GitHubのドキュメントやDroidKaigi公式カンファレンスアプリで行われている内容そのままです。

``` sh
# 暗号化、パスフレーズの入力を求められる（30文字以上のパスフレーズを入力してます）
gpg --symmetric --cipher-algo AES256 -o "app/google-services.json.gpg" "app/google-services.json"
gpg --symmetric --cipher-algo AES256 -o "app/release.keystore.gpg" "app/release.keystore"
gpg --symmetric --cipher-algo AES256 -o "app/signing.properties.gpg" "app/signing.properties"
```

### 複合シェルスクリプトの用意

`scripts/decrypt_secrets.sh` を作成します。
CIではこのファイルを使って複合させます。

``` sh
#!/bin/sh

gpg --quiet --batch --yes --decrypt --passphrase="$SECRET_PASSPHRASE" \
  --output "app/google-services.json" "app/google-services.json.gpg"
gpg --quiet --batch --yes --decrypt --passphrase="$SECRET_PASSPHRASE" \
  --output "app/release.keystore" "app/release.keystore.gpg"
gpg --quiet --batch --yes --decrypt --passphrase="$SECRET_PASSPHRASE" \
  --output "app/signing.properties" "app/signing.properties.gpg"
```

### Circle CIでの設定

Environment Variablesで`SECRET_PASSPHRASE`を設定します。

``` yml
# Circle CI
version: 2.1

executors:
  android:
    working_directory: ~/android
    docker:
      - image: cimg/android:2022.01.1

jobs:
  build:
    executor: android
    steps:
      - checkout
      - run:
          name: install package （もしかしたら不要かも）
          command: sudo apt install -y gpg
      - run:
          name: decrypt secrets
          command: ./scripts/decrypt_secrets.sh
      - run:
          name: Build and Upload App Distribution
          command: ./gradlew --stacktrace assembleRelease
```

### GitHub Actionsでの設定

Actions secretsで`SECRET_PASSPHRASE`を設定します。
なお、GnuPGは最初からインストールされているようです。

``` yml
# masterブランチの更新で実行
name: On master branch

on:
  push:
    branches:
      - master
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          fetch-depth: 0
      - name: Setup decrypt secret files
        run: ./scripts/decrypt_secrets.sh
        env:
          SECRET_PASSPHRASE: ${{ secrets.SECRET_PASSPHRASE }}
      - name: run build
        run: ./gradlew --stacktrace assembleRelease
```

以上です。