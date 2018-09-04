//
//  Array.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/17.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public extension Array {

    //仿照 android 的 forEachIndex
    public func forEachIndexed(_ handler: (_ index: Int, _ value: Element) -> Void) {
        for (index, value) in self.enumerated() {
            handler(index, value)
        }
    }

    //仿照android的filterIndexed
    public func filterIndexed(_ handler: (_ index: Int, _ value: Element) -> Bool) -> [Element] {
        var filterArray: [Element] = []
        for (index, value) in self.enumerated() {
            if handler(index, value) { filterArray.append(value) }
        }
        return filterArray
    }

    //仿照kotlin的fin
    public func find(_ handler: (_ value: Element) -> Bool) -> Element? {
        for (_, value) in self.enumerated() where handler(value) {
            return value
        }
        return nil
    }

    //將某個index的element調到陣列最後方
    public mutating func moveToLast(_ index: Int) {
        //如果index超過甚至等於總數, 則不動作
        if index >= count - 1 { return }
        append(remove(at: index))
    }
}
