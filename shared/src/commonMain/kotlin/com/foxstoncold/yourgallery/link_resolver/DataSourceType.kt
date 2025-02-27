package com.foxstoncold.yourgallery.link_resolver

enum class DataSourceType(
    private val subdomain: String)
{
    BUNKR("bunkr");

    //region public functions

    fun detectPattern(url: String): Boolean = Regex("^.*$subdomain.*$").matches(url)

    //endregion


}