package com.foxstoncold.splitlogger

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

    fun sp(msg: String, tr: Throwable? = null) = printMsgMethod(msg, Level.SEVERE, tr = tr)
    fun sp(obj: Any?=null, tr: Throwable? = null) = printMsgMethod(obj?.printObject()?:"", Level.SEVERE, tr = tr)

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

    private val tags: HashMap<String, String> = HashMap()

    //endregion



    //region private methods

    private fun printMsg(msg: String, level: Level, tr: Throwable? = null){
        Helper.simplePrint("${Helper.getFormattedDate()}${getTag(Helper.extractFromStacktrace(6)[0])}${level.marker} ${level.tabulation}$msg")
    }

    private fun printMsgMethod(msg: String, level: Level, tr: Throwable? = null){
        val fromStacktrace = Helper.extractFromStacktrace(6, true)
        Helper.simplePrint("${Helper.getFormattedDate()}${getTag(fromStacktrace[0])}${level.marker}${level.tabulation}(${fromStacktrace[1]})﹏$msg")
    }

    private fun printPass(msg: String){
        val className = Helper.extractFromStacktrace(5)[0]
        Helper.simplePrint("${Helper.getFormattedDate()}${getTag(className)}\uD83D\uDFE3⌇$className⌇$msg")
    }

    private fun getTag(className: String): String{
        //Trying to find a match in the storage
        if (tags.containsKey(className)) return tags[className]?:""

        val capitalLetterWords = Regex("[A-Z][a-z]*").findAll(className)
        val condensedWords = Regex("[A-Z][a-z]{0,3}[^A-Z^equoaijy]?")

        val condensedTag = capitalLetterWords.joinToString(prefix = "TAG_", separator = ""){
            val value = it.value
            val condensed = condensedWords.find(value)
            condensed?.value?:""
        }
        val leveledTag =
            if (condensedTag.length < 23) condensedTag + CharArray(23 - condensedTag.length).apply { fill(' ') }.concatToString()
            else if (condensedTag.length > 23) condensedTag.substring(0 .. 23)
            else condensedTag

        tags[className] = leveledTag
        return leveledTag
    }

    //endregion


}