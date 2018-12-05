package com.madbot.d2gen.domain

interface Instruction

data class SerializationInstruction(
        val serializedFieldName: ASField
): Instruction

data class BooleanWrappingInstruction(
        val boolName: String,
        val flagPosition: Int,
        val flagField: ASField
): Instruction

data class DeclareVariableInstruction(
        val field: ASField,
        val value: Any
): Instruction