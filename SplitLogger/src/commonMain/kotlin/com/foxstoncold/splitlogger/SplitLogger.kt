package com.foxstoncold.splitlogger

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.IO

object SplitLogger {

    //region simple logging methods

    fun s(msg: String) = printMsg(msg, Level.SEVERE)
    fun s(obj: Any? = null) = printMsg(obj.printObject(), Level.SEVERE)
    fun s(msg: String, tr: Throwable? = null) = printMsg(msg, Level.SEVERE, tr = tr)
    fun s(obj: Any? = null, tr: Throwable? = null) = printMsg(obj.printObject(), Level.SEVERE, tr = tr)

    fun w(msg: String) = printMsg(msg, Level.WARNING)
    fun w(obj: Any? = null) = printMsg(obj.printObject(), Level.WARNING)

    fun i(msg: String) = printMsg(msg, Level.INFO)
    fun i(obj: Any? = null) = printMsg(obj.printObject(), Level.INFO)

    fun f(msg: String) = printMsg(msg, Level.FINE)
    fun f(obj: Any? = null) = printMsg(obj.printObject(), Level.FINE)

    fun fr(msg: String) = printMsg(msg, Level.FINER)
    fun fr(obj: Any? = null) = printMsg(obj.printObject(), Level.FINER)

    fun fst(msg: String) = printMsg(msg, Level.FINEST)
    fun fst(obj: Any? = null) = printMsg(obj.printObject(), Level.FINEST)

    fun en() = printPass("<--")
    fun ex() = printPass("-->")

    //endregion

    //region method print logging methods

    fun sp(msg: String) = printMsgMethod(msg, Level.SEVERE)
    fun sp(obj: Any?=null) = printMsgMethod(obj?.printObject()?:"", Level.SEVERE)

//    fun sp(msg: String, tr: Throwable? = null) = printMsgMethod(msg, Level.SEVERE, tr = tr)
//    fun sp(obj: Any?=null, tr: Throwable? = null) = printMsgMethod(obj?.printObject()?:"", Level.SEVERE, tr = tr)

    fun wp(msg: String) = printMsgMethod(msg, Level.WARNING)
    fun wp(obj: Any?=null) = printMsgMethod(obj?.printObject()?:"", Level.WARNING)

    fun ip(msg: String) = printMsgMethod(msg, Level.INFO)
    fun ip(obj: Any?=null) = printMsgMethod(obj?.printObject()?:"", Level.INFO)

    fun fp(msg: String) = printMsgMethod(msg, Level.FINE)
    fun fp(obj: Any?=null) = printMsgMethod(obj?.printObject()?:"", Level.FINE)

    fun frp(msg: String) = printMsgMethod(msg, Level.FINER)
    fun frp(obj: Any?=null) = printMsgMethod(obj?.printObject()?:"", Level.FINER)

    fun fstp(msg: String) = printMsgMethod(msg, Level.FINEST)
    fun fstp(obj: Any?=null) = printMsgMethod(obj?.printObject()?:"", Level.FINEST)

    //endregion



    //region private properties

    private val loggerScope = CoroutineScope(Dispatchers.IO)
    private val tags: HashMap<String, String> = HashMap()

    //endregion



    //region private methods

    private fun printMsg(msg: String, level: Level, tr: Throwable? = null){
        val fromStacktrace = Helper.extractFromStacktrace(6)
        Helper.simplePrint("${Helper.getFormattedDate()}${getTag(fromStacktrace.first, fromStacktrace.third)}${level.marker} ${level.tabulation}$msg${tr?.stackTraceToString()?:""}")
    }

    private fun printMsgMethod(msg: String, level: Level, tr: Throwable? = null){
        val fromStacktrace = Helper.extractFromStacktrace(6, true)
        Helper.simplePrint("${Helper.getFormattedDate()}${getTag(fromStacktrace.first, fromStacktrace.third)}${level.marker}${level.tabulation}(${fromStacktrace.second})﹏$msg")
    }

    private fun printPass(msg: String){
        val fromStacktrace = Helper.extractFromStacktrace(5)
        Helper.simplePrint("${Helper.getFormattedDate()}${getTag(fromStacktrace.first, fromStacktrace.third)}\uD83D\uDFE3⌇${fromStacktrace.first}⌇$msg")
//        Helper.simplePrint("TAG___${className}")
    }

    private fun getTag(className: String, nativeCaller: Boolean): String{
        //Trying to find a match in the storage
        if (tags.containsKey(className)) return tags[className]?:""

        val capitalLetterWords = Regex("[A-Z][a-z]*").findAll(className)
        val condensedWords = Regex("[A-Z][a-z]{0,3}[^A-Z^equoaijy]?")

        val condensedTag = capitalLetterWords.joinToString(prefix = "TAG${if(nativeCaller)"_N" else ""}_", separator = ""){
            val value = it.value
            val condensed = condensedWords.find(value)
            condensed?.value?:""
        }
        val maxTagLength = if (!nativeCaller) 23 else 25
        val leveledTag =
            if (condensedTag.length < maxTagLength) condensedTag + CharArray(maxTagLength - condensedTag.length).apply { fill(' ') }.concatToString()
            else if (condensedTag.length > maxTagLength-1) condensedTag.substring(0..<maxTagLength-1) + ' '
            else condensedTag

        tags[className] = leveledTag
        return leveledTag
    }

    //endregion


}