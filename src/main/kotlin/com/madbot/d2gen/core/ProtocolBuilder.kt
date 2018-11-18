package com.madbot.d2gen.core

import com.madbot.d2gen.domain.ASClass
import java.io.File

object ProtocolBuilder {
    const val TEMPLATE_PATH = "templates"
    const val AS_EXTENSION = ".as"
    const val TEMPLATE_CONFIG = "generated.extension"

    var sourcePath: String = ""
    var genPath: String = ""
    var genExtension: String = ""
    var templateProfile: String = ""

    enum class ProtocolEntity(
            private val path: String,
            private val template: String,
            val parsingRules: (ASClass) -> Unit,
            val store: MutableMap<ClassPath, ASClass> = mutableMapOf()
    ) {
        ENUM("com/ankamagames/dofus/network/enums", "enum.twig", ::buildEnum),
        TYPE("com/ankamagames/dofus/network/types", "type.twig", ::buildClass),
        MESSAGE("com/ankamagames/dofus/network/messages", "message.twig", ::buildClass);

        private fun builder(file: File): ASClass {
            val asClass = ASParser.extractFileData(file, this)
            parsingRules(asClass)
            render(asClass)
            store(asClass)
            return asClass
        }

        infix fun buildOne(classPath: String) = builder(File(path(classPath)))
        fun buildAll() = File(path()).walk()
                .filter { !store.containsKey(it.nameWithoutExtension) && it.path.endsWith(AS_EXTENSION) }
                .forEach { builder(it) }

        fun render(asClass: ASClass) = Renderer.render(asClass, genPath, genExtension, template())
        fun store(asClass: ASClass) = store.put(asClass.name, asClass)

        fun path() = "$sourcePath/$path".fix("/")
        fun path(filePath: String) = "$sourcePath/$filePath".fix("/")
        fun template() = "$TEMPLATE_PATH/$templateProfile/$template".fix("/")
    }

    fun build(sourcePath: String, genPath: String, templateProfile: String) {
        this.sourcePath = sourcePath
        this.genPath = genPath
        this.genExtension = File("$TEMPLATE_PATH/$templateProfile/$TEMPLATE_CONFIG".fix("/")).readUtf().trim()
        this.templateProfile = templateProfile

        ProtocolEntity.ENUM.buildAll()
        ProtocolEntity.TYPE.buildAll()
        ProtocolEntity.MESSAGE.buildAll()
    }

    private fun buildEnum(it: ASClass) {
        ASParser parseNumberConstantsOf it
    }

    private fun buildClass(it: ASClass) {
        ASParser parseSuperclassOf it
        ASParser parseNumberConstantsOf it //fetch protocolId
    }
}