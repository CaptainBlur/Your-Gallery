package com.foxstoncold.yourgallery

expect fun s(msg: String)
expect fun s(obj: Any)
expect fun s(msg: String, tr: Throwable? = null)
expect fun s(obj: Any, tr: Throwable? = null)

expect fun w(msg: String)
expect fun w(obj: Any)

expect fun i(msg: String)
expect fun i(obj: Any)

expect fun f(msg: String)
expect fun f(obj: Any)

expect fun fr(msg: String)
expect fun fr(obj: Any)

expect fun fst(msg: String)
expect fun fst(obj: Any)

expect fun en()
expect fun ex()
