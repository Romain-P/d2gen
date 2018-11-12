package com.madbot.d2gen.strategy

import com.madbot.d2gen.as3.ASClass
import com.madbot.d2gen.as3.ASField
import com.madbot.d2gen.as3.NativeType
import java.io.File
import java.nio.charset.Charset

object ASParser {
    enum class Pattern(private val regex: Regex) {
        CONSTANT(Regex("""public static const (.+):(?:int|uint) = (-?\d+);"""));

        infix fun findMatchesIn(str: String) = regex.findAll(str)
    }

    //load basic file properties. There is no performed content parsing in this function.
    fun loadFileToClassEager(file: File): ASClass {
        val className = file.nameWithoutExtension
        val fileName = file.name
        val sourcePath = file.parentFile.path.removePrefix(ProtocolBuilder.sourcePath + File.separatorChar)
        val hardPath = file.parentFile.path
        val asContent = file.inputStream().readBytes().toString(Charset.defaultCharset())

        return ASClass(className, fileName, sourcePath, hardPath, asContent)
    }

    fun parseNumberConstant(asClass: ASClass): ASClass {
        val matches = Pattern.CONSTANT findMatchesIn asClass.asContent

        val fields = matches.map {
            val groups = it.groupValues
            val name = groups[1]
            val value = groups[2].toInt()

            name to ASField(name, NativeType.BYTE, value, true)
        }

        asClass.fields.putAll(fields.toMap())
        return asClass
    }
}