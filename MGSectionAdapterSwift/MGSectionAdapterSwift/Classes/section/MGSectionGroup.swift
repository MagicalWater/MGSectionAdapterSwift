//
//  MGSectionGroup.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/12.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import MGUtilsSwift
import MGExtensionSwift

public class MGSectionGroup {

    //統稱為 body, body 內部又分成多個 type, 用途為指定不同的ViewHolder
    var sections: [MGSection] = []

    //與 sections 的 sort 位置相對應
    //第一層擁有 header 的 section
    //這個header的位置要與 body 所戴的位置tag一模一樣
    var headers: [MGSectionHeader?] = []

    //與 sections 的 sort 位置相對應
    //第一層擁有 footer 的 section
    var footers: [MGSectionFooter?] = []


    //每個位置對應到的 MGSection 快取表
    var positionsSectionCache: [IndexPath:MGSection] = [:]

    //每個位置對應到的 ViewType 快取表, 這邊只儲存 header 跟 footer 的部分
    //因為 body的部分在 positionsSectionCache 裡面了
    var positionsHeaderCache: [Int:MGSectionHeader] = [:]

    var positionsFooterCache: [Int:MGSectionFooter] = [:]

    /**
     * 默認全展開, 這邊儲存有經過設定的 list
     * 之所以不放在 MGSection 裡面是因為 MGSection 對應的 位置可能經常發生改變
     * 這樣的話縮合的絕對位置就不准了
     * 並且此項只影響到item count, 統一管理數量的是 MGSectionGroup
     * 因此放到這裡統一管理
     * 不可直接設定擴展到這裡
     * */
    private var expandStatus: [MGSectionPos:Bool] = [:]


    //最外層的 header, 用途: 加載最新
    var outerHeader: Bool = false

    //最外層的 footer, 用途: 加載更多
    var outerFooter: Bool = false


    /**
     * 以下方法皆是直接加入section, 並不會對adapter產生更新動畫
     * */
    func addSection(_ section: MGSection, header: Int? = nil, footer: Int? = nil) {
        let row = sections.count
        sections.append(section)
        section.row = row
        section.absolatePos = IndexPath(row: row, section: 0)

        if header == nil { headers.append(nil) }
        else { headers.append( MGSectionHeader(row, type: header!) ) }

        if (footer == nil) { footers.append(nil) }
        else { footers.append( MGSectionFooter(row, type: footer!) ) }

        //加入section後, 快取的設定值會變更, 所以一率將快取設定移除
        clearCache()
    }

    //直接設定section count
    func setSections(_ count: Int, type: Int = MGBaseTableAdapter.TYPE_BODY) {
        let sectionsCount = sections.count
        if (sectionsCount > count) {
            for i in (0..<sectionsCount-count).reversed() {
                sections.remove(at: i)
                headers.remove(at: i)
                footers.remove(at: i)
            }
        } else if (sectionsCount < count) {
            for _ in 0..<count-sectionsCount {
                let section = MGSection()
                sections.append(section)
                headers.append(nil)
                footers.append(nil)
                section.row = sections.count - 1
                section.absolatePos = IndexPath(row: sections.count - 1, section: 0)
            }
        }

        sections.forEach {
            $0.cellType = type
        }
        //加入section後, 快取的設定值會變更, 所以一率將快取設定移除
        clearCache()
    }

    //直接寫入加入多少個一樣type的section
    func addSections(_ count: Int, type: Int = MGBaseTableAdapter.TYPE_BODY) {
        for _ in 0..<count {
            let section = MGSection()
            sections.append(section)
            headers.append(nil)
            footers.append(nil)
            section.row = sections.count - 1
            section.absolatePos = IndexPath(row: sections.count - 1, section: 0)
        }

        sections.forEach { $0.cellType = type }

        //加入section後, 快取的設定值會變更, 所以一率將快取設定移除
        clearCache()
    }


    //加入某個子section
    func appendSectionChild(_ inSection: MGSection, type: Int, count: Int) {
        for _ in 0..<count {
            let section = MGSection(type)
            inSection.addChild(section)
        }
    }

    //直接設定child在某個section之下
    func setSectionChild(_ count: Int, childType: Int, inSection: MGSection) {
        let sectionsCount = inSection.childCount
        if (sectionsCount > count) {
            for i in (0..<sectionsCount-count).reversed() {
                inSection.removeChild(i)
            }
        } else if (sectionsCount < count){
            for _ in 0..<count-sectionsCount {
                let section = MGSection()
                inSection.addChild(section)
                section.row = sections.count - 1
            }
        }

        //將所有section都改為特定的type
        inSection.child.forEach {
            $0.cellType = childType
        }
    }

    /**
     * 以上方法皆是直接加入section, 並不會對adapter產生更新動畫
     * */


    //設定擴展狀態, 回傳此項擴展改變會增加/減少多少個row
    func setExpandStatus(_ pos: MGSectionPos, status: Bool) -> Int {
        //先檢查狀態是否不同, 不同才需要做相應的動作
        if (expandStatus[pos] ?? true == status) {
            //相同, 不須更改, 直接回傳
            return 0
        }

        expandStatus[pos] = status

        //找出狀態變更的第一個節點並往下傳, 回傳的是此次狀態改變共增加/減少多少個row
        let changeCount = sections[pos.value[0]].setExpandStatus(pos, status: status)

        //清除所有位置的快取, 如果無影響則不用清除
        if (changeCount != 0) {
            clearCache()
            buildPosCache()
        }

        return changeCount
    }

    //得到某個位置的擴展狀態
    func getExpandStatus(_ pos: MGSectionPos) -> Bool {
        return expandStatus[pos] ?? true
    }


    //加入多少section到某個位置, 產生insert動畫
    func insertSectionAndRebuild(_ pos: MGSectionPos, type: Int, count: Int) {
        if (pos.value.count == 1) {
            //代表是加入到根節點, 直接加入section到sections即可
            var addSections: [MGSection] = []
            var addHolders: [MGSectionHeader?] = []
            var addFooters: [MGSectionFooter?] = []
            for _ in 0..<count {
                let section = MGSection(type)
                addSections.append(section)
                addHolders.append(nil)
                addFooters.append(nil)
            }
            sections.insert(contentsOf: addSections, at: pos.value[0]+1)
            headers.insert(contentsOf: addHolders, at: pos.value[0]+1)
            footers.insert(contentsOf: addFooters, at: pos.value[0]+1)
            
            resortSectionRow()
            clearCache()
            buildPosCache()
        }
    }
    
    //回傳新增的絕對位置從哪邊開始
    func appendSectionChildAndRebuild(_ inSection: MGSection, type: Int, count: Int) -> IndexPath {
        var lastSection: MGSection?
        if inSection.child.isEmpty { lastSection = nil }
        else { lastSection = inSection.child.last }

        for _ in 0..<count {
            let section = MGSection(type)
            inSection.addChild(section)
        }

        //找到最外層的爸爸的row, 則代表第幾個外層section


        resortSectionRow()
        clearCache()
        buildPosCache()

        if lastSection != nil { return lastSection!.absolatePos }
        else { return inSection.absolatePos }
    }


    //回傳移除的絕對位置, 從哪邊開始, 目前只能移除一筆
    func removeSectionAndRebuild(_ pos: MGSectionPos) -> IndexPath? {
        let s = getSection(pos)

        guard let section = s else {
            return nil
        }
        //檢查是否有father, 沒有代表是根, 直接在此頁面的位置移除
        let absolateIndex = section.absolatePos
        let row = section.row
        let father = section.father
        if father != nil {
            father!.removeChild(row)
        } else {
            sections.remove(at: row)
            headers.remove(at: row)
            footers.remove(at: row)
        }

        resortSectionRow()
        clearCache()
        buildPosCache()

        return absolateIndex
    }

    //重新排序所有section的row
    private func resortSectionRow() {
        sections.forEachIndexed { index, value in
            value.row = index
            value.resortChild()
        }
    }

    func cleanSection() {
        sections.removeAll()
        headers.removeAll()
        footers.removeAll()
        clearCache()
    }

    //平鋪後 body 的 type
    func getSection(_ pos: IndexPath) -> MGSection {
        //先從pos.section取出是第外層第幾個section
        //再從row得到section真正的位置
        return positionsSectionCache[pos]!
    }

    func getSection(_ position: MGSectionPos) -> MGSection? {
        var searchSections = sections[position.value[0]]
        for i in 1..<position.value.count {
            searchSections = searchSections.child[position.value[i]]
        }
        return searchSections
    }


    func clearCache() {
        positionsSectionCache.removeAll()
        positionsHeaderCache.removeAll()
        positionsFooterCache.removeAll()
    }

    //雖然顯示上有分組的感覺, 但實際上只有1層平鋪
    //在獲得total數量時, 就將 item 的對應表做起
    //除非之後的sections或者headers有所變動, 否則直接快取
    //假如除了 outerheader 跟 outerfooter之外為空, 則直接回傳0
    func getAllCount() -> Int {

        var outerAdd = 0
        if outerHeader { outerAdd += 1 }
        if outerFooter { outerAdd += 1 }

        if (sections.count > 0 && positionsSectionCache.isEmpty) {
            buildPosCache()
        }

        let count = positionsSectionCache.count + positionsHeaderCache.count + positionsFooterCache.count
        if count == 0 { return 0 }

        return count + outerAdd
    }


    //得到某個最外節點下的seciton數量
    func getInnerSectionCount(_ index: Int) -> Int {
        return sections[index].getAllSection().count
    }

    //得到所有所有第一層section的數量
    //與android不一樣的地方在於有兩層, 而android只有一層平鋪
    //ios的外層header跟footer也已經拆開, 因此可不計算在外層數量內
    func getOuterSectionCount() -> Int {
        var outerAdd = 0
        if outerHeader { outerAdd += 1 }
        if outerFooter { outerAdd += 1 }

        if (sections.count > 0 && positionsSectionCache.isEmpty) {
            buildPosCache()
        }

        let count = sections.count
        //假如count為0, 那麼outerAdd也就不加入計算
        //畢竟主體是body
        if count == 0 { return 0}
        return count + outerAdd
    }


    //建立所有位置的快取, 初次建立時需要將擴展狀態設置給 expandStatus
    private func buildPosCache() {
        let num = outerHeader ? 1 : 0

        for i in 0..<sections.count {

            if (headers[i] != nil) {
                positionsHeaderCache[i+num] = headers[i]!
            }

            var row = 0
            for innerS in sections[i].getAllSection() {
                let indexPath = IndexPath(row: row, section: i+num)
                innerS.absolatePos = indexPath
                positionsSectionCache[indexPath] = innerS
                row += 1
            }

            if (footers[i] != nil) {
                positionsFooterCache[i+num] = footers[i]!
            }
        }
        syncExpandStatus()
    }


    //將section的擴展狀態同步給 expandStatus
    private func syncExpandStatus() {
        expandStatus.removeAll()
        var lists: [MGSectionPos] = []
        sections.forEach {
            lists += $0.getExpandStatusList(false)
        }
        lists.forEach {
            expandStatus[$0] = false
        }
    }

    //將sections的結構轉為json字串
    func getSectionStructText() -> String {
        clearCache()
        buildPosCache()
        var infos: [[String:Any]] = []
        if outerHeader {

        }
        sections.forEach {
            infos.append($0.getSectionStruct())
        }
        
        let s = MGJsonUtils.serializeString(infos) ?? ""
        return s
    }

    public struct MGSectionHeader {
        public let row: Int
        public let type: Int

        init(_ row: Int, type: Int) {
            self.row = row
            self.type = type
        }
    }

    public struct MGSectionFooter {
        public let row: Int
        public let type: Int

        init(_ row: Int, type: Int) {
            self.row = row
            self.type = type
        }
    }

}
