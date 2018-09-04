//
//  MGBaseCollectionAdapter.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/19.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit
import MGUtilsSwift

/**
 2018.9.4: 取消加載 置頂/更多 的動畫顯示, 一律改用靜態顯示, 因為使用者操作上可能造成不便
 */
open class MGBaseCollectionAdapter : MGBaseScrollAdapter, MGBaseCollectionDataBindDelegate, MGBaseCollectionCustomSizeDelegate {

    public static let TYPE_OUTTER_HEADER = -1001
    public static let TYPE_OUTTER_FOOTER = -1002
    public static let TYPE_BODY = -1003
    public static let TYPE_BLANK = -1004

    private let ID_OUTER_TOP: String = "ID_OUTER_TOP"
    private let ID_OUTER_BOTTOM: String = "ID_OUTER_BOTTOM"
    private let ID_EMPTY_BODY: String = "ID_EMPTY_BODY"
    private let ID_EMPTY_HEADER: String = "ID_EMPTY_HEADER"
    private let ID_EMPTY_FOOTER: String = "ID_EMPTY_FOOTER"

    public var collectionView: UICollectionView

    //已註冊的cell, header, footer
    private var registerCells: [Int:UINib] = [:]
    private var registerHeaders: [Int:UINib] = [:]
    private var registerFooters: [Int:UINib] = [:]

    //配置所有cell type的物件
    private var sectionGroup: MGSectionGroup = MGSectionGroup()

    //置頂加載跟置底加載
    private var loadmoreHelper: MGLoadmoreHelper = MGLoadmoreHelper()
    private var loadtopHelper: MGLoadtopHelper = MGLoadtopHelper()

    //底部加載
    weak var loadmoreDelegate: MGLoadmoreDelegate?

    //頂部加載
    weak var loadtopDelegate: MGLoadtopDelegate?

    private var timer: MGTimerUtils = MGTimerUtils()

    public init(_ collectionView: UICollectionView, orientation: ScrollOrientation) {
        self.collectionView = collectionView
        self.collectionView.register(MGBaseCollectionCell.self, forCellWithReuseIdentifier: ID_OUTER_TOP)
        self.collectionView.register(MGBaseCollectionCell.self, forCellWithReuseIdentifier: ID_OUTER_BOTTOM)
        self.collectionView.register(MGBaseCollectionCell.self, forCellWithReuseIdentifier: ID_EMPTY_BODY)
        self.collectionView.register(MGBaseCollectionCell.self, forCellWithReuseIdentifier: "\(MGBaseCollectionAdapter.TYPE_BODY)")
        self.collectionView.register(MGCollectionHeaderFooterReuseView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: ID_EMPTY_HEADER)
        self.collectionView.register(MGCollectionHeaderFooterReuseView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: ID_EMPTY_FOOTER)
        super.init()
        self.scrollOrientation = orientation

        settingLayout()
    }

    private func settingLayout() {
        let layout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout

        //設定方向
        layout.scrollDirection = scrollOrientation == .vertical ? UICollectionViewScrollDirection.vertical : UICollectionViewScrollDirection.horizontal

        //自適應寬高 預估cell size，size不能為空或者CGSize.zero，除之外可以隨意設置
        layout.estimatedItemSize = CGSize(width: 20, height: 20)

        //自適應寬高的cell必須複寫preferredLayoutAttributesFitting方法

//        layout.minimumInteritemSpacing = itemMinSpace()
//        layout.minimumLineSpacing = lineMinSpace()
//        layout.sectionInset = sectionSpace()
//        leftInspect = layout.sectionInset.left
//        rightInspect = layout.sectionInset.right
    }

    //註冊cell
    public func registerCell(_ cell: UINib, type: Int) {
        registerCells[type] = cell
        collectionView.register(cell, forCellWithReuseIdentifier: "\(type)")
    }

    //註冊header view
    public func registerHeaderView(_ headerView: UINib, type: Int) {
        registerHeaders[type] = headerView
        collectionView.register(headerView, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "\(type)")
    }

    //註冊footer view
    public func registerFooterView(_ footerView: UINib, type: Int) {
        registerFooters[type] = footerView
        collectionView.register(footerView, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "\(type)")
    }


    //開始載入資料
    public func startLoadData() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsSelection = false
        collectionView.allowsMultipleSelection = false
    }


    //重新載入所有collection資料
    public func reloadData() {
        //重新載入資料
        collectionView.reloadData()
    }



    //****************** MGBaseCollectionDataBindDelegate ******************
    //同步顯示某個section的header
    open func bindSectionHeaderView(_ view: MGCollectionHeaderFooterReuseView, section: Int, header: MGSectionGroup.MGSectionHeader) {}

    //同步顯示某個section的footer
    open func bindSectionFooterView(_ view: MGCollectionHeaderFooterReuseView, section: Int, footer: MGSectionGroup.MGSectionFooter) {}

    //同步顯示某個cell
    open func bindSectionCell(_ cell: MGBaseCollectionCell, indexPath: IndexPath, section: MGSection) {}

    //同步顯示最外層(置頂加載)
    open func bindOuterHeaderCell(_ cell: MGBaseCollectionCell, indexPath: IndexPath) {}

    //同步顯示最外層(置底加載)
    open func bindOuterFooterCell(_ cell: MGBaseCollectionCell, indexPath: IndexPath) {}
    //****************** MGBaseCollectionDataBindDelegate ******************


    //****************** MGBaseCollectionCustomSizeDelegate ******************


    //是否自定義某個cell的高度
    open func customSectionCellSize(_ indexPath: IndexPath, section: MGSection) -> CGSize? {
        return nil
    }
    //是否自定義最外層頂部cell的高度
    open func customOuterHeaderCellSize(_ indexPath: IndexPath) -> CGSize? {
        return nil
    }
    //是否自定義最外層底下cell的高度
    open func customOuterFooterCellSize(_ indexPath: IndexPath) -> CGSize? {
        return nil
    }
    //是否自定義section header的高度
    open func customSectionHeaderSize(_ section: Int, header: MGSectionGroup.MGSectionHeader) -> CGSize? {
        return nil
    }
    //是否自定義section footer的高度
    open func customSectionFooterSize(_ section: Int, footer: MGSectionGroup.MGSectionFooter) -> CGSize? {
        return nil
    }

    //****************** MGBaseCollectionCustomSizeDelegate ******************
}


extension MGBaseCollectionAdapter: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        let count = sectionGroup.getOuterSectionCount()
        return count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = sectionGroup.getInnerSectionCount(section)
        return count
    }


    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: MGBaseCollectionCell
        //如果 pos 是 0, 並且 outerHeader 有開啟就是 TYPE_OUTTER_HEADER
        //如果 pos 是 最後一個位置, 並且 outerFooter 有開啟即是 TYPE_OUTTER_FOOTER
        if indexPath.section == 0 && sectionGroup.outerHeader {

            cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID_OUTER_TOP, for: indexPath) as! MGBaseCollectionCell
            
            //如果正在休息, 跳過
            if (!loadtopHelper.isBreath && loadtopDelegate?.hasLoadtop() == true) {
                settingHeaderText(cell, isLoading: true)
                //如果正在加載置頂, 也跳過
                if (!loadtopHelper.isLoading) {
                    loadtopHelper.isLoading = true
                    //2018.9.4: 取消動畫更新, 一律靜態顯示
                    //因此也不需要延遲回調
                    bindOuterHeaderCell(cell, indexPath: indexPath)
                    self.loadtopDelegate?.startLoadtop()
//                    collectionView.performBatchUpdates(nil, completion: nil)
//                    timer.startCountdown(what: 0x1, byDelay: loadtopHelper.animDuration) {
//                        self.loadtopDelegate?.startLoadtop()
//                    }
                } else {
                    bindOuterHeaderCell(cell, indexPath: indexPath)
                }
            } else {
                settingHeaderText(cell, isLoading: false)
                bindOuterHeaderCell(cell, indexPath: indexPath)
            }

        } else if (indexPath.section == sectionGroup.getOuterSectionCount()-1) && sectionGroup.outerFooter {

            cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID_OUTER_BOTTOM, for: indexPath) as! MGBaseCollectionCell
            
            //如果正在休息, 跳過
            if (!loadmoreHelper.isBreath && loadmoreDelegate?.hasLoadmore() == true) {
                settingFooterText(cell, isLoading: true)
                //如果正在加載更多, 也跳過
                if (!loadmoreHelper.isLoading) {
                    loadmoreHelper.isLoading = true
                    //2018.9.4: 取消動畫更新, 一律靜態顯示
                    //因此也不需要延遲回調
                    bindOuterFooterCell(cell, indexPath: indexPath)
                    self.loadmoreDelegate?.startLoadmore()
//                    collectionView.performBatchUpdates(nil, completion: nil)
//                    timer.startCountdown(what: 0x2, byDelay: loadtopHelper.animDuration) {
//                        self.loadmoreDelegate?.startLoadmore()
//                    }
                } else {
                    bindOuterFooterCell(cell, indexPath: indexPath)
                }
            } else {
                settingFooterText(cell, isLoading: false)
                bindOuterFooterCell(cell, indexPath: indexPath)
            }

        } else {
            //先取得此位置的section
            let sectionData = sectionGroup.getSection(indexPath)
            if registerCells.contains(where: { $0.key == sectionData.cellType }) {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(sectionData.cellType)", for: indexPath) as! MGBaseCollectionCell
                cell.section = sectionData
                bindSectionCell(cell, indexPath: indexPath, section: sectionData)
            } else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: ID_EMPTY_BODY, for: indexPath) as! MGBaseCollectionCell
                cell.backgroundColor = UIColor.clear
            }
        }

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        var view: MGCollectionHeaderFooterReuseView? = nil
        switch kind {
        case UICollectionElementKindSectionHeader:
            //header的顯示回調
            //先取得此位置是否有header section
            if let header = sectionGroup.positionsHeaderCache[indexPath.section] {
                if registerHeaders.contains(where: { $0.key == header.type }),
                    let v = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind, withReuseIdentifier: "\(header.type)", for: indexPath
                        ) as? MGCollectionHeaderFooterReuseView {
                    v.header = header
                    bindSectionHeaderView(v, section: indexPath.section, header: header)
                }
            }
            break
        case UICollectionElementKindSectionFooter:
            //footer的顯示回調
            //先取得此位置是否有footer section
            if let footer = sectionGroup.positionsFooterCache[indexPath.section] {
                if registerFooters.contains(where: { $0.key == footer.type }),
                    let v = collectionView.dequeueReusableSupplementaryView(
                        ofKind: kind, withReuseIdentifier: "\(footer.type)", for: indexPath
                        ) as? MGCollectionHeaderFooterReuseView {
                    v.footer = footer
                    bindSectionFooterView(v, section: indexPath.section, footer: footer)
                }
            }
            break
        default: break
        }

        if view == nil {
            view = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind, withReuseIdentifier: ID_EMPTY_FOOTER, for: indexPath
                ) as? MGCollectionHeaderFooterReuseView
            view?.backgroundColor = UIColor.clear
        }
        return view!
    }

    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size: CGSize?

        //如果 pos 是 0, 並且 outerHeader 有開啟就是 TYPE_OUTTER_HEADER
        //如果 pos 是 最後一個位置, 並且 outerFooter 有開啟即是 TYPE_OUTTER_FOOTER
        if indexPath.section == 0 && sectionGroup.outerHeader {
            //先查看當前是處於置頂刷新狀態
            //2018.9.4: 取消動畫更新, 一律靜態顯示
//            if !loadtopHelper.isLoading { size = nil }
//            else { size = customOuterHeaderCellSize(indexPath) }
            size = customOuterHeaderCellSize(indexPath)
        } else if (indexPath.section == sectionGroup.getOuterSectionCount()-1) && sectionGroup.outerFooter {
            //先查看當前是處於置底 刷新狀態
            //2018.9.4: 取消動畫更新, 一律靜態顯示
//            if !loadmoreHelper.isLoading { size = nil }
//            else { size = customOuterFooterCellSize(indexPath) }
            size = customOuterFooterCellSize(indexPath)
        } else {
            //先取得此位置的section
            let sectionData = sectionGroup.getSection(indexPath)
            //判斷此section的type是否有被註冊, 沒有的話直接高度設置為0.01
            if !registerCells.contains(where: { $0.key == sectionData.cellType }) { size = nil }
            else { size = customSectionCellSize(indexPath, section: sectionData) }
        }

        //若回傳 CGSize.zero, 則下個cell會消失不見, 因此這邊傳入0.1
        return size ?? CGSize.init(width: 0.1, height: 0.1)
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        //先取得此位置是否有header section
        if let header = sectionGroup.positionsHeaderCache[section] {
            //有的話是否有自訂size
            if let size = customSectionHeaderSize(section, header: header) {
                return size
            } else {
                //暫時不知道當沒有自訂寬高時此處怎麼處理, 因此直接回傳zero
                return CGSize.zero
            }
        } else {
            return CGSize.zero
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        //先取得此位置是否有header section
        if let footer = sectionGroup.positionsFooterCache[section] {
            //有的話是否有自訂size
            if let size = customSectionFooterSize(section, footer: footer) {
                return size
            } else {
                //暫時不知道當沒有自訂寬高時此處怎麼處理, 因此直接回傳zero
                return CGSize.zero
            }
        } else {
            return CGSize.zero
        }
    }

    //設定置頂加載文字顯示
    private func settingHeaderText(_ cell: MGBaseCollectionCell, isLoading: Bool) {
//        if isLoading {
//            cell.label.text = "置頂加載中..."
//        } else {
//            cell.label.text = "已是最新"
//        }
    }
    
    //設定置頂加載文字顯示
    private func settingFooterText(_ cell: MGBaseCollectionCell, isLoading: Bool) {
//        if isLoading {
//            cell.label.text = "更多加載中..."
//        } else {
//            cell.label.text = "已無更多"
//        }
    }

}



//section相關操作
extension MGBaseCollectionAdapter : MGSectionDelegate {

    //設定擴展狀態
    public func setExpandStatusAndRefresh(_ section: MGSection, status: Bool) -> Int {
        let changeCount = setExpandStatus(section, status: status)
        let startIndex = IndexPath(row: section.absolatePos.row+1, section: section.absolatePos.section)

        if changeCount > 0 {
            insertMultipCell(startIndex, count: changeCount)
        } else if changeCount < 0 {
            deleteMultipCell(startIndex, count: abs(changeCount))
        }
        return changeCount
    }

    public func setExpandStatus(_ section: MGSection, status: Bool) -> Int {
        return sectionGroup.setExpandStatus(section.position, status: status)
    }

    public func getExpandStatus(_ section: MGSection) -> Bool {
        return sectionGroup.getExpandStatus(section.position)
    }

    //插入section, 使用動畫(功能尚未完成)
    public func insertSectionAndRefresh(_ pos: MGSectionPos, type: Int, count: Int) {
        //        <#code#>
    }

    //加入section到最後, 使用動畫
    public func appendSectionAndRefresh(_ depth: Int, type: Int, count: Int) {
        //        sectionGroup.addSections(count, type)
        //        tableView.
    }

    //加入到某個section的child
    public func appendChildSectionAndRefresh(_ inSection: MGSection, type: Int, count: Int) {
        let startPos = sectionGroup.appendSectionChildAndRebuild(inSection, type: type, count: count)
        insertMultipCell(startPos, count: count)
    }

    //加入多個cell
    private func insertMultipCell(_ start: IndexPath, count: Int) {
        var inserIndexPaths: [IndexPath] = []
        for i in 0..<count {
            let insert = IndexPath(row: start.row+i, section: start.section)
            inserIndexPaths.append(insert)
        }
        collectionView.insertItems(at: inserIndexPaths)
    }

    //刪除多個cell
    private func deleteMultipCell(_ start: IndexPath, count: Int) {
        var deleteIndexPaths: [IndexPath] = []
        for i in 0..<count {
            let delete = IndexPath(row: start.row+i, section: start.section)
            deleteIndexPaths.append(delete)
        }
        collectionView.deleteItems(at: deleteIndexPaths)
    }

    //移除section, 使用動畫
    public func removeSectionAndRefresh(_ pos: MGSectionPos) {
        let startPos = sectionGroup.removeSectionAndRebuild(pos)
        if let start = startPos {
            if sectionGroup.getAllCount() == 0 {
                collectionView.reloadData()
            } else {
                collectionView.deleteItems(at: [start])
            }
        }
    }

    //刷新某個item, 帶入sectionPos
    public func refreshSection(_ pos: MGSectionPos) {
        let section = sectionGroup.getSection(pos)
        if let find = section { collectionView.reloadItems(at: [find.absolatePos]) }
    }

    //尋找上個同深度的節點
    public func findPreNode(_ section: MGSection) -> MGSection? {
        let pos = section.position
        pos.value[pos.value.count-1] -= 1
        return sectionGroup.getSection(pos)
    }

    //從 itemView 找出完整的位置
    public func findPosition(_ byView: UIView) -> MGSectionPos? {
        return findSection(byView)?.position
    }

    //從 itemView 找出 section
    public func findSection(_ byView: UIView) -> MGSection? {
        var findCell: MGBaseCollectionCell?
        _ = collectionView.visibleCells.contains { cell in
            if findAllView(byView, inView: cell) {
                findCell = cell as? MGBaseCollectionCell
                return true
            } else {
                return false
            }
        }
        return findCell?.section
    }

    //尋找某個view
    private func findAllView(_ find: UIView, inView: UIView) -> Bool {
        if find == inView { return true }
        else {
            for v in inView.subviews where findAllView(find, inView: v) {
                return true
            }
        }
        return false
    }

    public func quickSetSection(_ count: Int, type: Int?) {
        if type == nil { sectionGroup.setSections(count) }
        else { sectionGroup.setSections(count, type: type!) }
    }

    public func cleanSection() {
        sectionGroup.cleanSection()
    }

    public func cleanPosCache() {
        sectionGroup.clearCache()
    }

    public func addSection(_ section: MGSection, header: Int?, footer: Int?) {
        sectionGroup.addSection(section, header: header, footer: footer)
    }

    public func appendChildSection(_ inSection: MGSection, type: Int, count: Int) {
        sectionGroup.appendSectionChild(inSection, type: type, count: count)
    }

    public func setOuterHolder(_ top: Bool, bottom: Bool) {
        sectionGroup.outerHeader = top
        sectionGroup.outerFooter = bottom
    }

    //得到section組成的結構字串
    public func getSectionStruct() -> String {
        return sectionGroup.getSectionStructText()
    }
}

//table綁定資料相關
public protocol MGBaseCollectionDataBindDelegate {
    //同步顯示某個section的header
    func bindSectionHeaderView(_ view: MGCollectionHeaderFooterReuseView, section: Int, header: MGSectionGroup.MGSectionHeader)

    //同步顯示某個section的footer
    func bindSectionFooterView(_ view: MGCollectionHeaderFooterReuseView, section: Int, footer: MGSectionGroup.MGSectionFooter)

    //同步顯示某個cell
    func bindSectionCell(_ cell: MGBaseCollectionCell, indexPath: IndexPath, section: MGSection)

    //同步顯示最外層(置頂加載)
    func bindOuterHeaderCell(_ cell: MGBaseCollectionCell, indexPath: IndexPath)

    //同步顯示最外層(置底加載)
    func bindOuterFooterCell(_ cell: MGBaseCollectionCell, indexPath: IndexPath)
}

//table高度相關
public protocol MGBaseCollectionCustomSizeDelegate {
    //是否自定義某個cell的高度
    func customSectionCellSize(_ indexPath: IndexPath, section: MGSection) -> CGSize?
    //是否自定義最外層頂部cell的高度
    func customOuterHeaderCellSize(_ indexPath: IndexPath) -> CGSize?
    //是否自定義最外層底下cell的高度
    func customOuterFooterCellSize(_ indexPath: IndexPath) -> CGSize?
    //是否自定義section header的高度
    func customSectionHeaderSize(_ section: Int, header: MGSectionGroup.MGSectionHeader) -> CGSize?
    //是否自定義section footer的高度
    func customSectionFooterSize(_ section: Int, footer: MGSectionGroup.MGSectionFooter) -> CGSize?
}


