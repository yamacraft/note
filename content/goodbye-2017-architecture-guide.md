---
title: "2017年に公式が推奨していたアーキテクチャの備忘録"
date: 2022-12-13T00:00:00+09:00
draft: false
categories: ["tech"]
tags: ["tech", "advent2022", "android", "architecture"]
---

※ 記事公開以降に一部修正と補足を追加しています。

[Android Advent Calendar 2022](https://qiita.com/advent-calendar/2022/android)の13日目の記事になります。

去年末、[Android公式のアーキテクチャガイドが刷新された](https://android-developers-jp.googleblog.com/2022/03/rebuilding-our-guide-to-app-architecture.html)のはご存じでしょうか？

Android公式がアーキテクチャガイドを用意したのは（記憶が間違っていなければ）2017年のGoogleIOからでした。
あのころに比べると、明らかに文量が増えています。
その変化に戸惑っている方はいるんじゃないでしょうか。

そして、当時のドキュメントをベースに作られたアプリも多くあることでしょう。
現在はその当時の資料が消えてしまったため、いずれ「このアプリはどういう設計思想だったんだろう」と思われてしまう可能性があります。

そんなわけで、割と自分の記憶だよりではありますが、当時どんな感じの内容が書かれていたのか備忘録を残すことにしました。

## 2017年のアーキテクチャはAACの利用が前提

2017年の公式推奨アーキテクチャは、AAC（Android Architecture Components）を使用して作ります。
~~また、DIを利用するためにHiltを利用します。~~

![2017年のアーキテクチャガイドで掲載されていた構成図](/note/image/goodbye-2017-architecture-guide/2017-aac-guide.png)

当時掲載されていた構成図は、このような形になっていました。

コードは基本的にView（Activity/Fragment）とViewModel（AAC ViewModel）、Repositoryに分割することで関心の分離を活用させています。
ViewModelからViewへデータを渡す時はLiveDataを使います。
これもAACが提供するコンポーネントのひとつです。

DataSourceで使っているRoomやRetrofit、SQLiteやWebServiceは、あくまでも一例です。
AACよりも利用の強制力はありません。

### （補足）Hiltの利用について

ここは指摘されて気がつきましたが、Hiltが登場したのは2020年にリリースされたDagger 2.28からだったので、自分の記憶違いでした。
じゃあDagger2の勘違いかと思いきや、念の為ちょっと調べてみたところ、Dagger2を使って書かれていたと思われるような痕跡も見当たりませんでした。
ですので、Hiltを使っていたという記載は、おそらく別のドキュメントの内容を混同していた可能性があります。

とはいえ、「関心の分離」を実装するのにDIは非常に役立ちますし、現状ほぼ必須の技術だと考えています。
ですので、以降の記事は最初の内容でそのまま掲載することにします。

ちなみに手動による依存関係の挿入方法の資料もあります。
また、ここには2017年版アーキテクチャガイドのなごりを見ることができます。

[手動による依存関係挿入  \|  Android デベロッパー  \|  Android Developers](https://developer.android.com/training/dependency-injection/manual?hl=ja)

### （補足）2017年版アーキテクチャはMVVMではないし、AAC ViewModelはViewModelではない

一見するとMVVMのような2017年版アーキテクチャですが、これをMVVMと呼ぶと面倒くさいことになる可能性があります。

というのも、たとえばView側が（Androidの機能としての）Data Bindingを厳密に利用しない限り、View側でデータ加工が安易にできてしまいます。
ViewModel側もAndroidのライフサイクルを意識した作りになってしまうため、完全な関心の分離ができているのかという疑問の声も聞いたことがあります。

そうした理由からか、安易にこれらをIT界隈の共通知識であるMVVMやViewModelとして呼称すると、思わぬ方向から「いや違う」と物言いが飛んでくることがあります。
あくまでもこれはAAC内にあるViewModelと言う名のコンポーネントで、MVVMではなくAACのアーキテクチャであると言っておくと、余計な議論から逃げることができます。

## コードサンプル

「特定のGitHub Organizationのリポジトリ一覧を取得する」機能の実装を例に、コード実装例を紹介します。
この実装では、AACとHilt以外にAPI通信をするためにRetrofitを利用します。

RepositoryからRetrofitを使ってAPIからデータを取得し加工、ViewModelで必要なLiveDataに渡してViewで画面に反映させるという流れです。

プロジェクトの全体はGitHubで公開しています。
https://github.com/yamacraft/Sample-Architecture2017-android

### Repositoryからデータを取得する

Hiltを使うため、Repositoryはインタフェースと実装クラスを作成し、モジュールクラスで定義づけを行います。

ちなみに実装クラスの名称に推奨されたルールはないようです。
GoogleのGitHubに上がっているリポジトリを見ても、実装が1つだけの場合でもDefaultRepositoryだったりRepositoryImplだったりと、まちまちです。

``` kotlin
// GithubRepository.kt
interface GithubRepository {
    suspend fun getOrganizationRepositories(organizationName: String): Result<List<String>>
}

// GithubRepositoryImpl.kt
class GithubRepositoryImpl @Inject constructor(
    private val githubService: GithubService
) : GithubRepository {
    override suspend fun getOrganizationRepositories(organizationName: String): Result<List<String>> {
        val response = githubService.getOrganizationRepositories(organizationName)
        if (response.isSuccessful) {
            val names = response.body()?.map {
                it.fullName
            } ?: listOf()
            return Result.success(names)
        }
        return Result.failure(Exception(response.message()))
    }
}

// RepositoryModule.kt
@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Singleton
    @Binds
    abstract fun bindGithubRepository(repository: GithubRepositoryImpl): GithubRepository
}
```

GithubServiceクラスの部分に関しては、今回のアーキテクチャガイドの話とは別のHilt（DI）側の話になるので省略します。

上記のRepositoryクラスでは、APIから受け取ったデータを加工して返しています。
これは特に公式ドキュメントでは記載していない（はず）部分で、自分の独自解釈でやっている内容です。
アプリ内で定義したデータクラスに加工することで、Repositoryがどうやってデータを取得しているのか、意識させないようにするという意図があります。

### ViewModelでLiveDataに送る

ViewModel以降はシンプルに、次にデータを渡すだけの作りで実装します。

``` kotlin
@HiltViewModel
class GithubViewModel @Inject constructor(
    private val githubRepository: GithubRepository
) : ViewModel() {

    private var _repositoriesLiveData = MutableLiveData<List<String>>()
    val repositoriesLiveData: LiveData<List<String>> = _repositoriesLiveData

    fun getRepositories(organizationName: String) {
        viewModelScope.launch {
            val result = githubRepository.getOrganizationRepositories(organizationName)
            if (result.isSuccess) {
                result.getOrNull()?.let {
                    _repositoriesLiveData.value = it
                }
            }
            // TODO: エラーハンドリングの対応
        }
    }
}
```

実際はエラーハンドリングやリトライ処理、複数のRepositoryを組み合わせたビジネスロジックをここで実装することになります。
それでも最終的にLiveDataへ必要なデータを流し込むことに変わりはありません。

### View（Activity）でLiveDataの内容を描写する

こちらも今回View側ではLiveDataのデータを監視し、その内容を描写するだけの実装となっています。
DataBindingを使った場合、layoutファイルだけで完結することもあります。

``` kotlin
@AndroidEntryPoint
class MainActivity : AppCompatActivity() {

    private val githubViewModel: GithubViewModel by viewModels()

    private lateinit var binding: ActivityMainBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        ActivityMainBinding.inflate(layoutInflater).apply {
            binding = this
            setContentView(binding.root)
        }

        // LiveDataが更新された時、その内容をテキストに表示
        githubViewModel.repositoriesLiveData.observe(this) {
            binding.mainText.text = it.toString()
        }
    }
}
```

このコードではそもそものAPIを呼び出す `githubViewModel.getRepositories()` を省略しています。
とりあえず `onCreate()` の最後にでも入れておけば、アプリ起動時に呼び出されます。

## 関心の分離とは何か

アーキテクチャガイドの原則として挙げられている「関心の分離」ですが、正直この言葉だけではどういう意味かわかりづらい気がします。

自分が教えられて一番わかりやすかったのが「どんな形でデータが送られて、送ったデータがどう使われるかを気にしなくてすむ」でした。

とはいえ、やはり言葉だけだと理解するのは難しいです。
ViewModelのUnitTestを使って説明します。

``` kotlin
@OptIn(ExperimentalCoroutinesApi::class)
class GithubViewModelTest {

    @Rule
    @JvmField
    var rule = InstantTaskExecutorRule()

    @MockK
    private lateinit var itemObserver: Observer<List<String>>

    @Before
    fun setUp() {
        MockKAnnotations.init(this)
    }

    @Test
    fun getOrganizationRepository_success() = runTest {
        val testDispatcher = UnconfinedTestDispatcher(testScheduler)
        Dispatchers.setMain(testDispatcher)
        every { itemObserver.onChanged(any()) } answers {}

        // Repositoryをmockして決めた値を返すように設定し、実行
        val repositories = listOf(
            "list1",
            "list2",
            "list3"
        )
        val repository = mockk<GithubRepository> {
            coEvery {
                getOrganizationRepositories(any())
            } returns Result.success(repositories)
        }
        val viewModel = GithubViewModel(repository)
        viewModel.repositoriesLiveData.observeForever(itemObserver)
        try {
            viewModel.getRepositories("example")
        } finally {
            Dispatchers.resetMain()
        }

        // 意図したRepositoryのメソッドを呼べているかと中身のチェック
        coVerifyOrder {
            repository.getOrganizationRepositories("example")
        }
        val items = requireNotNull(viewModel.repositoriesLiveData.value)
        assertThat(items.size, `is`(3))
        assertThat(items[0], `is`("list1"))
        assertThat(items[1], `is`("list2"))
        assertThat(items[2], `is`("list3"))
    }
}
```

LiveDataのUnitTestの都合上、コードが長くなってしまいましたが、見るべき部分はコメントの「Repositoryをmockして〜」の部分からです。

ViewModelが負うべき責務は、Repositoryから送られてきたデータをあるべきLiveDataに保存して、Viewに送ることです。
このテストでチェックしている内容は、その部分１点のみです。

実際の `GithubRepository.getOrganizationRepositories()` では、GitHubのAPIを叩いて取得したデータが返ってきます。
しかしこのUnitTestでは、その部分をmock化して固定の値を返すようにしています。
ですが、今回 `GithubViewModel.getRepositories()` がやるべきことは、Repositoryが返したきたデータをそのまま特定のLiveDataへ流し込むことです。
大事なのはそれだけであって、Repositoryがどうやって値を持ってきたかを気にする必要はありません。
どこから取得したかを気にするのは、Repository側の責務です。
それはRepositoryのテストで担保すべきものになります。

また一方でLiveDataに流し込んだ値がどうやって画面に表示されるかも、ここでは気にする必要がありません。
それはView側の仕事であり、Viewの責務になります。
これが関心の分離です。

## なぜAACとアーキテクチャガイドが生まれたのか

Android開発界隈では、長いことActivityやFragmentにコードを詰め込みすぎる「FatActivity（FatFragment）」が問題視されていました。
これの解決策として、Daggerを使ったDIの利用などが取り上げられたこともありましたが、根本的な解決には至りませんでした。
このあたりは2017年までのAndroidの設計に関する記事の内容が、MVPやMVVMなどバリエーション豊かだったことからもわかります。

こうした背景から、より明確な設計でアプリを作れるよう、AACの誕生とともにアーキテクチャガイドが作成されたようです。

{{< youtube FrteWKKVyzI >}}

## 個人的考察

### UseCaseは不要なのか

AACによるアーキテクチャの利用は、またたく間に広まりました。
一方でこのアーキテクチャはあまりにもシンプルすぎるためか、企業系のアプリではViewModelとRepositoryの間にUseCaseを挟むケースをいくつか見かけました。

- [Android版CODEアプリのアーキテクチャと使用ライブラリ \- リサーチ・アンド・イノベーション 開発者ブログ](https://rni-dev.hatenablog.com/entry/2021/08/30/121839)
- [新規でAndroidアプリを作る際に役立った考え方 \#famm年賀状2022 \#android \#kotlin \- Tech Blog](https://techblog.timers-inc.com/entry/new-androidapp)

私個人としての考えですが、UseCaseを挟む考えは有りだと思っています。

本来ならViewModelを適切な形に分割すればUseCaseは不要なのでしょうが、DataSourceやモデル側の都合でViewModelが分割できない場合もあります。
また当初のアーキテクチャガイドでは、小規模のアプリを前提にしているような印象もありました。
そうしたことからも、ビジネスロジック部分を明確にする意味でもUseCaseに切り分けるのは有効だと考えます。
あと上記のテストコードでもわかりますが、LiveDataのテストはちょっと面倒くさいです。
そういった意味でもUseCaseを挟むメリットはあります。

実際に現在の最新アーキテクチャガイドではドメインレイヤがOptionalとして追加され、UseCaseの実装が解説されてます。

[ドメインレイヤ  \|  Android デベロッパー  \|  Android Developers](https://developer.android.com/jetpack/guide/domain-layer?hl=ja)

### 最新アーキテクチャガイドは何が違うのか

結論から書くと、実はそんなに変化はありません。
基本的な「関心の分離」の原則はそのままに、AACを使うもよし、ほかを使うのもよしといった形で柔軟性を高くした内容になっています。
また、Optionalでドメインレイヤにも触れることで、ある程度規模のあるアプリの設計にも対応しようとしています。

アーキテクチャガイド誕生はAACの誕生でもありました。
Android公式としては、まずデベロッパー達に関心の分離を原則としたアプリ設計を身に着けてもらうのが最優先だったのでしょう。
実際にAACを使ったアーキテクチャの実装はシンプルでわかりやすく、一気に広がった印象があります。

一方このガイド誕生後、Kotlin自体にFlow（StateFlow）が実装されたり、ViewにJetpack Composeが実装されました。
関心の分離による設計思想が広まったことで、後はそれを何で使って実装するかはデベロッパー達に任せようという考えが反映されたのではないかと私は解釈しています。

## まとめ

2017年から2021年末まで掲載されていたアーキテクチャガイドはAACの利用を前提とした非常にシンプルな内容でした。

現在はAAC以外での実装方法や、規模の大きいアプリ開発も見越して改修した結果、少し抽象度も上がってしまっているように感じます。

とはいえ、基本的な設計思想は変わっていないと私は解釈しています。
今後AAC（特にLiveData周り）がすべてメンテナンスされ続けていくとも限りませんし、もう新版から公開が1年経っています。

早い内に新しいアーキテクチャガイドの内容に慣れておきたいですね。