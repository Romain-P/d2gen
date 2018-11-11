package com.madbot.d2gen.as3

data class ASField(
    val name: String,
    val type: Type,
    val genericType: Type,
    val sizeSerializationType: Type,
    val static: Boolean
)