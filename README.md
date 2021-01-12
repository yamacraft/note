山田航空ネットワーク3rd
====================

![Build and Deploy](https://github.com/yamacraft/note/workflows/Build%20and%20Deploy/badge.svg)

https://yamacraft.github.io/note

## 記事の追加

```sh
$ hugo new <filename>.md
```

### 基本タグ

すべての記事は、必ずこのタグが１つ以上あるようにする。

- tech
  - 技術記事（特にコードのあるもの）、技術ブログとして抽出して適切なものにつける
- work
  - 技術記事とはちょっと外れるお仕事関連の記事
  - ヤマダ印に関するものはyamadajirushiタグを併記する
- diary
  - 日記
- poem
  - 個人的な主張でつけるやつ。やや技術寄り。
- yodan
  - 上記のどれとも違う趣味的なコラム記事につける

#### サブタグ

- dabun
  - あまり内容を精査していない半端な記事につける
- study
  - 勉強メモ
- yamadajirushi
  - ヤマダ印関連
- android, unity, CI, GitHub Actions,Circle CI
  - 技術系は大項目＋中項目を意識
- notice
  - お知らせ

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