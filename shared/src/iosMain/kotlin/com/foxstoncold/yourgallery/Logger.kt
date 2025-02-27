package com.foxstoncold.yourgallery

actual fun s(msg: String) { }
actual fun s(obj: Any) { }
actual fun s(msg: String, tr: Throwable?) { }
actual fun s(obj: Any, tr: Throwable?) { }

actual fun w(msg: String) { }
actual fun w(obj: Any) { }

actual fun i(msg: String) { }
actual fun i(obj: Any) { }

actual fun f(msg: String) { }
actual fun f(obj: Any) { }

actual fun fr(msg: String) { }
actual fun fr(obj: Any) { }

actual fun fst(msg: String) { }
actual fun fst(obj: Any) { }

actual fun en() { }
actual fun ex() { }
