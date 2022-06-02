---
title: "{{ replace .Name "-" " " | title }}"
date: {{ .Date }}
draft: false
categories: [""]
tags: [""]
---

<!--
    ** カテゴリー **
    - tech
        - techのみ
    - work
        - workのみ
    - diary
        - diary、poem、yodan含む

    * コラムレベルの場合は300〜600文字に抑える
    * 長文でも1段落300〜600文字で、それぞれ見出しを付けるとよい
    * images: ["/note/image/ogp.png"] 追加で本文前に画像を配置できる（OGPもこっち優先になる）
-->