package com.madbot.d2gen

const val commands = "Available commands:\n\tgen [name] [sources_path] [gen_path]\n\t:names [protocol]"

fun main(args: Array<String>) {
    println("Type help for listing the commands...")

    do {
        print("> ")
        val cmd = readLine()?.split(' ')

        when (cmd?.first()) {
            "help" -> println(commands)
            "gen" -> {
                if (cmd.size >= 4) {
                    when (cmd[1].toLowerCase()) {
                        "protocol" -> ProtocolBuilder.build(cmd[2], cmd[3])
                        else -> println("Invalid generator name, type help")
                    }
                } else println("Missing params, type help")
            }
            else -> println(commands)
        }
    } while (cmd != null)
}