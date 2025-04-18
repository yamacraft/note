---
title: "作業記録（2021年1月25日）"
date: 2021-01-25T18:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["work"]
tags: ["work", "android"]
---

年明けから決算関連で細かい事務作業が大量発生していましたが、ようやく一段落ついたので開発関係の作業を本格的に再開。

まずはAAびゅーわとD.I.C.のAndroid Gradleプラグインをアップデート（AS4.1.2対応）して、ついでにライブラリもアップデートして動作確認。

この２つのアプリは基本的に自分の技術調査・実践を兼ねて開発をしています。
ただどちらも機能的にクセのあるアプリですので、それぞれ次の指針で今年は進めていくように考えています。

- AAびゅーわはView（UI）周りを中心に改修
- D.I.C.は設計周りを中心に改修

まずはD.I.C.をちゃんと[公式の推奨アーキテクチャ](https://developer.android.com/jetpack/guide?hl=ja#recommended-app-arch)に合わせて改修しつつ、ついでにDagger Hiltも導入しようと考えています。

といっても、Dagger Hiltはまだちゃんと触ったことがなかったので、まずは実験用のサンプルプロジェクトを作成。
とりあえずGitHubのAPIにアクセスしてデータを返すまでの流れを作ってからDagger HiltでDI対応をしたかったのですが、その前段階の実装途中で本日は時間切れ。

こういった実装確認をするための簡単な実装のひな型は、ちゃんと以前から用意すべきでした。反省。