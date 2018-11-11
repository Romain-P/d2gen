package com.madbot.d2gen.as3

data class ASClass(
    override val name: String,
    val superClass: ASClass?,
    val fields: Map<String, ASField>,
    val methods: Map<String, ASMethod>,
    val path: String
) : Type