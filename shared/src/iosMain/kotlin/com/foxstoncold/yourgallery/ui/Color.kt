package com.foxstoncold.yourgallery.ui

import com.foxstoncold.yourgallery.link_resolver.ui.Color
import platform.UIKit.UIColor

fun Color.uiColor(): UIColor = UIColor(red = this.rgb.first, green = this.rgb.second, blue = this.rgb.third, 255.0)
fun Color.uiColorLight(): UIColor = UIColor(red = this.rgbLight.first, green = this.rgbLight.second, blue = this.rgbLight.third, 255.0)
fun Color.uiColorDark(): UIColor = UIColor(red = this.rgbDark.first, green = this.rgbDark.second, blue = this.rgbDark.third, 255.0)