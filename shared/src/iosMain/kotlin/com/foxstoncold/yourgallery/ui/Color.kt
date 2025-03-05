package com.foxstoncold.yourgallery.ui

import com.foxstoncold.yourgallery.link_resolver.ui.Color
import platform.UIKit.UIColor

fun Color.uiColor(): UIColor = UIColor(red = this.rgb.first, green = this.rgb.second, blue = this.rgb.third, 255.0)