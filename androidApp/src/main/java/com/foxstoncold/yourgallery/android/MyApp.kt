package com.foxstoncold.yourgallery.android

import android.app.Application
import com.foxstoncold.yourgallery.initLogger
import com.foxstoncold.yourgallery.link_resolver.DataParser

class MyApp: Application(){
    override fun onCreate() {
        super.onCreate()

        initLogger(this)
        val dp = DataParser()


    }
}