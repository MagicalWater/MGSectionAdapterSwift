//
//  MGTextTabLayout.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/19.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit

//仿照android的tabLatout, 實際上就是一個CollectionView, 但使用tab的方式進行封裝
@IBDesignable public class MGTextTabLayout: UIView {

    @IBInspectable public var normalTextColor: UIColor = UIColor.white {
        didSet { if oldValue != normalTextColor { collectionView.reloadData() } }
    }

    @IBInspectable public var highlightTextColor: UIColor = UIColor.white {
        didSet { if oldValue != highlightTextColor { collectionView.reloadData() } }
    }

    @IBInspectable public var lineColor: UIColor = UIColor.white {
        didSet { if oldValue != lineColor { syncFlagViewAttr() } }
    }

    @IBInspectable public var textSize: CGFloat = 15 {
        didSet { if oldValue != textSize { collectionView.reloadData() } }
    }

    //文字塞入空格
    @IBInspectable public var textSpace: CGFloat = 60 {
        didSet { if oldValue != textSpace { calculateAllWidth() } }
    }

    //每個tab之間的空格
    @IBInspectable public var tabSpace: CGFloat = 0 {
        didSet { if oldValue != tabSpace { syncCollectionViewAttr() } }
    }

    //tab固定寬度, 0即是沒有
    @IBInspectable public var fixedTabWidth: CGFloat = 0 {
        didSet { if oldValue != fixedTabWidth { calculateAllWidth() } }
    }


    @IBInspectable public var canBounce: Bool = true {
        didSet { if oldValue != canBounce { syncCollectionViewAttr() } }
    }

    //底部橫線高度
    @IBInspectable public var flagHeight: CGFloat = 2 {
        didSet { if oldValue != flagHeight { syncFlagViewAttr() } }
    }


    //當tab總和寬度小於view寬度時, 是否填滿, 填滿需按照填滿風格執行
    @IBInspectable public var fillToWidthIfNeed: Bool = false {
        didSet { if oldValue != fillToWidthIfNeed { calculateAllWidth() } }
    }

    //填滿的風格
    //0 -> 按照比例填滿, 1 -> 平均分配(現在type 1 有問題, 禁止使用)
    @IBInspectable public var fillType: Int = 1 {
        didSet { if oldValue != fillType { calculateAllWidth() } }
    }

    weak public var tabDelegate: MGTextTabLayoutDelegate?

    private var flagView: UIView!  //底部的橫線

    //當前選擇的tab
    public var select: Int = -1 {
        didSet { if oldValue != select { uploadShow(oldValue, new: select) } }
    }

    private var tabWidth: [CGFloat] = [] //每個tab的寬度
    private var tabPointX: [CGFloat] = [] //每個tab的x軸位置

    //所有tab加總後的寬度
    private var totalWidth: CGFloat = 0 {
        didSet {
            //當呼叫 calculateAllWidth 計算完寬度後, 此邊會接受到回調設置
            //接著檢查tab填充類型, 若 fillToWidthIfNeed 為 true, 則 當 totalWidth 小於 view 的寬度時
            //依照每個tab的寬度按比例放大直至填滿 view 寬度
            fillWidthIfNeed()

            //當tabWidth目前已有時, 則要更新flagView
            uploadShow(-1, new: select)
        }
    }


    //寬度改變時需要重算所有width
    override public var bounds: CGRect {
        didSet { calculateAllWidth() }
    }

    private var defaultCellId: String = "Cell"

    //裝載tab的collection view
    private var collectionView: UICollectionView!

    //tab按鈕文字, 每次有所變更都要重新計算
    public var tabText: [String] = [] {
        didSet { calculateAllWidth() }
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }


    private func setupView() {
        initCollectionView()
        initFlagView()
    }

    //初始化collection
    private func initCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal

        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.scrollsToTop = false

        addSubview(collectionView)

        //設置此變數, 在加入約束後才會自動更新frame
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        collectionView.backgroundColor = UIColor.clear


        //註冊基本使用的cell
        collectionView.register(TextCell.self, forCellWithReuseIdentifier: defaultCellId)

        collectionView.delegate = self
        collectionView.dataSource = self

        syncCollectionViewAttr()
    }

    //初始化下方的指示標view
    private func initFlagView() {
        let rect = CGRect(x: 0, y: 0, width: 0, height: flagHeight)
        flagView = UIView(frame: rect)

        collectionView.addSubview(flagView)
        syncFlagViewAttr()
    }

    //同步collection view 屬性
    private func syncCollectionViewAttr() {
        collectionView.alwaysBounceHorizontal = canBounce
        let layout: UICollectionViewFlowLayout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = tabSpace
        collectionView.reloadData()
    }

    //同步flag View 屬性
    private func syncFlagViewAttr() {
        flagView.backgroundColor = lineColor
        var frame = flagView.frame
        frame.size.height = flagHeight
        flagView.frame = frame
    }

    //計算寬度(所有tab總寬度, 個別寬度), 計算完成之後需要reload collection
    private func calculateAllWidth() {
        if tabText.isEmpty { self.frame = CGRect.zero }

        tabWidth.removeAll()
        tabPointX.removeAll()

        var total: CGFloat = 0
        for text in tabText {
            //先檢查是否有固定每個tab的寬度, 0即是沒有
            //計算每個tab寬度需再加上 textSpace, 讓字串左右能有一定的空格, 若 fixedTabWidth 有設定, 則 space 失效
            let curLength = fixedTabWidth == 0 ? self.getTextWidth(text) + textSpace : fixedTabWidth
            tabWidth.append(curLength)
            tabPointX.append(total)
            total += curLength
        }
        totalWidth = total

        collectionView?.reloadData()
    }


    /*
     當呼叫 calculateAllWidth 計算完寬度後, 此邊會接受到回調設置
     接著檢查tab填充類型, 若 fillToWidthIfNeed 為 true, 則 當 totalWidth 小於 view 的寬度時
     依照每個tab的寬度按比例放大直至填滿 view 寬度
     */
    private func fillWidthIfNeed() {
        print("是否需要拉伸: \(totalWidth) -> \(frame.width)")
        if fillToWidthIfNeed && totalWidth < frame.width {
            var newWidth: [CGFloat] = []
            var newPointX: [CGFloat] = []
            var total: CGFloat = 0
            for w in tabWidth {

                //依照填滿風格不同而改變
                switch fillType {
                case 0: //依照比例放大至填滿
                    let tempWidth = (w * frame.width)/totalWidth
                    newWidth.append(tempWidth)
                    newPointX.append(total)
                    total += tempWidth
                case 1: //平均分配
                    let tempWidth = frame.width / CGFloat(tabWidth.count)
                    newWidth.append(tempWidth)
                    newPointX.append(total)
                    total += tempWidth
                default: break
                }
            }
            tabWidth = newWidth
            tabPointX = newPointX
            totalWidth = frame.width
        }
    }


    //更新顯示(flag view位置, tab text顏色)
    private func uploadShow(_ old: Int, new: Int) {
        let oldIndexPath = IndexPath(row: old, section: 0)
        let newIndexPath = IndexPath(row: new, section: 0)

        if (old > new ? old : new) >= tabWidth.count {
            return
        }

        if old != -1 {
            //修改文字颜色
            let oldCell: TextCell? = collectionView.cellForItem(at: oldIndexPath) as? TextCell

            oldCell?.label.textColor = normalTextColor
            oldCell?.setNeedsDisplay()
        }


        //當new是-1時, 消失整個flagView
        if new == -1 {
            UIView.animate(withDuration: 0.3, animations: {
                self.flagView.frame = CGRect(x: 0, y: self.frame.height - self.flagHeight, width: 0, height: self.flagHeight)
            })
            return
        }

        let newCell = collectionView.cellForItem(at: newIndexPath) as? TextCell
        newCell?.label.textColor = highlightTextColor
        newCell?.setNeedsDisplay()

        //修改 flagView 的位置
        let width = tabWidth[new]
        let position = tabPointX[new]

        UIView.animate(withDuration: 0.3, animations: {
            self.flagView.frame = CGRect(x: position, y: self.frame.height - self.flagHeight, width: width, height: self.flagHeight)
        })

        //重设 tableview 的偏移量
        //        var offSet:CGFloat = 0
        //        if (viewLength-curY) < frame.width {
        //            offSet = viewLength - frame.width
        //        }else if (curY + curH) > frame.width {
        //            offSet = curY + curH/2.0 - frame.width/2.0
        //        }
        //        UIView.animate(withDuration: 0.3) {
        //            self.tbView.contentOffset = CGPoint(x: 0, y: offSet)
        //        }

        //重设 tableview 的偏移量
        //        var offSet: CGFloat = 0
        //        if (viewLength-curY) < frame.width {
        //
        //            if viewLength < frame.width {
        //                offSet = 0
        //            } else {
        //                offSet = viewLength - frame.width
        //            }
        //
        //            //            offSet = 0
        //        } else if (curY + curH) > frame.width {
        //            offSet = curY + curH/2.0 - frame.width/2.0
        //        }
    }


    private func getTextWidth(_ text: String) -> CGFloat {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: textSize)]
        let size = text.size(withAttributes: attributes)
        return size.width
    }


    private class TextCell: UICollectionViewCell {

        var label: UILabel!

        override init(frame: CGRect) {
            super.init(frame: frame)

            //加入基本顯示的 text label
            addLabel()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)

            //加入基本顯示的 text label
            addLabel()
        }

        //加入基本顯示的 text label
        private func addLabel() {
            label = UILabel()
            label.textAlignment = .center
            addSubview(label)

            //設置此變數, 在加入約束後才會自動更新frame
            label.translatesAutoresizingMaskIntoConstraints = false

            //置中約束
            //更好的寫法
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

            //普通的寫法
            //            let centerXConstraint = NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.centerX,
            //                                                            relatedBy: NSLayoutRelation.equal,
            //                                                            toItem: self, attribute: NSLayoutAttribute.centerX,
            //                                                            multiplier: 1, constant: 0)
            //
            //            let centerYConstraint = NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.centerY,
            //                                                            relatedBy: NSLayoutRelation.equal,
            //                                                            toItem: self, attribute: NSLayoutAttribute.centerY,
            //                                                            multiplier: 1, constant: 0)
            //
            //            NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
        }
    }
}


extension MGTextTabLayout: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {


    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tabText.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: defaultCellId, for: indexPath) as! TextCell
        cell.label.text = tabText[indexPath.row]
        cell.label.textColor = normalTextColor
        cell.label.font = cell.label.font.withSize(textSize)
        //        cell.backgroundColor = indexPath.row == 0 ? UIColor.brown : UIColor.blue
        return cell
    }


    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: tabWidth[indexPath.row], height: collectionView.frame.height)
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let d = tabDelegate {
            if d.canTabChange(self, select: indexPath.row) {
                select = indexPath.row
                d.tabChange(self, old: select, new: indexPath.row)
            }
        } else {
            select = indexPath.row
        }
    }

}


public protocol MGTextTabLayoutDelegate: class {

    //是否可以切換tab
    func canTabChange(_ view: MGTextTabLayout, select: Int) -> Bool

    //切換到哪個tab
    func tabChange(_ view: MGTextTabLayout, old: Int, new: Int)

}

