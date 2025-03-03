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

    actual fun extractFromStacktrace(stackTraceElement: Int, extractFunctionName: Boolean): Triple<String, String, Boolean> {
        val callStack = NSThread.callStackSymbols
        val stackElement = callStack[stackTraceElement].toString()

        fun extractSharedCall(): Triple<String, String, Boolean>?{
            val classNameResult = Regex("\\.\\p{Upper}\\p{Lower}+\\w*\\p{Punct}").find(stackElement, 59)
            val className = classNameResult?.value?.drop(1)?.dropLast(1)?: return null
            if (!extractFunctionName)
                return Triple(className, "[not_extracted]", false)
            else{
                val lastClassNameEnd = classNameResult.range.last
                val functionNameRegex = Regex("\\p{Punct}\\p{Lower}\\w*\\p{Punct}")
                val functionName = functionNameRegex.find(stackElement.substring(lastClassNameEnd))?.value?.drop(1)?.dropLast(1)?:"[unknown]"
                return Triple(className, functionName, false)
            }
        }

        fun extractNativeCall(): Triple<String, String, Boolean>{
            val classNameBoundary = "[0-9A-F]{2,3}"
//            val classNameOne = Regex("$classNameBoundary\\p{Upper}\\p{Lower}+\\w*?$classNameBoundary").find(stackElement, 59)?.value?: return Triple("[unknown]", "[unknown]", true)
            val classNameBoundariesResult = Regex(classNameBoundary).findAll(stackElement, 59).also {
                if (it.count()<2) return Triple("[unknown]", "[unknown]", true)
            }.first()
            val classNameTwo = stackElement.substring(startIndex = classNameBoundariesResult.range.last+1, endIndex = classNameBoundariesResult.next()!!.range.first)


            return Triple(classNameTwo, "[unknown]", true)
        }

        return extractSharedCall()?: extractNativeCall()
    }


    actual fun simplePrint(line: String) = println(line)
    actual fun getPrintedStack(element: Int): String {
//        val stackElement = NSThread.callStackSymbols[element].toString()
        val stackElement = NSThread.callStackSymbols().joinToString{ "\nTAG___" + it }
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
