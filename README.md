山田航空ネットワーク3rd
====================

![Build and Deploy](https://github.com/yamacraft/note/workflows/Build%20and%20Deploy/badge.svg)

https://yamacraft.github.io/note

## 記事の追加

```sh
$ hugo new <filename>.md
```

## ローカルサーバでのチェック

```sh
$ hugo server --ignoreCache -D
```

http://localhost:1313/note/ でサイトが見れるようになる。

下書きを表示したくない場合は、 `-D` を削除。

## deploy

hugoしてdocs以下を更新してからmasterにpushする。

## TODO

- hugoしてdocs以下の更新をCIにやらせたい
  - master更新したら自動でhugo走らせたものをpusuする的な感じで。