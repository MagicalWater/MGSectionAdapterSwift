//
//  DoubleEx.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/3/3.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public extension Double {
    //小數點以下為０則自動捨去
    public var cleanNonZero: String {
        return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }

    //轉換位數
    public func clean(_ index: Int = 2) -> String {
        return String(format: "%.\(index)f", self)
    }

//    var lowerClean: String {
//        return self.rounded(.down).clean
//    }
}
