//
//  MGLoadmoreDelegate.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/19.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

/**
 * Created by magicalwater on 2017/12/25.
 * 與 MGBaseTableAdapter 相互配合, 加載更多委託相關
 */
public protocol MGLoadmoreDelegate : class {
    func hasLoadmore() -> Bool
    func startLoadmore()
}
