package com.foxstoncold.splitlogger

internal actual object Helper {
    actual fun getFormattedDate(): String {
        return ""
    }

    actual fun extractFromStacktrace(stackTraceElement: Int, extractFunctionName: Boolean): Triple<String, String, Boolean> {
        return Triple("", "", false)
    }

    actual fun simplePrint(line: String) {
        println(line)
    }

    actual fun getPrintedStack(element: Int): String {
        return ""
    }
}