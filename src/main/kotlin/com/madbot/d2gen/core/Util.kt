package com.madbot.d2gen.core

import java.io.File
import java.nio.charset.Charset

typealias ClassName = String
typealias FieldName = String
typealias MethodName = String
typealias ClassPath = String

fun String.fix(separator: String, customSeparator: String = File.separator) = replace(separator, customSeparator)

fun String.withSeparator(separator: String) = replace(File.separator, separator)

fun File.readUtf() = inputStream().readBytes().toString(Charset.defaultCharset())