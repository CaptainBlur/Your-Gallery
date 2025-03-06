package com.foxstoncold.yourgallery.link_resolver.data_parser

import com.foxstoncold.yourgallery.link_resolver.ui.Color

enum class MediaContainerType(
    val colorScheme: MediaTypeColorScheme
) {
    BUNKR(
        colorScheme = MediaTypeColorScheme(
            primary = Color("#4F1DCB", "#CBBEFF"),
            secondary = Color("#62549B", "#CBBEFF"),
            tertiary = Color("#88007F", "#FFACEC"),
            error = Color("#BA1A1A", "#FFB4AB"),

            primary_medium = Color("#3A00A7", "#E1D7FF"),
            secondary_medium = Color("#392A6F", "#E1D7FF"),
            tertiary_medium = Color("#67005F", "#FFCEF0"),
            error_medium = Color("#740006", "#FFD2CC"),

            onPrimary = Color("#FFFFFF", "#340098"),
            onSecondary = Color("#FFFFFF", "#332469"),
            onTertiary = Color("#FFFFFF", "#5D0056"),
            onError = Color("#FFFFFF", "#690005"),

            primaryContainer = Color("#6740E3", "#6740E3"),
            secondaryContainer = Color("#C1B1FF", "#4C3E84"),
            tertiaryContainer = Color("#A8269B", "#A8269B"),
            errorContainer = Color("#FFDAD6", "#93000A"),

            primaryContainer_medium = Color("#6740E3", "#977CFF"),
            secondaryContainer_medium = Color("#7163AB", "#9586D1"),
            tertiaryContainer_medium = Color("#A8269B", "#E15CCF"),
            errorContainer_medium = Color("#CF2C27", "#FF5449"),

            onContainer = Color("#E2D8FF", "#BDAEFC"),

            surfaceDim = Color("#DDD8E5", "#14121B"),
            surface = Color("#FDF7FF", "#14121B"),
            surfaceBright = Color("#FDF7FF", "#3A3842"),
            onSurface = Color("#1C1A24", "#E6E0EE"),
            onSurfaceVariant = Color("#484455", "#CAC3D8"),
            outline = Color("#797486", "#938EA1"),
            outlineVariant = Color("#CAC3D8", "#484455"),

            surfaceContainerLowest = Color("#FFFFFF", "#0F0D16"),
            surfaceContainerLow = Color("#F7F1FF", "#1C1A24"),
            surfaceContainer = Color("#F2EBF9", "#201E28"),
            surfaceContainerHigh = Color("#ECE6F3", "#2B2932"),
            surfaceContainerHighest = Color("#E6E0EE", "#36333E")
        )
    ),
    UNDEFINED(MediaTypeColorScheme())
    ;
}


data class MediaTypeColorScheme(
    val primary: Color = Color("", ""),
    val secondary: Color = Color("", ""),
    val tertiary: Color = Color("", ""),
    val error: Color = Color("", ""),

    val primary_medium: Color = Color("", ""),
    val secondary_medium: Color = Color("", ""),
    val tertiary_medium: Color = Color("", ""),
    val error_medium: Color = Color("", ""),

    val onPrimary: Color = Color("", ""),
    val onSecondary: Color = Color("", ""),
    val onTertiary: Color = Color("", ""),
    val onError: Color = Color("", ""),

    val primaryContainer: Color = Color("", ""),
    val secondaryContainer: Color = Color("", ""),
    val tertiaryContainer: Color = Color("", ""),
    val errorContainer: Color = Color("", ""),

    val primaryContainer_medium: Color = Color("", ""),
    val secondaryContainer_medium: Color = Color("", ""),
    val tertiaryContainer_medium: Color = Color("", ""),
    val errorContainer_medium: Color = Color("", ""),

    val onContainer: Color = Color("", ""),

    val surfaceDim: Color = Color("",""),
    val surface: Color = Color("", ""),
    val surfaceBright: Color = Color("", ""),
    val onSurface: Color = Color("", ""),
    val onSurfaceVariant: Color = Color("", ""),
    val outline: Color = Color("", ""),
    val outlineVariant: Color = Color("", ""),

    val surfaceContainerLowest: Color = Color("", ""),
    val surfaceContainerLow: Color = Color("", ""),
    val surfaceContainer: Color = Color("", ""),
    val surfaceContainerHigh: Color = Color("", ""),
    val surfaceContainerHighest: Color = Color("", "")
)