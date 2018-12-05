package com.madbot.d2gen.domain

import com.madbot.d2gen.core.FieldName

data class ASConstructor(
        val parameters: MutableMap<FieldName, ASField> = mutableMapOf(),
        val superParameters: MutableMap<FieldName, ASField> = mutableMapOf()
)