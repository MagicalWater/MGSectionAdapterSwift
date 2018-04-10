//
//  MGSectionDelegate.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/22.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

public protocol MGSectionDelegate {
    //設定擴展狀態, 並且刷新動畫, 回傳增加減少了多少個count
    func setExpandStatusAndRefresh(_ section: MGSection, status: Bool) -> Int

    //設定擴展狀態, 不刷新, 回傳增加減少了多少個count
    func setExpandStatus(_ section: MGSection, status: Bool) -> Int

    //得到某個位置的擴展狀態
    func getExpandStatus(_ section: MGSection) -> Bool

    //插入section, 使用動畫
    func insertSectionAndRefresh(_ pos: MGSectionPos, type: Int, count: Int)

    //加入section到最後, 使用動畫
    func appendSectionAndRefresh(_ depth: Int, type: Int, count: Int)

    //加入到某個section的child
    func appendChildSectionAndRefresh(_ inSection: MGSection, type: Int, count: Int)

    //移除section, 使用動畫
    func removeSectionAndRefresh(_ pos: MGSectionPos)

    //刷新指定的section
    func refreshSection(_ pos: MGSectionPos)

    //尋找上個同深度的節點
    func findPreNode(_ section: MGSection) -> MGSection?

    //從 itemView 找出完整的位置
    func findPosition(_ byView: UIView) -> MGSectionPos?

    //從 itemView 找出 section
    func findSection(_ byView: UIView) -> MGSection?

    //快速設定 第一層 section 的數量
    func quickSetSection(_ count: Int, type: Int?)

    //清除所有section
    func cleanSection()

    //清除位置快取
    func cleanPosCache()

    //加入section到第一層, 第一層的每個section能有header跟footer
    func addSection(_ section: MGSection, header: Int?, footer: Int?)

    func appendChildSection(_ inSection: MGSection, type: Int, count: Int)

    //有否最上層(通常和加載置頂搭配), 以及最下層(通常與家載更多搭配使用)
    func setOuterHolder(_ top: Bool, bottom: Bool)
}
