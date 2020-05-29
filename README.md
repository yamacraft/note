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
$ hugo server --ignoreCache --minify -D
```

http://localhost:1313/note/ でサイトが見れるようになる。

下書きを表示したくない場合は、 `-D` を削除。

## deploy

masterが更新されれば、GitHub Actionsの方でサイト生成からアップロードまで行います。

生成されたサイトのデータは、

- `gh-pages` ブランチ全体
- Actionsの各結果のartifact

のどちらかで確認が可能。