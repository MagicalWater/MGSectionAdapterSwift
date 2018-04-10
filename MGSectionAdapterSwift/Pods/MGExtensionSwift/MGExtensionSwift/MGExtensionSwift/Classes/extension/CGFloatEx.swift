//
//  CGFloatEx.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/27.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

public extension CGFloat {

    //將當前數值默認為pt, 取得轉為px的值
    public var px: CGFloat {
        get { return self * UIScreen.main.scale }
    }

    //將當前數值默認為px, 取得轉為pt的值
    public var pt: CGFloat {
        get { return self / UIScreen.main.scale }
    }
}
