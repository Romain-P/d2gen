package com.madbot.d2gen

import com.madbot.d2gen.strategy.ProtocolBuilder

const val commands = "Available commands:\n\t" +
        "gen [name] [sources_path] [gen_path] [gen_ext]" +
        "\n\t:names [protocol]" +
        "\n\t:sources_path must be one level upper `com` (scripts)" +
        "\n\t:gen_path generated files directory" +
        "\n\t:gen_ext generated files extension e.g .kt"

fun main(args: Array<String>) {
    println("Type help for listing the commands...")

    do {
        print("> ")
        val cmd = readLine()?.split(' ')

        when (cmd?.first()) {
            "help" -> println(commands)
            "gen" -> {
                if (cmd.size >= 5) {
                    when (cmd[1].toLowerCase()) {
                        "protocol" -> ProtocolBuilder.build(cmd[2], cmd[3], cmd[4])
                        else -> println("Invalid generator name, type help")
                    }
                } else println("Missing params, type help")
            }
            else -> println(commands)
        }
    } while (cmd != null)
}