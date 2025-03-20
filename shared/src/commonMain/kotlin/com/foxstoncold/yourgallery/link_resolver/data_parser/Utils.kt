package com.foxstoncold.yourgallery.link_resolver.data_parser

import com.foxstoncold.splitlogger.SplitLogger
import com.foxstoncold.yourgallery.link_resolver.sl
import io.ktor.client.call.body
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.bodyAsText
import io.ktor.http.isSuccess

object Native{
    val sl = SplitLogger
    var logging: Boolean
        set(value){
            SplitLogger.enabled = value
        }
        get() = SplitLogger.enabled
    var themeMode: Boolean = false
}

suspend inline fun <reified R>handleHttpRequest(request: () -> HttpResponse): R? {
    try {
        val response = request()
        if (response.status.isSuccess()) return response.body<R>()
        else{
            sl.s("error making request: ${response.status}; ${response.bodyAsText()}")
            return null
        }
    } catch (e: Exception){
        sl.s("error making request: ", e)
        return null
    }
}
