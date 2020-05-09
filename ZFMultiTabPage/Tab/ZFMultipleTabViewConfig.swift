//
//  ZFMultipleTabViewConfig.swift
//  FortuneCatApp
//
//  Created by Flying on 2020/5/8.
//  Copyright © 2020 mflywork. All rights reserved.
//

import UIKit

let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height

let navHeight: CGFloat = {
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    if statusBarHeight == 20.0 {
        return 64
    }else {
        return 88
    }
}()

func colorWithRGB(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: 1)
}

class ZFMultipleTabViewConfig: NSObject {
    
    /** 是否显示底部分割线，默认为true */
    var showBottomSeparator: Bool = true
    /** 按钮之间的间距，默认为 20.0f */
    var spacingBetweenButtons: CGFloat = 20
    /** 标题文字字号大小，默认 15 号字体 */
    var titleFont: UIFont = UIFont.systemFont(ofSize: 15)
    /** 标题文字选中字号大小，默认 15 号字体 */
    var titleSelectedFont: UIFont = UIFont.systemFont(ofSize: 15)
    /** 普通状态下标题按钮文字的颜色，默认为黑色 */
    var titleColor: UIColor = UIColor.black
    /** 选中状态下标题按钮文字的颜色，默认为红色 */
    var titleSelectedColor: UIColor = UIColor.red
    /** 指示器颜色，默认为红色 */
    var indicatorColor: UIColor = UIColor.red
    /** 指示器高度，默认为 3.0f */
    var indicatorHeight: CGFloat = 3.0
    /** 指示器宽度比，默认为 1.0f，与title同宽 */
    var indicatorWidthRate: CGFloat = 1.0
    /** 指示器的圆角，默认为 2.0f */
    var indicatorCorner: CGFloat = 2.0
    /** 指示器距离底部的距离，默认为 5.0f */
    var indicatorBottomDistance: CGFloat = 5.0
    
}
