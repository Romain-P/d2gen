package com.madbot.d2gen

object ProtocolBuilder {
    private var sourcePath: String = null!!
    private var genPath: String = null!!

    fun build(sourcePath: String, genPath: String) {
        this.sourcePath = sourcePath
        this.genPath = genPath
    }
}