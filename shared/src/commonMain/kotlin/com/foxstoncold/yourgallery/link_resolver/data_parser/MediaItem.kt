package com.foxstoncold.yourgallery.link_resolver.data_parser

/*
Universal Media Item model for UI
 */
abstract class MediaItem {
    open val index: Int = -1
    open val name: String = "N/A"
    open val size: String = "N/A"
    open val contentType: MediaItemContentType = MediaItemContentType.UNDEFINED
    open val resolvedContentLink: String = "N/A"
    open val resolvedThumbnailLink: String = "N/A"
    open val headers: Map<String, String> = emptyMap()
    open val containerType: MediaContainerType = MediaContainerType.UNDEFINED
}

enum class MediaItemContentType{
    UNDEFINED, PHOTO, VIDEO, OTHER
}

