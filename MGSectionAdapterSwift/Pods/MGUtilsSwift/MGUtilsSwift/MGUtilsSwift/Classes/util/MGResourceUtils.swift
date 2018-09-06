//
//  MGResourceUtils.swift
//  MGUtilsSwift
//
//  Created by Magical Water on 2018/9/5.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public class MGResourceUtils {
    
    public static func loadString(_ bundle: Bundle? = nil, fileName: String, ex: String? = nil) -> String? {
        let targetBundle: Bundle
        if let b = bundle {
            targetBundle = b
        } else {
            targetBundle = Bundle.main
        }
        guard let path = targetBundle.url(forResource: fileName, withExtension: ex),
            let fileString: String = try? String(contentsOf: path) else {
                return nil
        }
        return fileString
    }
    
}
