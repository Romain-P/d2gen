package com.madbot.d2gen.as3

import java.io.File

/**
 * @sourcePath  e.g     com/ankamagames/dofus/
 * @hardPath    e.g     ~/sources/scripts/com/ankamagames/dofus/
 * @classPath   e.g     com/ankamagames/dofus/ClassName.as
 *
 * AS Class loaded in memory
 */
data class ASClass(
        override val name: String,
        val fileName: String,
        val superClass: ASClass?,
        val fields: MutableMap<String, ASField>,
        val methods: MutableMap<String, ASMethod>,
        val sourcePath: String,
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
            sourcePath,
            hardPath,
            "$sourcePath${File.separatorChar}$fileName",
            content
    )
}