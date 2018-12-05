package com.madbot.d2gen.domain

enum class NativeType(val as3Serializer: String = "") : Type {
    UNDEFINED,
    BYTE("Byte"),
    BOOL("Boolean"),
    SHORT("Short"),
    INT("Int"),
    LONG("Long"),
    USHORT("UnsignedShort"),
    UINT("UnsignedInt"),
    ULONG("UnsignedLong"),
    VSHORT("VarShort"),
    VINT("VarInt"),
    VLONG("VarLong"),
    VUSHORT("VarUhShort"),
    VUINT("VarUhInt"),
    VULONG("VarUhLong"),
    FLOAT("Float"),
    DOUBLE("Double"),
    STRING("UTF"),
    VECTOR;

    companion object {
        private val asTypes = arrayOf("uint", "int", "String", "Number", "Boolean", "*")
        private val binds = values().map{it.as3Serializer to it}.toMap()

        fun getBySerializer(as3: String) = binds[as3] ?: if (as3.startsWith(VECTOR.as3Serializer)) VECTOR else null

        fun isNative(type: String) = asTypes.contains(type) || type.startsWith("Vector")
    }
}