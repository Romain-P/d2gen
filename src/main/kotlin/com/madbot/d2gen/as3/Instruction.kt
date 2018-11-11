package com.madbot.d2gen.as3

interface Instruction

data class SerializationInstruction(
        val field: ASField
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