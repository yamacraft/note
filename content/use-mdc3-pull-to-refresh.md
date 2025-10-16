---
title: "MDC3のPull to Refreshを使おうとして困った話（未完成）"
date: 2025-10-16T17:00:00+09:00
draft: false
author: ["yamacraft"]
categories: ["tech"]
tags: ["tech", "android", "mdc3", "compose"]
---

## この記事は未完成品ですが、完成予定はありません

この記事は、約1年と半年ほど前（24年春ごろ）に途中まで書いて放置したものを、とりあえず公開できる程度まで体裁を整えたものになります。

そのため、肝心なオチ（解決策）については適当な記述になっています。
Material Designは現在Material3 Expressiveが発表されたこともあり、似たような悩みを持っている人は少ないと思っています。
とはいえ、いちおう途中まで書いたものを捨てるのももったいないので、備忘録として公開するに至りました。

## 前置き

Material Design Component（MDC）3は長いことPull to refreshコンポーネントが実装されておらず、これを使いたい場合、MDC2を並行利用する必要がありました。

ですが、[Compose Material 3 Version 1.2.0](https://developer.android.com/jetpack/androidx/releases/compose-material3#1.2.0)から、正式にPull to refresh関連のコンポーネントが実装されました。
ComposeBomだと、 `2024.02.00` から利用が可能です。

## 導入方法

比較として、MDC2での実装方法も記載します。

### MDC2のPull to refresh

`PullRefreshState` を生成し、Pull to refreshの対象となるレイアウトコンポーネントの `Modifier.pullRefresh()` にセットします。
そしてPull to refreshの表示を担う `PullRefreshIndicator` を、コンテンツに重ねるように配置します。

```kotlin
val pullRefreshState = rememberPullRefreshState(
    refreshing = state.progress,
    onRefresh = { /* TODO */ },
)

Box(
    modifier = modifier
        .fillMaxSize()
        .pullRefresh(state = pullRefreshState),
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        state = rememberLazyListState(),
    ) {
        // ...
    }

    PullRefreshIndicator(
        refreshing = state.progress,
        state = pullRefreshState,
        modifier = Modifier.align(alignment = Alignment.TopCenter),
    )
}
```

![Pull to refresh(MDC2)](/note/image/use-mdc3-pull-to-refresh/pr2.gif)

### MDC3のPull to refresh

大まかな違いはStateと表示に関するIndicator周りが変わりました。
`PullRefresh` はMDC2、 `PullToRefresh` はMDC3と覚えてよさそうです。

```kotlin
val pullToRefreshState = rememberPullToRefreshState()
if (pullToRefreshState.isRefreshing) {
    // ここは引っ張りきった時の動作
    LaunchedEffect(key1 = Unit) {
        delay(1000 * 3)
        pullToRefreshState.endRefresh()
    }
}

Box(
    modifier = modifier
        .fillMaxSize()
        .nestedScroll(connection = pullToRefreshState.nestedScrollConnection),
) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        state = rememberLazyListState(),
    ) {
        // ...
    }

    PullToRefreshContainer(
        state = pullToRefreshState,
        modifier = Modifier.align(alignment = Alignment.TopCenter)
    )
}
```

![Pull to refresh(MDC3, Container)](/note/image/use-mdc3-pull-to-refresh/pr3_container.gif)

インジケータは上記のほかに `LinearProgressIndicator` と `CircularProgressIndicator` が追加されました。
`PullToRefreshContainer` はMDC2に近い見た目のインジケータとなっています。
そして残りの２つは `*ProgressIndicator` をPull to refreshに対応させたようなコンポーネントとなっています。

![Pull to refresh(MDC3, CircularIndicator)](/note/image/use-mdc3-pull-to-refresh/pr3_indicator.gif)

MDC2との実装の大きな違いは、StateとIndicatorそれぞれにリフレッシュ中を設定するパラメータが消えたことでしょうか。
これによって、Pull to refreshがリフレッシュ中であることの状態を、こちらで実装する必要がなくなりました。
一方で、これによって悩みどころが発生してしまいました（後述）。

## MDC2版からMDC3版へ移行させる時の懸念点

上記のMDC3版のコードでは、UIレイヤ上でPull to refreshを閉じる処理までを実装しています（`if (pullToRefreshState.isRefreshing){}` 部分）。
しかし実際にアプリを作る時、他の操作でViewModel側の処理を直接呼びだすケースも存在するはずです。
その場合は、その操作と処理に合わせてPull to refreshのUIを表示したり非表示にしたりしたいはずです。

MDC2版では `refreshing: Boolean` の値を変えることで表示を制御できるので、だいたい次のようなUiStateを使って表示の制御が可能でした。

```kotlin
// UiState
data class UiState(
    val data: List<String> = emptyList(),
    val progress: Boolean = false,
)

// ViewModel内での利用例
fun onRefresh() {
    viewModelScope.launch {
        uiState = uiState.copy(progress = true)
        delay(3 * 1000)
        uiState = uiState.copy(
            data = List(items) { "Item $it" },
            progress = false
        )
    }
}
```

しかしMDC3版では現在、`PullToRefreshState` やIndicator内には、 `refreshing` に該当するようなパラメータがありません。
表示の切り替えを行うメソッドも、 `startRefresh()` と `endRefresh()` の2種類だけです。
そしてこれらは `isRefreshing` の値も書き換えてしまいます。
`isRefreshing` はPull to refreshを引っ張りきったかどうかのトリガ判定に使うパラメータでもあるので、安易に変更できません。

```kotlin
if (pullToRefreshState.isRefreshing) {
    LaunchedEffect(key1 = Unit) {
        // 処理の中でstate.progressが更新される
        onRefresh()
    }
}

// 例えば以下の実装をやると、onRefresh()が無限に呼ばれてしまう
if (state.progress) {
    pullToRefreshState.startRefresh()
} else {
    pullToRefreshState.endRefresh()
}
```

さらにUiStateでUI状態を管理することを考えると、必要なタイミング以外で `endRefresh()` を呼びたくありません。
MDC2版に合わせたUiStateをそのままに、どうにか実装できないかと考えた結果、次のようになりました。

```kotlin
// 前回のprogress状態を保持
val previousProgress = remember { mutableStateOf(state.progress) }
val pullToRefreshState = rememberPullToRefreshState()

if (pullToRefreshState.isRefreshing) {
    LaunchedEffect(key1 = Unit) {
        onRefresh()
    }

    LaunchedEffect(key1 = state.progress) {
        if(previousProgress.value && state.progress.not()) {
            if (state.progress.not()) {
                pullToRefreshState.endRefresh()
            }
        }
        previousProgress.value = state.progress
    }
}
```

ややこしいですね。
しかもこれは、閉じる場合のみの処理になります。
`refreshing` に該当するパラメータが欲しい…。

## 初期ロードの表示どうする問題

Pull to refreshを閉じる方はどうにかなりました。
ですが最大の難所は、ユーザ主導ではない更新（初期ロードなど）におけるPull to refreshのprogress表示です。

先ほども書いたように、MDC3版のPull to refreshの表示制御は `startRefresh()` しかなく、これを実行すると `isRefreshing` の値まで変わってしまいます。

結論だけで書くと、この記事を執筆時点では `PullToRefresh` ではどうにもなりませんでした。
一方で `*ProgressIndicator` は元がProgressIndicatorであるため、こちらはUIそのものを表示／非表示する形で対応できるようです。

*【コード／画像省略】*

## 追加された新コンポーネント

…という悩ましい問題があったのですが、その後バージョン1.3.0で `PullToRefreshBox` という新たなコンポーネントが追加されました。
こちらには `isRefreshing` というパラメータが追加されており、更新状況を設定できるようになりました。

* [developer.android.com - PullToRefreshBox](https://developer.android.com/reference/kotlin/androidx/compose/material3/pulltorefresh/package-summary#PullToRefreshBox(kotlin.Boolean,kotlin.Function0,androidx.compose.ui.Modifier,androidx.compose.material3.pulltorefresh.PullToRefreshState,androidx.compose.ui.Alignment,kotlin.Function1,kotlin.Function1))
* [下方向にスワイプして更新  \|  Jetpack Compose  \|  Android Developers](https://developer.android.com/develop/ui/compose/components/pull-to-refresh?hl=ja)

というわけで、MDC3でPull to Refreshを実装する時は `PullToRefreshBox` を使いましょう。

（補足）この記事は、この `PullToRefreshBox` の調査前に記載して放置していました。本当に解決できるかどうかは不明です。