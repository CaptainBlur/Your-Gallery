package com.foxstoncold.splitlogger

internal enum class Level(val tabulation: String, val marker: String)  {
    SEVERE("", "🔴"),
    WARNING("", "🟡"),
    FINEST("", "🔵"),
    FINER("    ", "🔵"),
    FINE("        ", "🔵"),
    INFO("", "🟢")
}