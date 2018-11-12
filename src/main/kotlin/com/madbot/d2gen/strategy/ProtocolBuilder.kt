package com.madbot.d2gen.strategy

import com.madbot.d2gen.as3.ASClass
import java.io.File

object ProtocolBuilder {
    var sourcePath: String = ""
    var genPath: String = ""
    var genExtension: String = ""

    enum class Entity(private val path: String, val template: String, val store: MutableMap<String, ASClass>) {
        ENUM("com.ankamagames.dofus.network.enums", "templates/enum.twig", mutableMapOf()),
        TYPE("com.ankamagames.dofus.network.types", "templates/type.twig", mutableMapOf()),
        MESSAGE("com.ankamagames.dofus.network.messages", "templates/message.twig", mutableMapOf());

        fun path() = sourcePath + File.separatorChar + path.replace('.', File.separatorChar)
        infix fun load(classes: List<ASClass>) = store.putAll(classes.map { it.classPath to it })
        infix fun render(classes: List<ASClass>) = Renderer.render(classes, genPath, template)
    }

    fun build(sourcePath: String, genPath: String, genExtension: String) {
        this.sourcePath = sourcePath
        this.genPath = genPath
        this.genExtension = genExtension

        buildEnums()
    }

    private fun buildEnums() {
        val generated = File(Entity.ENUM.path()).walk().filter {
            it.path.endsWith(".as")
        }.map {
            val baseClass = ASParser.loadFileToClassEager(it)
            ASParser.parseNumberConstant(baseClass)
        }.toList()

        Entity.ENUM load generated
        Entity.ENUM render generated
    }
}