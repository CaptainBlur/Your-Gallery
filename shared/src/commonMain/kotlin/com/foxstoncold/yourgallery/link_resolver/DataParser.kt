package com.foxstoncold.yourgallery.link_resolver

import com.fleeksoft.charset.Charsets
import com.fleeksoft.charset.toByteArray
import com.fleeksoft.ksoup.Ksoup
import com.fleeksoft.ksoup.nodes.Document
import com.fleeksoft.ksoup.select.Elements
import com.foxstoncold.yourgallery.en
import com.foxstoncold.yourgallery.f
import com.foxstoncold.yourgallery.i
import com.foxstoncold.yourgallery.s
import io.ktor.client.HttpClient
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.serialization.kotlinx.json.json
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json
import kotlin.experimental.ExperimentalObjCName
import kotlin.experimental.xor
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi
import kotlin.native.ObjCName

class DataParser{

    private val dpScope = CoroutineScope(Dispatchers.IO)
    private val client = HttpClient{
        install(ContentNegotiation){
            json(Json {
                ignoreUnknownKeys = true
            })
        }
    }

    init {

    }

    //region public functions

    suspend fun parseData(url: String): MediaItem?{
        var sourceType: DataSourceType? = null

        for (type in DataSourceType.entries){
            if (type.detectPattern(url)){
                sourceType = type
                break
            }
        }

        if (sourceType==null){
            s("unknown source type for: $url")
            return null
        }
        else{
            f("detected source type for: $url; $sourceType")
        }

        return when(sourceType){
            DataSourceType.BUNKR-> BunkrMediaItem.parse(client, url)
        }
    }

    //endregion


    //region private functions

    }

    //endregion
