//
//  MGProportionUtils.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/18.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

/*
 比例計算器
 傳入寬高
 在傳入想要更改的寬或高, 自動回傳對應的寬高
 */
public class MGProportionUtils {

    private init() {}

    //得到相同比例的高
    public static func getHeight(_ oriW: CGFloat, oriH: CGFloat, newW: CGFloat) -> CGFloat {
        let wScale = newW / oriW
        let h = oriH * wScale
        return h
    }

    //得到相同比例的寬
    public static func getWidth(_ oriW: CGFloat, oriH: CGFloat, newH: CGFloat) -> CGFloat {
        let hScale = newH / oriH
        let w = oriW * hScale
        return w
    }

}
