//
//  EndEditingScrollView.swift
//  AuthorizedStore
//
//  Created by Magical Water on 2018/3/2.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit

public class EndEditingScrollView: UIScrollView {

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        endEditing(true)
    }

}
