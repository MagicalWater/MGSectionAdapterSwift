//
//  UIViewEx.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/3/1.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {

    //得到view所屬的viewcontroller
    public var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
