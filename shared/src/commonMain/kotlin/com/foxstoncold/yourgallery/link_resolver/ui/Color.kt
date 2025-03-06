package com.foxstoncold.yourgallery.link_resolver.ui

import com.foxstoncold.yourgallery.link_resolver.data_parser.Native

/*
Common class representing hex colors for both platforms
 */
data class Color(
    private val light: String,
    private val dark: String,
){
    val hex: String
        get() = if (!Native.themeMode) light else dark

    val rgb: Triple<Double, Double, Double>
        get() = if (!Native.themeMode) lightRgb else darkRgb
    val rgbLight: Triple<Double, Double, Double>
        get() = lightRgb
    val rgbDark: Triple<Double, Double, Double>
        get() = darkRgb

    private val lightRgb = convertToRgb(light)
    private val darkRgb = convertToRgb(dark)

    private fun convertToRgb(hex: String): Triple<Double, Double, Double>{
        if (hex.isEmpty()) return Triple(0.0,0.0,0.0)
        val color = hex.removePrefix("#")

        val r = color.substring(color.length - 6, color.length - 4).toInt(16) / 255.0
        val g = color.substring(color.length - 4, color.length - 2).toInt(16) / 255.0
        val b = color.substring(color.length - 2, color.length).toInt(16) / 255.0
        return Triple(r, g, b)
    }
}
