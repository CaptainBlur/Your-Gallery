package com.foxstoncold.yourgallery

interface Platform {
    val name: String
}

expect fun getPlatform(): Platform