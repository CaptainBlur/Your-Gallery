package com.foxstoncold.yourgallery.link_resolver

data class RemoteAlbumModel(
    val title: String,
    val size: String,
    val mediaItems: List<MediaItem>
)

data class MediaItem(
    val name: String,
    val size: String,
    val link: String,
    val thumbnail: String
)