//
//  MGSettingUtils.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/18.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public class MGSettingUtils {

    private init() {}

    public static func put(_ key: String, value: Any?) {
        if let v = value {
            UserDefaults.standard.set(v, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }

    public static func get<T: Any>(_ key: String, def: T) -> T {
        if let v = UserDefaults.standard.object(forKey: key) {
            return v as! T
        }
        return def
    }

    public static func delete(_ key: String) {
        UserDefaults.standard.removeObject(forKey: key)
    }

}
