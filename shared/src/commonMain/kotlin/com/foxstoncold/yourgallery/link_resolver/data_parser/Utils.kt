package com.foxstoncold.yourgallery.link_resolver.data_parser

import com.foxstoncold.yourgallery.s
import io.ktor.client.statement.HttpResponse
import io.ktor.client.statement.bodyAsText
import io.ktor.http.HttpStatusCode
import io.ktor.http.isSuccess

suspend fun handleHttpResponse(response: HttpResponse) =
    if (response.status.isSuccess()) response.bodyAsText()
    else{
        s("error making request: ${response.status}; ${response.bodyAsText()}")
        null
    }