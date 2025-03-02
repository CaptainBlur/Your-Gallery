package com.foxstoncold.yourgallery.link_resolver.data_parser

enum class DataSourceType(
    private val subdomain: String)
{
    BUNKR("bunkr");

    private var resolved = false

    var url = String()
        private set
        get(){
            if (!resolved)
                throw UnsupportedOperationException("call 'resolve' function first")
            return field
        }
    var matches = false
        private set
        get(){
            if (!resolved)
                throw UnsupportedOperationException("call 'resolve' function first")
            return field
        }
    var isAlbum = false
        private set
        get(){
            if (!resolved)
                throw UnsupportedOperationException("call 'resolve' function first")
            return field
        }
    var isItem = false
        private set
        get(){
            if (!resolved)
                throw UnsupportedOperationException("call 'resolve' function first")
            return field
        }

    //region public functions

    fun resolve(url: String){
        matches = Regex("^.*$subdomain.*$").matches(url)
        resolved = true
        if (!matches)
            return
        this.url = url
        when(this.ordinal){
            0-> {
                val path = url.substringBeforeLast("/").last()
                isAlbum = path=='a'
                isItem = path=='f' || path=='v'
            }
        }
    }

    //endregion


}