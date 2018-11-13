package com.madbot.d2gen.core

import com.madbot.d2gen.domain.ASClass
import java.io.File

object ProtocolBuilder {
    const val templatePath = "templates"
    const val templateConfig = "generated.extension"
    var sourcePath: String = ""
    var genPath: String = ""
    var genExtension: String = ""
    var templateProfile: String = ""

    enum class Entity(private val path: String, private val template: String, val store: MutableMap<String, ASClass>) {
        ENUM("com/ankamagames/dofus/network/enums", "enum.twig", mutableMapOf()),
        TYPE("com/ankamagames/dofus/network/types", "type.twig", mutableMapOf()),
        MESSAGE("com/ankamagames/dofus/network/messages", "message.twig", mutableMapOf());

        infix fun load(classes: List<ASClass>) = store.putAll(classes.map { it.classPath to it })
        infix fun render(classes: List<ASClass>) = Renderer.render(classes, genPath, genExtension, template())

        fun path() = "$sourcePath/$path".fix("/")
        fun template() = "$templatePath/$templateProfile/$template".fix("/")
    }

    fun build(sourcePath: String, genPath: String, templateProfile: String) {
        this.sourcePath = sourcePath
        this.genPath = genPath
        this.genExtension = File("$templatePath/$templateProfile/$templateConfig".fix("/")).readUtf().trim()
        this.templateProfile = templateProfile

        buildEnums()
    }

    private fun buildEnums() {
        val generated = File(Entity.ENUM.path()).walk().filter {
            it.path.endsWith(".as")
        }.map {
            val baseClass = ASParser.loadFileToClassEager(it)
            ASParser.parseNumberConstants(baseClass)
        }.toList()

        Entity.ENUM load generated
        Entity.ENUM render generated
    }
}