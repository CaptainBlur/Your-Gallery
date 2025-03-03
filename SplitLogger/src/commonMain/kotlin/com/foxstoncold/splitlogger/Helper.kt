package com.foxstoncold.splitlogger

internal expect object Helper {
    fun getFormattedDate(): String
    fun extractFromStacktrace(stackTraceElement: Int, extractFunctionName: Boolean = false): Array<String>
    fun simplePrint(line: String)
    fun getPrintedStack(element: Int = 0): String
}