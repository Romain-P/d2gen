package com.madbot.d2gen.domain

data class ASField(
    val name: String,
    val type: Type,
    val value: Any? = null,
    val static: Boolean = false,
    val genericType: Type? = null,
    val sizeSerializationType: Type? = null
)