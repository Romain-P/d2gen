package com.madbot.d2gen.domain

import com.madbot.d2gen.core.*
import java.io.File

/**
 * @packagePath  e.g     com/ankamagames/dofus/
 * @hardPath    e.g     ~/sources/scripts/com/ankamagames/dofus/
 * @classPath   e.g     com/ankamagames/dofus/ClassName
 *
 * AS Class loaded in memory
 */
data class ASClass(
        override val name: String,
        val fileName: String,
        var superClass: ASClass?,
        val constructor: ASConstructor,
        val protocolEntity: ProtocolBuilder.ProtocolEntity,
        val fields: MutableMap<FieldName, ASField>,
        val methods: MutableMap<MethodName, ASMethod>,
        val imports: MutableMap<ClassName, ClassPath>,
        val packagePath: String,
        val hardPath: String,
        val classPath: String,
        val asContent: String
) : Type {
    constructor(name: String, fileName: String, entity: ProtocolBuilder.ProtocolEntity, classPath: String, hardPath: String, content: String)
            : this
    (
            name,
            fileName,
            null,
            ASConstructor(),
            entity,
            mutableMapOf(),
            mutableMapOf(),
            mutableMapOf(),
            classPath,
            hardPath,
            "$classPath${File.separatorChar}$name",
            content
    )
}