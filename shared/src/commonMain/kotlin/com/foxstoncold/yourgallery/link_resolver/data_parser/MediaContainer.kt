package com.foxstoncold.yourgallery.link_resolver.data_parser

import com.fleeksoft.ksoup.Ksoup
import com.fleeksoft.ksoup.nodes.Document
import com.foxstoncold.yourgallery.link_resolver.sl
import io.ktor.client.HttpClient
import io.ktor.client.request.get
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.supervisorScope
import kotlinx.serialization.MissingFieldException

/*
Universal Media Container model for UI
 */
data class MediaContainer(
    val name: String = "N/A",
    val size: String = "N/A",
    val remoteContainerLink: String = "N/A",
    val containerType: MediaContainerType,
    val mediaItems: List<MediaItem?> = emptyList()
){
    var itemPointer: Int = -1
        set(value) {
            if (value !in mediaItems.indices)
                throw IllegalArgumentException("item pointer should be in range of media items list indices")
            else field = value
        }
        get() {
            if (field==-1)
                throw UnsupportedOperationException("item pointer should be set first")
            else return field
        }

    companion object {
        suspend fun parse(client: HttpClient, sourceType: DataSourceType): MediaContainer?{
            val url = sourceType.url
            val htmlString = handleHttpRequest{
                client.get(url)
            } ?: return null
            val document: Document = Ksoup.parse(htmlString)

            val albumName = document.select("h1.truncate").text()
            val albumSize = document.select("p.text-xs.visitors span.font-semibold").text().drop(1).substringBeforeLast(")")
            val links = document.select("div.theItem a[aria-label=download]")
                .map { it.attr("href") }
                .map { "https://bunkr.cr$it" }

            val result = supervisorScope {
                val items = links.mapIndexed { index, link->
                    async(Dispatchers.IO){
                        BunkrMediaItem.parse(index, client, link)
                    }
                }
                items.awaitAll().sortedBy { it?.index }
            }

            return MediaContainer(albumName, albumSize, url, MediaContainerType.BUNKR, result)
        }

    }
}