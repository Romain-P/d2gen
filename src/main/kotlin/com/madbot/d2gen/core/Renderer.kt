package com.madbot.d2gen.core

import com.madbot.d2gen.domain.ASClass
import org.jtwig.JtwigModel
import org.jtwig.JtwigTemplate
import java.io.File

object Renderer {
    val templates = mutableMapOf<String, JtwigTemplate>()

    fun render(classes: List<ASClass>, genPath: String, genExt: String, templateFile: String) =
            classes.forEach { render(it, genPath, genExt, templateFile) }

    fun render(asClass: ASClass, genPath: String, genExt: String, templateFile: String) =
            render("${asClass.sourcePath}/${asClass.name}.$genExt".fix("/"), genPath, templateFile) { x -> x.with("x", asClass)}

    inline fun render(classPath: String, genPath: String, tplFile: String, binder: (model: JtwigModel) -> Unit) {
        templates.putIfAbsent(tplFile, JtwigTemplate.classpathTemplate(tplFile))
        val template = templates[tplFile]!!
        val model = JtwigModel.newModel()

        binder(model)
        val rendered = template.render(model)
        val generated = File(genPath + File.separatorChar + classPath)

        generated.parentFile.mkdirs()
        generated.writeText(rendered)
    }
}