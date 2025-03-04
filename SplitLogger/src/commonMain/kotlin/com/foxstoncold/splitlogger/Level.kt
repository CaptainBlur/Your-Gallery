package com.foxstoncold.splitlogger

internal enum class Level(val tabulation: String, val marker: String)  {
    SEVERE("", "🔴"),
    WARNING("", "🟡"),
    FINE("", "🔵"),
    FINER("    ", "🔵"),
    FINEST("        ", "🔵"),
    INFO("", "🟢")
}