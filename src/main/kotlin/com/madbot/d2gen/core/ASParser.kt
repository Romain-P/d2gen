package com.madbot.d2gen.core

import com.madbot.d2gen.domain.ASClass
import com.madbot.d2gen.domain.ASField
import com.madbot.d2gen.domain.NativeType
import java.io.File

object ASParser {
    enum class Pattern(private val regex: Regex?, private val dynamicPattern: String? = null) {
        CONSTANT(Regex("""public static const (\w+):(?:int|uint) = (-?\d+);""")),
        SUPERCLASS(Regex("""public class .+ extends (\w+)(?: implements .+)?""")),
        IMPORT(null, """import ((?:.+\.)*%s);""");

        infix fun findMatchesIn(str: String) = regex?.findAll(str)
        infix fun findResultsIn(str: String) = regex?.find(str)?.groupValues

        fun findResults(str: String, vararg args: String) = Regex(dynamicPattern!!.format(*args)).find(str)?.groupValues
    }

    fun extractFileData(file: File, entity: ProtocolBuilder.ProtocolEntity): ASClass {
        val className = file.nameWithoutExtension
        val fileName = file.name
        val classPath = file.parentFile.path.removePrefix(ProtocolBuilder.sourcePath + File.separatorChar)
        val hardPath = file.parentFile.path
        val asContent = file.readUtf()

        return ASClass(className, fileName, entity, classPath, hardPath, asContent)
    }

    infix fun parseNumberConstantsOf(asClass: ASClass): ASClass {
        val matches = Pattern.CONSTANT findMatchesIn asClass.asContent

        val fields = matches?.map {
            val groups = it.groupValues
            val name = groups[1]
            val value = groups[2].toInt()

            name to ASField(name, NativeType.BYTE, value, true)
        } ?: return asClass

        asClass.fields.putAll(fields)
        return asClass
    }

    infix fun parseSuperclassOf(asClass: ASClass) {
        val groups = Pattern.SUPERCLASS findResultsIn asClass.asContent ?: return
        val superClass = groups[1]
        val path = parseImport(asClass, superClass)

        asClass.superClass = asClass.protocolEntity.store[superClass] ?: asClass.protocolEntity.buildOne("$path.as")
    }

    private fun parseImport(asClass: ASClass, className: String): String {
        val path = Pattern.IMPORT.findResults(asClass.asContent, className)?.get(1)?.fix(".") //if not found
                ?: "${asClass.packagePath}/$className".fix("/") //then same package

        asClass.imports[className] = path
        return path
    }
}