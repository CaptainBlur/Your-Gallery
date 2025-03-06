package com.foxstoncold.yourgallery.link_resolver.data_parser

import com.fleeksoft.ksoup.Ksoup
import com.foxstoncold.yourgallery.link_resolver.sl
import io.ktor.client.HttpClient
import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.client.request.post
import io.ktor.client.request.setBody
import io.ktor.http.ContentType
import io.ktor.http.contentType
import kotlinx.serialization.Serializable
import kotlin.experimental.xor
import kotlin.io.encoding.Base64
import kotlin.io.encoding.ExperimentalEncodingApi

/*
Universal Media Item model for UI
 */
abstract class MediaItem {
    open val name: String = "N/A"
    open val size: String = "N/A"
    open val resolvedContentLink: String = "N/A"
    open val resolvedThumbnailLink: String = "N/A"
    open val headers: Map<String, String> = emptyMap()
    open val containerType: MediaContainerType = MediaContainerType.UNDEFINED
}

data class BunkrMediaItem(
    override val name: String,
    override val size: String,

    val pageLink: String,
    val srcLink: String = "N/A",
    val thumbnailLink: String,
    val contentPreviewLink: String = "N/A",
    val passPreviewForThumbnail: Boolean
): MediaItem(){
    override val headers: Map<String, String> = mapOf("Referer" to "https://get.bunkrr.su/")
    override val resolvedContentLink: String
        get() = srcLink
    override val resolvedThumbnailLink: String
        get() = if (passPreviewForThumbnail) contentPreviewLink else thumbnailLink
    override val containerType: MediaContainerType
        get() = MediaContainerType.BUNKR


    companion object{
        @Serializable
        data class EncryptedVideoSource(
            val encrypted: Boolean,
            val timestamp: Long,
            val url: String
        )

        suspend fun parse(client: HttpClient, pageLink: String): BunkrMediaItem?{
            val htmlString = handleHttpRequest{
                client.get(pageLink)
            } ?: return null
            val fileName = pageLink.substringAfterLast("/")

            val doc = Ksoup.parse(htmlString)
            val itemName = doc.select("h1.text-subs").text()
            val itemSize = doc.select("p.text-xs").firstOrNull()?.ownText()?.trim()
            val thumbnailUrl = doc.select("meta[property=og:image]").attr("content")

            val vc: EncryptedVideoSource = client.post("https://bunkr.cr/api/vs") {
                contentType(ContentType.Application.Json)
                setBody("{\"slug\":\"$fileName\"}")
            }.body()
            val url = decryptVideoUrl(vc)
            if (url==null){
                sl.s("failed to decrypt url: ${vc.url}")
                return null
            }

//            val album = RemoteAlbumModel(albumTitle, albumSize, mediaItems)
//            i(fileName + fileSize + thumbnailUrl)
//            i(url)
            return BunkrMediaItem(
                itemName, itemSize?:"N/A", pageLink, url, thumbnailUrl, "", false
            )
        }

        @OptIn(ExperimentalEncodingApi::class)
        private fun decryptVideoUrl(vc: EncryptedVideoSource, secretKeyPrefix: String = "SECRET_KEY_"): String? {
            return try {
                // Modify the timestamp like in JavaScript (divide by 3600)
                val keyString = secretKeyPrefix + (vc.timestamp / 3600).toString()
                val key = keyString.encodeToByteArray()

                // Decode the Base64-encoded encrypted string
                val encryptedBytes = Base64.decode(vc.url)

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
    }
}