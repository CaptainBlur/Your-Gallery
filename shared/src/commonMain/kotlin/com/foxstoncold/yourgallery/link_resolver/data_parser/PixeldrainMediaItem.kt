package com.foxstoncold.yourgallery.link_resolver.data_parser

import com.foxstoncold.yourgallery.link_resolver.data_parser.BunkrMediaItem.Companion
import com.foxstoncold.yourgallery.link_resolver.sl
import io.ktor.client.HttpClient
import io.ktor.client.request.get
import kotlinx.serialization.Serializable

data class PixeldrainMediaItem(
    override val index: Int,
    override val name: String,
    override val size: String,
    override val resolvedThumbnailLink: String,
    override val contentType: MediaItemContentType,

    val fileId: String,
    ): MediaItem()
    {
        override val resolvedContentLink: String
            get() = "https://pixeldrain.com/api/file/$fileId"
        override val containerType: MediaContainerType
            get() = MediaContainerType.PIXELDRAIN

        companion object{
            @Serializable
            data class PixeldrainFileInfo(
                val id: String,
                val name: String,
                val size: Int,
                val thumbnail_href: String
            )

            @Serializable
            data class PixeldrainFileListInfo(
                val id: String,
                val title: String,
                val files: List<PixeldrainFileInfo>
            )

            suspend fun parse(client: HttpClient, pageLink: String): PixeldrainMediaItem? =
                PixeldrainMediaItem.parse(-1, client, pageLink)

            suspend fun parse(index: Int, client: HttpClient, pageLink: String): PixeldrainMediaItem?{
                val link = "https://pixeldrain.com/api/file/${pageLink.substringAfterLast('/')}/info"

                val fileInfo: PixeldrainFileInfo? = handleHttpRequest {
                    client.get(urlString = link)
                }
                if (fileInfo==null)
                    return null

                return parse(index, fileInfo)
            }

            fun parse(index: Int, fileInfo: PixeldrainFileInfo): PixeldrainMediaItem{
                val thumbnailLink = "https://pixeldrain.com/api" + fileInfo.thumbnail_href
                val size = formatFileSize(fileInfo.size.toLong())

                return PixeldrainMediaItem(index, fileInfo.name, size, thumbnailLink, MediaItemContentType.VIDEO, fileInfo.id)
            }

            private fun formatFileSize(bytes: Long): String {
                if (bytes < 0) return "Invalid size" // Handle negative values

                val units = arrayOf("B", "KB", "MB", "GB", "TB", "PB")
                var size = bytes.toDouble()
                var unitIndex = 0

                while (size >= 1024 && unitIndex < units.lastIndex) {
                    size /= 1024
                    unitIndex++
                }

                return if (size % 1 == 0.0)
                    "${size.toInt()} ${units[unitIndex]}"
                else
                    "${(size * 10).toInt() / 10.0} ${units[unitIndex]}" // Manual rounding to 1 decimal place
            }
        }
    }