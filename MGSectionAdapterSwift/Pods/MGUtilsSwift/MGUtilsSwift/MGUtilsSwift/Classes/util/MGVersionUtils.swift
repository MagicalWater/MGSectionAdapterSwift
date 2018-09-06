//
//  MGVersionUtils.swift
//  MGUtilsSwift
//
//  Created by Magical Water on 2018/9/5.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public class MGVersionUtils {
    private init() {}
    
    //比較版本號
    public static func compareIsNew(_ ori: String, new: String) -> Bool {
        var oriArray = ori.split(separator: ".").map{ Int($0) ?? 0 }
        var newArray = new.split(separator: ".").map{ Int($0) ?? 0 }
        
        let maxLen = max(oriArray.count, newArray.count)
        //比較短的那邊補上缺少的長度, 內容為0
        if maxLen > oriArray.count {
            oriArray.append(contentsOf: [Int](repeating: 0, count: maxLen - oriArray.count))
        } else if maxLen > newArray.count {
            newArray.append(contentsOf: [Int](repeating: 0, count: maxLen - newArray.count))
        }
        
        for i in 0..<maxLen {
            let oriInt = oriArray[i]
            let newInt = newArray[i]
            if oriInt > newInt {
                return false
            } else if newInt > oriInt {
                return true
            }
        }
        return false
    }
}
