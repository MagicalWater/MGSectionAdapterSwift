//
//  MGBaseAdapter.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/12.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit
import MGUtilsSwift
import MGViewsSwift

open class MGBaseTableAdapter: MGBaseScrollAdapter, MGBaseTableDataBindDelegate, MGBaseTableCustomHeightDelegate {


    public static let TYPE_OUTTER_HEADER = -1001
    public static let TYPE_OUTTER_FOOTER = -1002
    public static let TYPE_BODY = -1003
    public static let TYPE_BLANK = -1004

    public var tableView: UITableView

    //已註冊的cell, header, footer
    private var registerCells: [Int:UINib] = [:]
    private var registerHeaders: [Int:UINib] = [:]
    private var registerFooters: [Int:UINib] = [:]

    private let ID_OUTER_TOP: String = "ID_OUTER_TOP"
    private let ID_OUTER_BOTTOM: String = "ID_OUTER_BOTTOM"
    private let ID_EMPTY_BODY: String = "ID_EMPTY_BODY"
    private let ID_EMPTY_HEADER_FOOTER: String = "ID_EMPTY_HEADER_FOOTER"

    //緩存每一個cell的heigth, 為了讓每次給出的大概高度接近真實
    //同時預防 https://www.jianshu.com/p/64f0e1557562 最後面說的點擊了狀態欄之後無法滾動到最上方的問題
    private var tempCellHeight: [IndexPath:CGFloat] = [:]
    private var tempHeaderHeight: [Int:CGFloat] = [:]
    private var tempFooterHeight: [Int:CGFloat] = [:]

    //配置所有cell type的物件
    private var sectionGroup: MGSectionGroup = MGSectionGroup()

    //置頂加載跟置底加載
    private var loadmoreHelper: MGLoadmoreHelper = MGLoadmoreHelper()
    private var loadtopHelper: MGLoadtopHelper = MGLoadtopHelper()

    //底部加載
    weak public var loadmoreDelegate: MGLoadmoreDelegate?

    //頂部加載
    weak public var loadtopDelegate: MGLoadtopDelegate?

    private var timer: MGTimerUtils = MGTimerUtils()

    //當table資料為空時顯示的文字
    public var emptyText: String = "無資料存在"

    public init(_ tableView: UITableView) {
        self.tableView = tableView
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100;
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 100;
        self.tableView.sectionFooterHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionFooterHeight = 100;
        self.tableView.register(MGBaseHeaderFooterTableCell.self, forCellReuseIdentifier: ID_OUTER_TOP)
        self.tableView.register(MGBaseHeaderFooterTableCell.self, forCellReuseIdentifier: ID_OUTER_BOTTOM)
        self.tableView.register(MGBaseTableCell.self, forCellReuseIdentifier: ID_EMPTY_BODY)
        self.tableView.register(MGBaseTableCell.self, forCellReuseIdentifier: "\(MGBaseTableAdapter.TYPE_BODY)")
        self.tableView.register(MGTableHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "\(ID_EMPTY_HEADER_FOOTER)")
        super.init()
    }

    //註冊cell
    public func registerCell(_ cell: UINib, type: Int) {
        registerCells[type] = cell
        tableView.register(cell, forCellReuseIdentifier: "\(type)")
    }

    //註冊header view
    public func registerHeaderView(_ headerView: UINib, type: Int) {
        registerHeaders[type] = headerView
        tableView.register(headerView, forHeaderFooterViewReuseIdentifier: "\(type)")
    }

    //註冊footer view
    public func registerFooterView(_ footerView: UINib, type: Int) {
        registerFooters[type] = footerView
        tableView.register(footerView, forHeaderFooterViewReuseIdentifier: "\(type)")
    }

    //開始載入資料
    public func startLoadData() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
    }


    //重新載入所有table資料
    public func reloadData() {
        //重新載入資料
        tableView.reloadData()
    }

    //同步顯示最外層(置頂加載, 複寫可更改樣式)
    open func bindOuterHeaderCell(_ cell: MGBaseHeaderFooterTableCell, indexPath: IndexPath) {
        cell.label.text = "為您加載..."
        cell.label.textColor = UIColor.black
    }

    //同步顯示最外層(置底加載, 複寫可更改樣式)
    open func bindOuterFooterCell(_ cell: MGBaseHeaderFooterTableCell, indexPath: IndexPath) {
        cell.label.text = "加載更多..."
        cell.label.textColor = UIColor.black
    }

    //同步顯示某個section的header
    open func bindSectionHeaderView(_ view: MGTableHeaderFooterView, section: Int, header: MGSectionGroup.MGSectionHeader) { }

    //同步顯示某個section的footer
    open func bindSectionFooterView(_ view: MGTableHeaderFooterView, section: Int, footer: MGSectionGroup.MGSectionFooter) { }

    //同步顯示某個section
    open func bindSectionCell(_ cell: MGBaseTableCell, indexPath: IndexPath, section: MGSection) {}



    //****************** MGBaseTableCustomHeightDelegate ******************

    func customSectionCellHeight(_ indexPath: IndexPath, section: MGSection) -> CGFloat? {
        return nil
    }

    //是否自定義最外層頂部cell的高度
    func customOuterHeaderCellHeight(_ indexPath: IndexPath) -> CGFloat? {
        return nil
    }

    //是否自定義最外層底下cell的高度
    func customOuterFooterCellHeight(_ indexPath: IndexPath) -> CGFloat? {
        return nil
    }

    //是否自定義section header的高度
    func customSectionHeaderHeight(_ section: Int, header: MGSectionGroup.MGSectionHeader) -> CGFloat? {
        return nil
    }

    //是否自定義section footer的高度
    func customSectionFooterHeight(_ section: Int, footer: MGSectionGroup.MGSectionFooter) -> CGFloat? {
        return nil
    }

    //****************** MGBaseTableCustomHeightDelegate ******************

    //內容是否為空(決定是否顯示空內容文字)
    open func isBodyEmpty() -> Bool {
        return false
    }

    //加載更多結束時需要手動呼叫此方法, 讓adapter知道已經加載完了
    public func endLoadmore() {
        loadmoreHelper.isLoading = false
    }

    //加載更多後, 需要休息呼叫此方法
    public func breathLoadmore(_ breath: Bool) {
        loadmoreHelper.isBreath = breath
    }

    //加載置頂結束時需要手動呼叫此方法, 讓adapter知道已經加載完了
    public func endLoadtop() {
        loadtopHelper.isLoading = false
    }

    //加載置頂後, 需要休息呼叫此方法
    public func breathLoadtop(_ breath: Bool) {
        loadtopHelper.isBreath = breath
    }

}


extension MGBaseTableAdapter: UITableViewDelegate, UITableViewDataSource {

    //某個cell的高度, 如果沒有自定義就是讓系統自行計算
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat?
        if indexPath.section == 0 && sectionGroup.outerHeader {
            //先查看當前是處於置頂刷新狀態
            if !loadtopHelper.isLoading { height = 0.01 }
            else { height = customOuterHeaderCellHeight(indexPath) ?? 60 }
        } else if (indexPath.section == sectionGroup.getOuterSectionCount()-1) && sectionGroup.outerFooter {
            if !loadmoreHelper.isLoading { height = 0.01 }
            else { height = customOuterFooterCellHeight(indexPath) ?? 60 }
        } else {
            //先取得此位置的section
            let sectionData = sectionGroup.getSection(indexPath)

            //判斷此section的type是否有被註冊, 沒有的話直接高度設置為0.01
            if !registerCells.contains(where: { $0.key == sectionData.cellType }) { height = 0.01 }
            else { height = customSectionCellHeight(indexPath, section: sectionData) }
        }
        return height ?? UITableViewAutomaticDimension
    }

    //讓系統自行計算高度給出系統一個估略值
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        //先檢查是否有緩存
        if let tempHeight = tempCellHeight[indexPath] {
            return tempHeight
        }
        return 100
    }

    //與上方相同, section的header跟footer的高度
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //先檢查此位置是否有header存在
        if let header = sectionGroup.positionsHeaderCache[section]{
            return customSectionHeaderHeight(section, header: header) ?? UITableViewAutomaticDimension
        } else {
            return 0.01
        }
    }

    //讓系統自行計算高度給出系統一個估略值
    public func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        //先檢查是否有緩存
        if let tempHeight = tempHeaderHeight[section] {
            return tempHeight
        }
        return 100
    }

    //同上, footer
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        //先檢查此位置是否有footer存在
        if let footer = sectionGroup.positionsFooterCache[section] {
            return customSectionFooterHeight(section, footer: footer) ?? UITableViewAutomaticDimension
        } else {
            return 0.01
        }
    }

    //讓系統自行計算高度給出系統一個估略值
    public func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        //先檢查是否有緩存
        if let tempHeight = tempFooterHeight[section] {
            return tempHeight
        }
        return 100
    }

    //得到共有多少個外部section
    public func numberOfSections(in tableView: UITableView) -> Int {
        let count = sectionGroup.getOuterSectionCount()

        //根據數據內容是否為空顯示資料為空字樣
        if let emptyTable = tableView as? MGTableViewEmptySupport {
            emptyTable.emptyLabel.text = isBodyEmpty() ? emptyText : nil
        }

        return count
    }


    //得到某個section下的總數量
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 && sectionGroup.outerHeader {
            return 1
        } else if (section == sectionGroup.getOuterSectionCount()-1) && sectionGroup.outerFooter {
            return 1
        } else {
            if sectionGroup.outerHeader {
                return sectionGroup.getInnerSectionCount(section-1)
            } else {
                return sectionGroup.getInnerSectionCount(section)
            }
        }
    }

    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view: UITableViewHeaderFooterView? = nil
        //先取得此位置是否有header section
        if let header = sectionGroup.positionsHeaderCache[section] {

            if registerHeaders.contains(where: { $0.key == header.type }),
                let v = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(header.type)") as? MGTableHeaderFooterView {
                v.header = header
                bindSectionHeaderView(v, section: section, header: header)
                tempHeaderHeight[section] = v.frame.height
            } else {
                view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ID_EMPTY_HEADER_FOOTER)
                view!.backgroundColor = UIColor.clear
            }

        }
        return view
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //先取得此位置是否有footer section
        var view: UITableViewHeaderFooterView? = nil
        if let footer = sectionGroup.positionsFooterCache[section] {

            if registerFooters.contains(where: { $0.key == footer.type }),
                let v = tableView.dequeueReusableHeaderFooterView(withIdentifier: "\(footer.type)") as? MGTableHeaderFooterView {
                v.footer = footer
                bindSectionFooterView(v, section: section, footer: footer)
                tempFooterHeight[section] = v.frame.height
            } else {
                view = tableView.dequeueReusableHeaderFooterView(withIdentifier: ID_EMPTY_HEADER_FOOTER)
                view!.backgroundColor = UIColor.clear
            }

        }
        return view
    }

    //依照cell的類型, 從繼承此類別的子類別獲取cell
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: MGBaseTableCell
        //如果 pos 是 0, 並且 outerHeader 有開啟就是 TYPE_OUTTER_HEADER
        //如果 pos 是 最後一個位置, 並且 outerFooter 有開啟即是 TYPE_OUTTER_FOOTER
        if indexPath.section == 0 && sectionGroup.outerHeader {

//            cell = tableView.dequeueReusableCell(withIdentifier: ID_OUTER_TOP) as! MGBaseHeaderFooterTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: ID_OUTER_TOP, for: indexPath) as! MGBaseHeaderFooterTableCell
            cell.backgroundColor = UIColor.clear
            bindOuterHeaderCell(cell as! MGBaseHeaderFooterTableCell, indexPath: indexPath)

            //如果正在休息, 跳過
            if (!loadtopHelper.isBreath && loadtopDelegate?.hasLoadtop() == true) {
                //如果正在加載置頂, 也跳過
                if (!loadtopHelper.isLoading) {
                    loadtopHelper.isLoading = true
//                    tableView.beginUpdates()
//                    tableView.endUpdates()
                    reloadData()
                    timer.startCountdown(what: 0x1, byDelay: loadtopHelper.animDuration) {
                        self.loadtopDelegate?.startLoadtop()
                    }
                }
            }

        } else if (indexPath.section == sectionGroup.getOuterSectionCount()-1) && sectionGroup.outerFooter {

//            cell = tableView.dequeueReusableCell(withIdentifier: ID_OUTER_BOTTOM) as! MGBaseHeaderFooterTableCell
            cell = tableView.dequeueReusableCell(withIdentifier: ID_OUTER_BOTTOM, for: indexPath) as! MGBaseHeaderFooterTableCell
            cell.backgroundColor = UIColor.clear
            bindOuterFooterCell(cell as! MGBaseHeaderFooterTableCell, indexPath: indexPath)

            //如果正在休息, 跳過
            if (!loadmoreHelper.isBreath && loadmoreDelegate?.hasLoadmore() == true) {
                //如果正在加載更多, 也跳過
                if (!loadmoreHelper.isLoading) {
                    loadmoreHelper.isLoading = true
                    tableView.beginUpdates()
                    tableView.endUpdates()
                    timer.startCountdown(what: 0x2, byDelay: loadtopHelper.animDuration) {
                        self.loadmoreDelegate?.startLoadmore()
                    }
                }
            }

        } else {
            //先取得此位置的section
            let sectionData = sectionGroup.getSection(indexPath)
            if registerCells.contains(where: { $0.key == sectionData.cellType }) {
                cell = tableView.dequeueReusableCell(
                    withIdentifier: "\(sectionData.cellType)",
                    for: indexPath
                    ) as! MGBaseTableCell
                cell.section = sectionData
                bindSectionCell(cell, indexPath: indexPath, section: sectionData)
            } else {
                cell = tableView.dequeueReusableCell(withIdentifier: ID_EMPTY_BODY, for: indexPath) as! MGBaseTableCell
                cell.backgroundColor = UIColor.clear
            }
            //將得到cell的高度進行緩存
            tempCellHeight[indexPath] = cell.frame.height
        }
        return cell
    }
}

//section相關操作
extension MGBaseTableAdapter : MGSectionDelegate {

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
        fatalError("功能尚未完全")
    }

    //加入section到最後, 使用動畫
    public func appendSectionAndRefresh(_ depth: Int, type: Int, count: Int) {
        fatalError("功能尚未完全")
//        sectionGroup.addSections(count, type)
//        tableView.
    }

    //加入到某個section的child
    public func appendChildSectionAndRefresh(_ inSection: MGSection, type: Int, count: Int) {
        let startPos = sectionGroup.appendSectionChildAndRebuild(inSection, type: type, count: count)
        let appendStartPos = IndexPath.init(row: startPos.row+1, section: startPos.section)
        insertMultipCell(appendStartPos, count: count)
    }

    //加入多個cell
    private func insertMultipCell(_ start: IndexPath, count: Int) {
        var inserIndexPaths: [IndexPath] = []
        for i in 0..<count {
            let insert = IndexPath(row: start.row+i, section: start.section)
            inserIndexPaths.append(insert)
        }
        tableView.insertRows(at: inserIndexPaths, with: .automatic)
    }

    //刪除多個cell
    private func deleteMultipCell(_ start: IndexPath, count: Int) {
        var deleteIndexPaths: [IndexPath] = []
        for i in 0..<count {
            let delete = IndexPath(row: start.row+i, section: start.section)
            deleteIndexPaths.append(delete)
        }
        tableView.deleteRows(at: deleteIndexPaths, with: .automatic)
    }

    //移除section, 使用動畫
    public func removeSectionAndRefresh(_ pos: MGSectionPos) {
        let startPos = sectionGroup.removeSectionAndRebuild(pos)
        if let start = startPos {
            if sectionGroup.getAllCount() == 0 {
                tableView.reloadData()
            } else {
                tableView.deleteRows(at: [start], with: .automatic)
            }
        }
    }

    //刷新某個item, 帶入sectionPos
    public func refreshSection(_ pos: MGSectionPos) {
        let section = sectionGroup.getSection(pos)
        if let find = section { tableView.reloadRows(at: [find.absolatePos], with: UITableViewRowAnimation.automatic) }
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
        var findCell: MGBaseTableCell?
        _ = tableView.visibleCells.contains { cell in
            if findAllView(byView, inView: cell) {
                findCell = cell as? MGBaseTableCell
                return true
            } else {
                return false
            }
        }
        return findCell?.section
    }

    public func findCell<T: MGBaseTableCell>(_ bySection: MGSection) -> T? {
        return tableView.cellForRow(at: bySection.absolatePos) as? T
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
public protocol MGBaseTableDataBindDelegate {


    //同步顯示某個section的header
    func bindSectionHeaderView(_ view: MGTableHeaderFooterView, section: Int, header: MGSectionGroup.MGSectionHeader)

    //同步顯示某個section的footer
    func bindSectionFooterView(_ view: MGTableHeaderFooterView, section: Int, footer: MGSectionGroup.MGSectionFooter)

    //同步顯示某個cell
    func bindSectionCell(_ cell: MGBaseTableCell, indexPath: IndexPath, section: MGSection)

    //同步顯示最外層(置頂加載)
    func bindOuterHeaderCell(_ cell: MGBaseHeaderFooterTableCell, indexPath: IndexPath)

    //同步顯示最外層(置底加載)
    func bindOuterFooterCell(_ cell: MGBaseHeaderFooterTableCell, indexPath: IndexPath)
}


//extension MGBaseTableDataBindDelegate {
//    //同步顯示某個section的header
//    public func bindSectionHeaderView(_ section: Int, header: MGSectionGroup.MGSectionHeader) -> UIView? {
//        return nil
//    }
//
//    //同步顯示某個section的footer
//    public func bindSectionFooterView(_ section: Int, footer: MGSectionGroup.MGSectionFooter) -> UIView? {
//        return nil
//    }
//
//    //同步顯示某個section
//    public func bindSectionCell(_ cell: MGBaseTableCell, indexPath: IndexPath, section: MGSection) {}
//}




//table高度相關
protocol MGBaseTableCustomHeightDelegate {
    //是否自定義某個cell的高度
    func customSectionCellHeight(_ indexPath: IndexPath, section: MGSection) -> CGFloat?

    //是否自定義最外層頂部cell的高度
    func customOuterHeaderCellHeight(_ indexPath: IndexPath) -> CGFloat?

    //是否自定義最外層底下cell的高度
    func customOuterFooterCellHeight(_ indexPath: IndexPath) -> CGFloat?

    //是否自定義section header的高度
    func customSectionHeaderHeight(_ section: Int, header: MGSectionGroup.MGSectionHeader) -> CGFloat?

    //是否自定義section footer的高度
    func customSectionFooterHeight(_ section: Int, footer: MGSectionGroup.MGSectionFooter) -> CGFloat?
}

//extension MGBaseTableCustomHeightDelegate {
//    //是否自定義某個cell的高度
//    func customSectionCellHeight(_ indexPath: IndexPath, section: MGSection) -> CGFloat? {
//        return nil
//    }
//
//    //是否自定義最外層頂部cell的高度
//    func customOuterHeaderCellHeight(_ indexPath: IndexPath) -> CGFloat? {
//        return nil
//    }
//
//    //是否自定義最外層底下cell的高度
//    func customOuterFooterCellHeight(_ indexPath: IndexPath) -> CGFloat? {
//        return nil
//    }
//
//    //是否自定義section header的高度
//    func customSectionHeaderHeight(_ section: Int, header: MGSectionGroup.MGSectionHeader) -> CGFloat? {
//        return nil
//    }
//
//    //是否自定義section footer的高度
//    func customSectionFooterHeight(_ section: Int, footer: MGSectionGroup.MGSectionFooter) -> CGFloat? {
//        return nil
//    }
//}



