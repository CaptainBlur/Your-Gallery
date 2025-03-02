package com.foxstoncold.splitlogger

internal enum class Level(tabulation: String, marker: String)  {
    SEVERE("", "🔴"),
    WARNING("", "🟡"),
    FINEST("", "🔵"),
    FINER("\t", "🔵"),
    FINE("\t\t", "🔵"),
    INFO("", "🟢")
}