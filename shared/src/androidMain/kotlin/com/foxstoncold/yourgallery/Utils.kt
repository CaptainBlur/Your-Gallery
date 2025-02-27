package com.foxstoncold.yourgallery

import android.content.Context
import com.foxstoncold.splitlogger.SplitLogger

fun initLogger(context: Context){
    SplitLogger.initialize(context)
}

actual fun s(msg: String) { SplitLogger.s(msg) }
actual fun s(obj: Any) { SplitLogger.s(obj) }
actual fun s(msg: String, tr: Throwable?) { SplitLogger.s(msg, tr) }
actual fun s(obj: Any, tr: Throwable?) { SplitLogger.s(obj, tr) }

actual fun w(msg: String) { SplitLogger.w(msg) }
actual fun w(obj: Any) { SplitLogger.w(obj) }

actual fun i(msg: String) { SplitLogger.i(msg) }
actual fun i(obj: Any) { SplitLogger.i(obj) }

actual fun f(msg: String) { SplitLogger.f(msg) }
actual fun f(obj: Any) { SplitLogger.f(obj) }

actual fun fr(msg: String) { SplitLogger.fr(msg) }
actual fun fr(obj: Any) { SplitLogger.fr(obj) }

actual fun fst(msg: String) { SplitLogger.fst(msg) }
actual fun fst(obj: Any) { SplitLogger.fst(obj) }

actual fun en() { SplitLogger.en() }
actual fun ex() { SplitLogger.ex() }