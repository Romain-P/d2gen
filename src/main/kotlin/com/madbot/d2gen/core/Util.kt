package com.madbot.d2gen.core

import java.io.File
import java.nio.charset.Charset

typealias ClassName = String
typealias FieldName = String
typealias MethodName = String
typealias ClassPath = String
typealias Index = Float

fun String.fix(separator: String, customSeparator: String = File.separator) = replace(separator, customSeparator)

fun String.withSeparator(separator: String) = replace(File.separator, separator)

fun String.removeWhitespaces() = replace("""\s""".toRegex(), "")

//deadlock on jdk8 impl
fun <K, V> MutableMap<K, V>.putIfAbsentBis(key: K, value: V) {
    if (!containsKey(key))
        put(key, value)
}

fun File.readUtf() = inputStream().readBytes().toString(Charset.defaultCharset())