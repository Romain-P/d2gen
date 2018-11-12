package com.madbot.d2gen.domain

enum class NativeType(val as3Serializer: String) : Type {
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
    VECTOR("Vector");

    companion object {
        private val binds = values().map{it.as3Serializer to it}.toMap()

        fun get(as3: String) = binds[as3]
    }
}