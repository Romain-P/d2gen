package com.madbot.d2gen.domain

import java.io.File

typealias ClassName = String
typealias FieldName = String
typealias MethodName = String
typealias ClassPath = String

/**
 * @packagePath  e.g     com/ankamagames/dofus/
 * @hardPath    e.g     ~/sources/scripts/com/ankamagames/dofus/
 * @classPath   e.g     com/ankamagames/dofus/ClassName.as
 *
 * AS Class loaded in memory
 */
data class ASClass(
        override val name: String,
        val fileName: String,
        var superClass: String?,
        val fields: MutableMap<FieldName, ASField>,
        val methods: MutableMap<MethodName, ASMethod>,
        val imports: MutableMap<ClassName, ClassPath>,
        val packagePath: String,
        val hardPath: String,
        val classPath: String,
        val asContent: String
) : Type {
    constructor(name: String, fileName: String, sourcePath: String, hardPath: String, content: String)
            : this
    (
            name,
            fileName,
            null,
            mutableMapOf(),
            mutableMapOf(),
            mutableMapOf(),
            sourcePath,
            hardPath,
            "$sourcePath${File.separatorChar}$fileName",
            content
    )
}