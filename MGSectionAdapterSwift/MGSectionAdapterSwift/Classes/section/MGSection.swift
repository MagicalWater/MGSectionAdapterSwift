//
//  MGSection.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/12.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

//typealias MGSectionPos = [Int]

public class MGSectionPos : Hashable {
    
    public var value: [Int] = []
    public var hashValue: Int = 0

    public static func ==(lhs: MGSectionPos, rhs: MGSectionPos) -> Bool {
        if (lhs.value.count != rhs.value.count) { return false }
        for i in 0..<lhs.value.count where lhs.value[i] != rhs.value[i] {
            return false
        }
        return true
    }

}

public class MGSection {

    public var father: MGSection? = nil
    public var child: [MGSection] = []

    //此father底下的第幾個
    public var row: Int = 0

    //此section在tableView的絕對位置
    public var absolatePos: IndexPath = IndexPath()

    //依賴的 viewHolder type
    public var cellType: Int

    /**
     * 當child size
     * = 0 -> 是 leaf
     * > 0 -> 是 node
     */
    public var isLeaf: Bool {
        get { return child.isEmpty }
    }

    //深度
    public var depth: Int {
        get { return (father?.depth ?? -1) + 1 }
    }

    //長度與深度相對應, 從頭到尾第幾個位置進入
    public var position: MGSectionPos {
        get {
            let p = father?.position ?? MGSectionPos()
            p.value.append(row)
            return p
        }
    }

    //搜尋所有層次的child數量
    public var totalChildCount: Int {
        get {
            var count: Int = 0
            for c in child {
                count += c.totalChildCount
            }
            return count
        }
    }

    //下層的child數量
    public var childCount: Int {
        get { return child.count }
    }

    //是否為展開狀態 - 默認展開狀態
    public var isExpand: Bool = true

    public init(_ cellType: Int = MGBaseTableAdapter.TYPE_BODY) {
        self.cellType = cellType
    }


    //加入一個section到child
    public func addChild(_ section: MGSection) {
        child.append(section)
        section.row = childCount - 1
        section.father = self
    }

    //刪除某個child
    public func removeChild(_ index: Int) {
        child.remove(at: index)
    }


    //重新排序所有child
    public func resortChild() {
        for i in 0..<childCount {
            child[i].row = i
            child[i].resortChild()
        }
    }

    //將所有的 child 照順序取出(包含自己, 但若是狀態是縮起, 則不計算)
    public func getAllSection() -> [MGSection] {
        var list: [MGSection] = []
        list.append(self)
        if isExpand {
            child.forEach {
                list += $0.getAllSection()
            }
        }
        return list
    }


    //得到所有擴展狀態與參數相同的MGSectionPos
    public func getExpandStatusList(_ status: Bool) -> [MGSectionPos] {
        var list: [MGSectionPos] = []
        if isExpand == status {
            list.append(position)
        }
        child.forEach {
            list += $0.getExpandStatusList(status)
        }
        return list
    }


    //一路往下傳下去, 直至找到正確位置
    public func setExpandStatus(_ pos: MGSectionPos, status: Bool) -> Int {

        //先檢查深度是否正確
        if (depth == pos.value.count-1) {
            //正確, 就是自己
            //只有當狀態不一樣時, 才回傳改變的數量
            if isExpand != status {
                isExpand = status
                if isExpand { return childCount }
                else { return -childCount }
            } else {
                return 0
            }
        } else {
            //不正確, 往child傳
            //下個child的排序是第幾個
            let childSort = pos.value[depth+1]
            return child[childSort].setExpandStatus(pos, status: status)
        }
    }


    //得到section的組成結構
    public func getSectionStruct() -> [String:Any] {
        var list: [String:Any] = [:]
        list["row"] = row
        list["cellType"] = cellType
        list["child"] = []
        list["absolate_section"] = absolatePos.section
        list["absolate_row"] = absolatePos.row
        child.forEach {
            var child = list["child"] as! Array<[String:Any]>
            child.append($0.getSectionStruct())
            list["child"] = child
        }
        return list
    }


    //位置資訊
    public struct MGSectionStructInfo {
        let row: Int
        let type: Int
        let child: [MGSectionStructInfo]
    }



}
