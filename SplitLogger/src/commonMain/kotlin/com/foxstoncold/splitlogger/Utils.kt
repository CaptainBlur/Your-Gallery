package com.foxstoncold.splitlogger

internal inline fun <reified T : Any?>T.printObject(): String{
    return when (this){
//        is Array<*>->
//            Gson().toJson(this)
//        is ByteArray-> Gson().toJson(this.toTypedArray())
//        is CharArray-> Gson().toJson(this.toTypedArray())
//        is ShortArray-> Gson().toJson(this.toTypedArray())
//        is IntArray-> Gson().toJson(this.toTypedArray())
//        is LongArray-> Gson().toJson(this.toTypedArray())
//        is FloatArray-> Gson().toJson(this.toTypedArray())
//        is DoubleArray-> Gson().toJson(this.toTypedArray())
//        is BooleanArray-> Gson().toJson(this.toTypedArray())
        null-> "null"
        else-> this.toString()
    }
}