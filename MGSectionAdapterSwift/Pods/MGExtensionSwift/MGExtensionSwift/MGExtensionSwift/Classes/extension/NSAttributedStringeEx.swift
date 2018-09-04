//
//  NSAttributedStringeEx.swift
//  MGExtensionSwift
//
//  Created by Magical Water on 2018/5/8.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

public extension NSAttributedString {

    //若不輸入寬度約束, 則給定一個預設極大值 greatestFiniteMagnitude, 同於 CGFloat.max, 表示只有一行
    public func height(_ withWidth: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        let constraintRect = CGSize(width: withWidth, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return ceil(boundingBox.height)
    }

    //若不輸入高度約束, 則給定一個預設極大值 greatestFiniteMagnitude, 同於 CGFloat.max, 表示不限制
    public func width(_ withHeight: CGFloat = .greatestFiniteMagnitude) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: withHeight)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return ceil(boundingBox.width)
    }

}
