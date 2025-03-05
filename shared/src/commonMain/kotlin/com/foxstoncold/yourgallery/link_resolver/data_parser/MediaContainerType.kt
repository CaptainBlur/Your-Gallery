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

            surfaceContainerLowest = Color("#FFFFFF", "#0F0D16"),
            surfaceContainerLow = Color("#F7F1FF", "#1C1A24"),
            surfaceContainer = Color("#F2EBF9", "#201E28"),
            surfaceContainerHigh = Color("#ECE6F3", "#2B2932"),
            surfaceContainerHighest = Color("#E6E0EE", "#36333E")
        )
    );
}


data class MediaTypeColorScheme(
    val primary: Color,
    val secondary: Color,
    val tertiary: Color,
    val error: Color,

    val primary_medium: Color,
    val secondary_medium: Color,
    val tertiary_medium: Color,
    val error_medium: Color,

    val onPrimary: Color,
    val onSecondary: Color,
    val onTertiary: Color,
    val onError: Color,

    val primaryContainer: Color,
    val secondaryContainer: Color,
    val tertiaryContainer: Color,
    val errorContainer: Color,

    val primaryContainer_medium: Color,
    val secondaryContainer_medium: Color,
    val tertiaryContainer_medium: Color,
    val errorContainer_medium: Color,

    val onContainer: Color,

    val surfaceDim: Color,
    val surface: Color,
    val surfaceBright: Color,
    val onSurface: Color,
    val onSurfaceVariant: Color,

    val surfaceContainerLowest: Color,
    val surfaceContainerLow: Color,
    val surfaceContainer: Color,
    val surfaceContainerHigh: Color,
    val surfaceContainerHighest: Color
)