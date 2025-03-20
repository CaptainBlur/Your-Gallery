package com.foxstoncold.yourgallery.link_resolver

import com.foxstoncold.splitlogger.SplitLogger
import com.foxstoncold.yourgallery.link_resolver.data_parser.BunkrMediaItem
import com.foxstoncold.yourgallery.link_resolver.data_parser.DataSourceType
import com.foxstoncold.yourgallery.link_resolver.data_parser.MediaContainer
import com.foxstoncold.yourgallery.link_resolver.data_parser.MediaContainerType
import com.foxstoncold.yourgallery.link_resolver.data_parser.MediaItem
import com.foxstoncold.yourgallery.link_resolver.data_parser.PixeldrainMediaItem
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
    private val parsedDataCache: HashMap<String, Any?> = hashMapOf()

    init {
        sl.en()
    }

    fun testRun(){
        dpScope.launch {
//            val album = "https://bunkr.cr/a/DoznjiN9"
//            val item = "https://bunkr.cr/f/7710667-o6og5XNI.mp4"
//            val item = "https://pixeldrain.com/u/tgN4A9Hs"
            val album = "https://pixeldrain.com/l/j5G25RUJ"
            delay (5000L)

            val result = parseData(album)?: return@launch
            sl.w(result)
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

        return if (parsedDataCache.containsKey(sourceType.url)){
            sl.fst("getting cached data")
            parsedDataCache[sourceType.url]
        }
        else if (sourceType.isItem){
            sl.f("parsing item")
            val parsed = when(sourceType.ordinal){
                0-> BunkrMediaItem.parse(client, sourceType.url)
                1-> PixeldrainMediaItem.parse(client, sourceType.url)
                else-> null
            }
            parsed?.let { parsedDataCache[sourceType.url] = it }
            return parsed
        }
        else if (sourceType.isAlbum){
            sl.f("parsing album")
            val parsed = MediaContainer.parse(client, sourceType)
            parsed?.let { parsedDataCache[sourceType.url] = it }
            return parsed
        }
        else{
            sl.s("Link is neither an item or an album")
            null
        }
    }

    //endregion


    //region private functions



    //endregion

    }