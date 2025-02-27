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
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO
import kotlinx.coroutines.launch
import kotlin.experimental.xor
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi

class DataParser(){

    private val dpScope = CoroutineScope(Dispatchers.IO)

    init {
        val encrypted = "OzE3IjZucGQmdz1BVlhHH1MyJis3ayc6ZB8pOwVsUG0FAB4sDgF9Li9kdTFuV0xHDFAFMCNwIT9iLCohYDxRZ0BaR0IwIG4AfSUcLwAYLBpVQwE="
        val timestamp = 1740673482L

        val videoUrl = decryptVideoUrl(encrypted, timestamp)
        i(videoUrl!!)
    }

    //region public functions

    fun parseData(url: String){
        var sourceType: DataSourceType? = null

        for (type in DataSourceType.entries){
            if (type.detectPattern(url)){
                sourceType = type
                break
            }
        }

        if (sourceType==null){
            s("unknown source type for: $url")
            return
        }
        else{
            f("detected source type for: $url; $sourceType")
        }

        when(sourceType){
            DataSourceType.BUNKR-> parseBunkr(url)
        }

    }

    //endregion


    //region private functions

    private fun parseBunkr(url: String){
//        dpScope.launch {
//            val doc: Document = try {
//                Ksoup.parseGetRequest(url)
//            } catch (e: Exception){
//                s("error getting html", e)
//                return@launch
//            }
//
//            val albumTitle = doc.select("h1.truncate").text()
//            val albumSize = doc.select("p.visitors span.font-semibold").text()
//
//            val mediaElements: Elements = doc.select("div.theItem")
//            val mediaItems = mediaElements.map { element ->
//                val name = element.select("p.truncate.theName").text()
//                val size = element.select("p.theSize").text()
//                val link = element.select("a[aria-label=download]").attr("href")
//                val thumbnail = element.select("img.grid-images_box-img").attr("src")
//                MediaItem(name, size, link, thumbnail)
//            }
//
//            val album = RemoteAlbumModel(albumTitle, albumSize, mediaItems)
//            i(album)
//        }
    }

    @OptIn(ExperimentalEncodingApi::class)
    fun decryptVideoUrl(encryptedBase64: String, timestamp: Long, secretKeyPrefix: String = "SECRET_KEY_"): String? {
        return try {
            // Modify the timestamp like in JavaScript (divide by 3600)
            val keyString = secretKeyPrefix + (timestamp / 3600).toString()
            val key = keyString.encodeToByteArray()

            // Decode the Base64-encoded encrypted string
            val encryptedBytes = Base64.decode(encryptedBase64)

            // Perform XOR decryption
            val decryptedBytes = encryptedBytes.mapIndexed { index, byte ->
                byte xor key[index % key.size]
            }.toByteArray()

            // Convert decrypted bytes to string (video URL)
            decryptedBytes.decodeToString()
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    //endregion



}