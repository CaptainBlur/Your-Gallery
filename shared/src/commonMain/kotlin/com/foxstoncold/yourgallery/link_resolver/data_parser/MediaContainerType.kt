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

            onPrimaryContainer = Color("#E2D8FF", "#E2D8FF"),
            onSecondaryContainer = Color("#4E4086", "#BDAEFC"),
            onTertiaryContainer = Color("#FFD0F1", "#FFD0F1"),

            primaryContainer = Color("#6740E3", "#6740E3"),
            secondaryContainer = Color("#C1B1FF", "#4C3E84"),
            tertiaryContainer = Color("#A8269B", "#A8269B"),
            errorContainer = Color("#FFDAD6", "#93000A"),

            primaryContainer_medium = Color("#6740E3", "#977CFF"),
            secondaryContainer_medium = Color("#7163AB", "#9586D1"),
            tertiaryContainer_medium = Color("#A8269B", "#E15CCF"),
            errorContainer_medium = Color("#CF2C27", "#FF5449"),

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
    
    DEFAULT(
        colorScheme = MediaTypeColorScheme(
            primary = Color("#6C5E09", "#FFF9EC"),
            secondary = Color("#665E3B", "#D2C79B"),
            tertiary = Color("#4C6628", "#EEFFD2"),
            error = Color("#BA1A1A", "#FFB4AB"),

            primary_medium = Color("#3F3600", "#FFF9EC"),
            secondary_medium = Color("#3D3616", "#E8DCB0"),
            tertiary_medium = Color("#253D02", "#EEFFD2"),
            error_medium = Color("#740006", "#FFD2CC"),

            onPrimary = Color("#FFFFFF", "#393000"),
            onSecondary = Color("#FFFFFF", "#373011"),
            onTertiary = Color("#FFFFFF", "#203600"),
            onError = Color("#FFFFFF", "#690005"),

            onPrimaryContainer = Color("#6F600C", "#6F600C"),
            onSecondaryContainer = Color("#6D6440", "#C0B58B"),
            onTertiaryContainer = Color("#4E682A", "#4E682A"),

            primaryContainer = Color("#F1DD7F", "#F1DD7F"),
            secondaryContainer = Color("#EEE3B5", "#4E4725"),
            tertiaryContainer = Color("#C7E79A", "#C7E79A"),
            errorContainer = Color("#FFDAD6", "#93000A"),

            primaryContainer_medium = Color("#7C6D1A", "#F1DD7F"),
            secondaryContainer_medium = Color("#766D48", "#9A9169"),
            tertiaryContainer_medium = Color("#5A7535", "#C7E79A"),
            errorContainer_medium = Color("#CF2C27", "#FF5449"),

            surfaceDim = Color("#DFD9CF", "#15130D"),
            surface = Color("#FFF9EE", "#15130D"),
            surfaceBright = Color("#FFF9EE", "#3B3932"),
            onSurface = Color("#1D1C15", "#E7E2D7"),
            onSurfaceVariant = Color("#4B4738", "#CDC6B3"),
            outline = Color("#7C7766", "#96917F"),
            outlineVariant = Color("#CDC6B3", "#4B4738"),

            surfaceContainerLowest = Color("#FFFFFF", "#100E08"),
            surfaceContainerLow = Color("#F9F3E8", "#1D1C15"),
            surfaceContainer = Color("#F3EDE3", "#212019"),
            surfaceContainerHigh = Color("#EDE8DD", "#2C2A23"),
            surfaceContainerHighest = Color("#E7E2D7", "#37352D")
        )
    ),

    PIXELDRAIN(
        colorScheme = MediaTypeColorScheme(
            primary = Color("#4B6635", "#B2D195"),
            secondary = Color("#56624B", "#BECBAE"),
            tertiary = Color("#23695C", "#90D4C4"),
            error = Color("#BA1A1A", "#FFB4AB"),

            primary_medium = Color("#243C10", "#C7E6A9"),
            secondary_medium = Color("#2F3925", "#D4E1C3"),
            tertiary_medium = Color("#003E35", "#A5EAD9"),
            error_medium = Color("#740006", "#FFD2CC"),

            onPrimary = Color("#FFFFFF", "#1F360B"),
            onSecondary = Color("#FFFFFF", "#293420"),
            onTertiary = Color("#FFFFFF", "#00382F"),
            onError = Color("#FFFFFF", "#690005"),

            onPrimaryContainer = Color("#2E4719", "#2E4719"),
            onSecondaryContainer = Color("#5C6850", "#ADB99E"),
            onTertiaryContainer = Color("#00493E", "#00493E"),

            primaryContainer = Color("#97B57C", "#97B57C"),
            secondaryContainer = Color("#DAE7C9", "#3F4A34"),
            tertiaryContainer = Color("#75B8A9", "#75B8A9"),
            errorContainer = Color("#FFDAD6", "#93000A"),

            primaryContainer_medium = Color("#5A7542", "#97B57C"),
            secondaryContainer_medium = Color("#657159", "#89957B"),
            tertiaryContainer_medium = Color("#34786B", "#75B8A9"),
            errorContainer_medium = Color("#CF2C27", "#FF5449"),

            surfaceDim = Color("#DADAD3", "#121410"),
            surface = Color("#FAFAF2", "#121410"),
            surfaceBright = Color("#FAFAF2", "#383A35"),
            onSurface = Color("#1A1C18", "#E3E3DC"),
            onSurfaceVariant = Color("#44483E", "#C4C8BA"),
            outline = Color("#74796D", "#8E9286"),
            outlineVariant = Color("#C4C8BA", "#44483E"),

            surfaceContainerLowest = Color("#FFFFFF", "#0D0F0B"),
            surfaceContainerLow = Color("#F4F4ED", "#1A1C18"),
            surfaceContainer = Color("#EFEEE7", "#1F201C"),
            surfaceContainerHigh = Color("#E9E8E1", "#292B26"),
            surfaceContainerHighest = Color("#E3E3DC", "#343531")
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

    val onPrimaryContainer: Color = Color("", ""),
    val onSecondaryContainer: Color = Color("", ""),
    val onTertiaryContainer: Color = Color("", ""),

    val primaryContainer_medium: Color = Color("", ""),
    val secondaryContainer_medium: Color = Color("", ""),
    val tertiaryContainer_medium: Color = Color("", ""),
    val errorContainer_medium: Color = Color("", ""),

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
