package com.foxstoncold.yourgallery

import platform.Foundation.NSLog

actual fun s(msg: String) { println(msg) }
actual fun s(obj: Any) { }
actual fun s(msg: String, tr: Throwable?) { }
actual fun s(obj: Any, tr: Throwable?) { }

actual fun w(msg: String) { println(msg) }
actual fun w(obj: Any) { }

actual fun i(msg: String) { println(msg) }
actual fun i(obj: Any) { }

actual fun f(msg: String) { println(msg) }
actual fun f(obj: Any) { }

actual fun fr(msg: String) { println(msg) }
actual fun fr(obj: Any) { }

actual fun fst(msg: String) { println(msg) }
actual fun fst(obj: Any) { }

actual fun en() { }
actual fun ex() { }
