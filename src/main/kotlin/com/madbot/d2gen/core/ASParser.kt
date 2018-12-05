package com.madbot.d2gen.core

import com.madbot.d2gen.domain.*
import java.io.File
import java.util.*

object ASParser {
    private const val SERIALIZE_METHOD = "serialize"
    private const val DESERIALIZE_METHOD = "deserialize"
    private const val PARAMETER_DELIMITER = ','
    private const val FIELD_EQUALIZER = '='
    private const val TYPE_DELIMITER = ':'
    private const val DEFINITION_INDEX = 0
    private const val NAME_INDEX = 0
    private const val TYPE_INDEX = 1

    enum class BodyParseState(val charValue: Char = '\u0000') {
        BEGIN,
        OPENED('{'),
        CLOSED('}')
    }

    enum class Pattern(private val regex: Regex? = null, private val dynamicPattern: String? = null) {
        CONSTANT(Regex("""public\sstatic\sconst\s(\w+):(?:int|uint)\s=\s(-?\d+);""")),
        SUPERCLASS(Regex("""public\sclass\s.+\sextends\s(\w+)(?: implements .+)?""")),
        INSTRUCTION_METHOD_CALL(Regex("""this.(\w+)\(.+\);""")),
        INSTRUCTION_SERIALIZATION(Regex("""(?:output|input).(?:write|read)(\w+)\((?:this.)(\w+)\);""")),
        SUPER_CONSTRUCTOR(Regex("""(?:super\.)?init\w+\((.+)\);""")),
        TYPE_VECTOR(Regex("""Vector\.<(\w+)>""")),
        IMPORT(dynamicPattern = """import\s((?:.+\.)*%s);"""),
        CONSTRUCTOR_HEADER(dynamicPattern = """(?:override)*\spublic\sfunction\sinit%s\((.*)\)\s:\s\w+"""),
        METHOD_HEADER(dynamicPattern = """(?:override)*\s(?:public|private)\sfunction\s%s\(.*\)\s:\s\w+""");

        infix fun findMatchesIn(str: String) = regex!!.findAll(str)
        infix fun findResultsIn(str: String) = regex!!.find(str)?.groupValues

        fun findMatch(str: String, vararg args: String) = Regex(dynamicPattern!!.format(*args)).find(str)
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

        val fields = matches.map {
            val groups = it.groupValues
            val name = groups[1]
            val value = groups[2].toInt()

            name to ASField(name, NativeType.BYTE, value, true)
        }

        asClass.fields.putAll(fields)
        return asClass
    }

    infix fun parseSuperclassOf(asClass: ASClass) {
        val groups = Pattern.SUPERCLASS findResultsIn asClass.asContent ?: return
        val superClass = groups[1]
        val path = parseImport(asClass, superClass)

        asClass.superClass = asClass.protocolEntity.store[superClass] ?: asClass.protocolEntity.buildOne("$path.as")
    }

    infix fun parseSerializersOf(asClass: ASClass) {
        parseMethod(asClass, SERIALIZE_METHOD)
        parseMethod(asClass, DESERIALIZE_METHOD)
    }

    infix fun parseConstructorOf(asClass: ASClass) {
        val match = Pattern.CONSTRUCTOR_HEADER.findMatch(asClass.asContent, asClass.name)
        val parameters = match?.groupValues?.get(1)

        if (match == null) {
            println("Info: no constructor found for ${asClass.classPath}")
            return
        }

        val headerIndex = match.range.last + 1

        parseSuperConstructor(asClass, headerIndex)
        parseConstructorParameters(asClass, parameters)
    }

    private fun parseSuperConstructor(asClass: ASClass, headerIndex: Int) {
        if (asClass.superClass == null) return

        val body = parseBody(asClass.asContent, headerIndex)
        val parameters = Pattern.SUPER_CONSTRUCTOR.findResultsIn(body)?.get(1)?.split(PARAMETER_DELIMITER) ?: return

        for (param in parameters) {
            //TODO
        }
    }

    private fun parseMethod(asClass: ASClass, name: String, quiet: Boolean = false): ASMethod? {
        val match = Pattern.METHOD_HEADER.findMatch(asClass.asContent, name)

        if (match == null) {
            println("Warning: method $name not found in ${asClass.classPath}")
            return null
        }

        val methodHeaderIndex = match.range.last
        val instructions = parseInstructions(asClass, name, methodHeaderIndex + 1)
        val method = ASMethod(name, instructions)

        if (!quiet)
            asClass.methods[name] = method
        return method
    }

    data class Test(val str: String) : Instruction

    private fun parseInstructions(asClass: ASClass, methodName: String, headerIndex: Int): List<Instruction> {
        val body = parseBody(asClass.asContent, headerIndex)
        val instructions = TreeMap<Index, Instruction>()

        resolveNestedMethodCalls(asClass, body, instructions)
        parseSerializationInstructions(asClass, body, methodName, instructions)

        instructions[0.1F] = Test(body)

        return instructions.map { (_, value) -> value }
    }

    private fun resolveNestedMethodCalls(asClass: ASClass, currentMethodBody: String, instructions: TreeMap<Index, Instruction>) {
        Pattern.INSTRUCTION_METHOD_CALL.findMatchesIn(currentMethodBody).forEach {
            var index = it.range.first.toFloat()
            val name = it.groupValues[1]
            val externalInstructions = parseMethod(asClass, name, true)!!.procedure

            instructions.putAll(externalInstructions.map { instruction -> index += 0.01F; index to instruction })
        }
    }

    private fun parseSerializationInstructions(asClass: ASClass, methodBody: String, methodName: String, instructions: TreeMap<Index, Instruction>) {
        Pattern.INSTRUCTION_SERIALIZATION.findMatchesIn(methodBody).forEach loop@{
            val index = it.range.first.toFloat()
            val type = it.groupValues[1]
            val fieldName = it.groupValues[2]
            val field = asClass.fields[fieldName]

            if (field == null) {
                println("Warning: field $fieldName not found in method $methodName of class ${asClass.classPath}")
                return@loop
            }

            field.type = retrieveTypeOf(asClass, type, true)
            instructions[index] = SerializationInstruction(field)
        }
    }

    private fun parseBody(str: String, startIndex: Int): String {
        var state = BodyParseState.BEGIN
        var nested = 0
        var i = 0
        var begin = startIndex

        while (state != BodyParseState.CLOSED) {
            if (str[startIndex + i] == BodyParseState.OPENED.charValue) {
                if (state == BodyParseState.BEGIN) {
                    begin += i + 1
                    state = BodyParseState.OPENED
                } else
                    ++nested
            } else if (str[startIndex + i] == BodyParseState.CLOSED.charValue) {
                if (nested > 0)
                    --nested
                else
                    state = BodyParseState.CLOSED
            }
            ++i
        }
        return str.substring(begin, startIndex + i - 2)
    }

    private fun parseConstructorParameters(asClass: ASClass, params: String?) {
        if (params == null || params.isBlank())
            return

        params.removeWhitespaces().split(PARAMETER_DELIMITER)
                .map { it.split(FIELD_EQUALIZER)[DEFINITION_INDEX].split(TYPE_DELIMITER) }.forEach {
                    val name = it[NAME_INDEX]
                    val typeName = it[TYPE_INDEX]
                    val type = retrieveTypeOf(asClass, typeName)
                    var genericType: Type? = null

                    if (type == NativeType.VECTOR) {
                        val genericTypeName = Pattern.TYPE_VECTOR.findResultsIn(typeName)!![1]
                        genericType = retrieveTypeOf(asClass, genericTypeName) //should not be vector again ;)
                    }

                    asClass.fields[name] = ASField(name = name, type = type, genericType = genericType)
                }
    }

    private fun retrieveTypeOf(asClass: ASClass, typeName: String, bySerializeType: Boolean = false): Type {
        var type: Type? = null

        if (bySerializeType)
            type = NativeType.getBySerializer(typeName)
        else if (NativeType.isNative(typeName))
            type = NativeType.UNDEFINED //it will be resolved later (by serialize type)

        if (type == null) {
            type = SerializableType(typeName)
            parseImport(asClass, typeName)
        }
        return type
    }

    private fun parseImport(asClass: ASClass, className: String): ClassPath {
        var path = asClass.imports[className]

        if (path != null)
            return path

        path = Pattern.IMPORT.findResults(asClass.asContent, className)?.get(1)?.fix(".") //if not found
                ?: "${asClass.packagePath}/$className".fix("/") //then same package

        asClass.imports[className] = path
        return path
    }
}