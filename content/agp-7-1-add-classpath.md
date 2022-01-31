---
title: "AGP7.1でclasspathを追加する"
date: 2022-01-31T17:49:09+09:00
draft: false
categories: ["tech"]
tags: ["tech", "android"]
---

先日、AGP（Android Gradle Plugin）7.1とAndroid Studio 2021.1.1（Bumblebee）がリリースされました。
これによって、Android StudioのBumblebeeでプロジェクトを新規作成すると、AGP 7.1のgradleファイルが作られるようになりました。

``` gradle
// settings.gradle
pluginManagement {
    repositories {
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "SampleProject"
include ':app'
```

``` gradle
// (root)build.gradle
// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id 'com.android.application' version '7.1.0' apply false
    id 'com.android.library' version '7.1.0' apply false
    id 'org.jetbrains.kotlin.android' version '1.6.10' apply false
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```

こんな感じで、settings.gradleとルートのbuild.gradleの内容が大きく変わりました。
以前あった `buildscript{}` がごっそり消えています。
HiltやFirebase Appdistribution-gradleなどのclasspathを取り込みたい場合は、どうやって書けばよいのでしょうか。

以前のようにルートのbuild.gradleの先頭に `buildscript{}` を記載するのが正解でした。

``` gradle
// (root)build.gradle
// Top-level build file where you can add configuration options common to all sub-projects/modules.
buildscript {
    ext.hilt_version = "2.38.1"
    repositories {
        gradlePluginPortal()
    }
    dependencies {
        classpath "com.google.dagger:hilt-android-gradle-plugin:$hilt_version"
        classpath 'com.google.gms:google-services:4.3.10'
        classpath 'com.google.android.gms:oss-licenses-plugin:0.10.4'
        classpath 'com.google.firebase:firebase-appdistribution-gradle:3.0.0'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:2.8.1'
    }
}

plugins {
    id 'com.android.application' version '7.1.0' apply false
    id 'com.android.library' version '7.1.0' apply false
    id 'org.jetbrains.kotlin.android' version '1.6.10' apply false
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
```

というお話でした。

以上です。