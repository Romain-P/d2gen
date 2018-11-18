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
            private val template: String
    ) {
        ENUM("com/ankamagames/dofus/network/enums", "enum.twig"),
        TYPE("com/ankamagames/dofus/network/types", "type.twig"),
        MESSAGE("com/ankamagames/dofus/network/messages", "message.twig");

        fun browseFiles(onEach: (ASClass) -> Unit) = File(path()).walk()
                .filter { it.path.endsWith(AS_EXTENSION) }
                .forEach { onEach(ASParser extractFileDataOf it) }g

        infix fun render(asClass: ASClass) = Renderer.render(asClass, genPath, genExtension, template())
        infix fun render(classes: List<ASClass>) = Renderer.render(classes, genPath, genExtension, template())

        fun path() = "$sourcePath/$path".fix("/")
        fun template() = "$TEMPLATE_PATH/$templateProfile/$template".fix("/")
    }

    fun build(sourcePath: String, genPath: String, templateProfile: String) {
        this.sourcePath = sourcePath
        this.genPath = genPath
        this.genExtension = File("$TEMPLATE_PATH/$templateProfile/$TEMPLATE_CONFIG".fix("/")).readUtf().trim()
        this.templateProfile = templateProfile

        buildEnums()
        buildTypes()
    }

    private fun buildEnums() {
        ProtocolEntity.ENUM.browseFiles {
            ASParser parseNumberConstantsOf it
            ProtocolEntity.ENUM render it
        }
    }

    private fun buildTypes() {
        ProtocolEntity.TYPE.browseFiles {
            ASParser parseSuperclassOf it
            ProtocolEntity.TYPE render it
        }
    }
}