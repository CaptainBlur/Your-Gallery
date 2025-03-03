package com.foxstoncold.splitlogger

import platform.Foundation.NSDate
import platform.Foundation.NSDateFormatter
import platform.Foundation.NSThread

internal actual object Helper {

    actual fun getFormattedDate(): String{
        val date = NSDate()
        val formatter = NSDateFormatter().apply {
            dateFormat = "HH:mm:ss:SSS__"
        }
        return formatter.stringFromDate(date)
    }

    actual fun extractFromStacktrace(stackTraceElement: Int, extractFunctionName: Boolean): Array<String> {
        val callStack = NSThread.callStackSymbols
        val stackElement = callStack[stackTraceElement].toString()
        val classNameResult = Regex("\\.\\p{Upper}\\p{Lower}+\\w*\\p{Punct}").find(stackElement, 59)
        val className = classNameResult?.value?.drop(1)?.dropLast(1)?:"null"
        if (!extractFunctionName)
            return arrayOf(className)
        else{
            val lastClassNameEnd = classNameResult?.range?.last?: return arrayOf(className, "[unknown]")
            val functionNameRegex = Regex("\\p{Punct}\\p{Lower}\\w*\\p{Punct}")
            val functionName = functionNameRegex.find(stackElement.substring(lastClassNameEnd))?.value?.drop(1)?.dropLast(1)?:"[unknown]"
            return arrayOf(className, functionName)
        }
    }

    actual fun simplePrint(line: String) = println(line)
    actual fun getPrintedStack(element: Int): String {
        val stackElement = NSThread.callStackSymbols[5].toString()
        return stackElement
//        val classNameRegex = Regex("\\.\\p{Upper}\\p{Lower}+\\w*\\p{Punct}+")
//
//        val lastClassNameEnd = classNameRegex.find(stackElement, 59)?.range?.last?: return "null"
//        val functionNameRegex = Regex("\\p{Punct}\\p{Lower}\\w*\\p{Punct}")
//        val functionName = functionNameRegex.find(stackElement.substring(lastClassNameEnd))?.value?:"null"
//
//        return "\nTAG___" + stackElement.substring(lastClassNameEnd) + "___" + functionName.drop(1).dropLast(1) + "﹏"
    }
}
