//
//  MGAppInfoUtils.swift
//  MGUtilsSwift
//
//  Created by Magical Water on 2018/9/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

class MGAppInfoUtils {
    
    public static var versionText: String {
        get {
            return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
        }
    }
    
}
