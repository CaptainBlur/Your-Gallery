package com.foxstoncold.yourgallery.link_resolver

enum class DataSourceType(
    private val subdomain: String)
{
    BUNKR("bunkr"), GOFILE("gofile"), PIXELDRAIN("pixeldrain")
}