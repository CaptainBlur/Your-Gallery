package com.foxstoncold.yourgallery.link_resolver

import com.foxstoncold.splitlogger.SplitLogger
import com.foxstoncold.yourgallery.link_resolver.data_parser.BunkrMediaItem
import com.foxstoncold.yourgallery.link_resolver.data_parser.DataSourceType
import com.foxstoncold.yourgallery.link_resolver.data_parser.MediaContainer
import com.foxstoncold.yourgallery.link_resolver.data_parser.MediaContainerType
import com.foxstoncold.yourgallery.link_resolver.data_parser.MediaItem
import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json

typealias sl = SplitLogger

class DataParser{
    val testMediaContainer = MediaContainer(containerType = MediaContainerType.BUNKR)

    private val dpScope = CoroutineScope(Dispatchers.IO)
    private val client = HttpClient{
        install(ContentNegotiation){
            json(Json {
                ignoreUnknownKeys = true
            })
        }
    }

    init {
        dpScope.launch {
            sl.en()

            val album = "https://bunkr.cr/a/DoznjiN9"
            val item = "https://bunkr.cr/f/7710667-o6og5XNI.mp4"
            delay (5000L)

//            val result = parseData(album)?: return@launch
//            i("Done: " + (result as MediaContainer).mediaItems.size)
        }
    }

    //region public functions

    suspend fun parseData(url: String): Any?{
        var sourceType: DataSourceType? = null

        for (type in DataSourceType.entries){
            type.resolve(url)
            if (type.matches){
                sourceType = type
                break
            }
        }

        if (sourceType==null){
            sl.s("unknown source type for: $url")
            return null
        }
        else{
            sl.f("detected source type for: $url; $sourceType")
        }

        return if (sourceType.isItem){
            sl.f("parsing item")
            when(sourceType.ordinal){
                0-> BunkrMediaItem.parse(client, sourceType.url)
                else-> null
            }
        }
        else if (sourceType.isAlbum){
            sl.f("parsing album")
            MediaContainer.parse(client, sourceType)
        }
        else{
            sl.s("Link is neither an item or an album")
            null
        }
    }

    //endregion


    //region private functions

    }

    //endregion
