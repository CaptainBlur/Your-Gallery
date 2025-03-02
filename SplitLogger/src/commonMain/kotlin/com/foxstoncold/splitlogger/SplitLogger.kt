package com.foxstoncold.splitlogger

object SplitLogger {

    //region logging methods

    fun s(msg: String) = printMsg(msg, Level.SEVERE)
    fun s(obj: Any?) = printMsg(obj.printObject(), Level.SEVERE)
    fun s(msg: String, tr: Throwable? = null) = printMsg(msg, Level.SEVERE, tr = tr)
    fun s(obj: Any?, tr: Throwable? = null) = printMsg(obj.printObject(), Level.SEVERE, tr = tr)

    fun w(msg: String) = printMsg(msg, Level.WARNING)
    fun w(obj: Any?) = printMsg(obj.printObject(), Level.WARNING)

    fun i(msg: String) = printMsg(msg, Level.INFO)
    fun i(obj: Any?) = printMsg(obj.printObject(), Level.INFO)

    fun f(msg: String) = printMsg(msg, Level.FINE)
    fun f(obj: Any?) = printMsg(obj.printObject(), Level.FINE)

    fun fr(msg: String) = printMsg(msg, Level.FINER)
    fun fr(obj: Any?) = printMsg(obj.printObject(), Level.FINER)

    fun fst(msg: String) = printMsg(msg, Level.FINEST)
    fun fst(obj: Any?) = printMsg(obj.printObject(), Level.FINEST)

//    fun en() = printPass("<--")
//    fun ex() = printPass("-->")

    //endregion

    //region private methods

    private fun printMsg(msg: String, level: Level, tr: Throwable? = null){
        println(msg)
        Helper.getFormattedDate()
    }

    //endregion


}