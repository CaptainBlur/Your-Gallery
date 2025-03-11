package com.foxstoncold.yourgallery.link_resolver.data_parser

import com.fleeksoft.ksoup.Ksoup
import com.fleeksoft.ksoup.nodes.Document
import com.fleeksoft.ksoup.nodes.Element
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
    open val index: Int = -1
    open val name: String = "N/A"
    open val size: String = "N/A"
    open val resolvedContentLink: String = "N/A"
    open val resolvedThumbnailLink: String = "N/A"
    open val headers: Map<String, String> = emptyMap()
    open val containerType: MediaContainerType = MediaContainerType.UNDEFINED
}

data class BunkrMediaItem(
    override val index: Int,
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

        suspend fun parse(client: HttpClient, pageLink: String): BunkrMediaItem? = parse(-1, client, pageLink)

        suspend fun parse(index: Int, client: HttpClient, pageLink: String): BunkrMediaItem?{
            val htmlString = handleHttpRequest{
                client.get(pageLink)
            } ?: return null
            val doc = Ksoup.parse(htmlString)

            val itemName = doc.select("h1.text-subs").text()
            val itemSize = doc.select("p.text-xs").firstOrNull()?.ownText()?.trim()
            val thumbnailUrl = doc.select("meta[property=og:image]").attr("content")
            val slug = extractJsVariable(doc, "jsSlug")
            val vc: EncryptedVideoSource = try {
                client.post("https://bunkr.cr/api/vs") {
                    contentType(ContentType.Application.Json)
                    setBody("{\"slug\":\"$slug\"}")
                }.body()
            } catch (e: Exception){
                sl.s("error getting encrypted vs: ", e)
                return null
            }
            val url = decryptVideoUrl(vc)
            if (url==null){
                sl.s("failed to decrypt url: ${vc.url}")
                return null
            }

//            val album = RemoteAlbumModel(albumTitle, albumSize, mediaItems)
//            i(fileName + fileSize + thumbnailUrl)
//            i(url)
            return BunkrMediaItem(
                index, itemName, itemSize?:"N/A", pageLink, url, thumbnailUrl, "", false
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

        private fun extractJsVariable(doc: Document, variableName: String): String? {
            val scripts = doc.select("script")

            for (script in scripts) {
                val scriptText = script.html()

                val regex = Regex("""var\s+$variableName\s*=\s*['"]([^'"]+)['"];""")
                val match = regex.find(scriptText)

                if (match != null) {
                    return match.groupValues[1]
                }
            }

            return null
        }
    }
}