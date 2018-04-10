//
//  MGPercentPositionLayout.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/19.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit

/*
 百分比佈局, 百分比不是指子view的長寬以百分比呈現
 而是以百分比作為約束位置
 例如: Label 我要放在 layout 底下的 x軸: 90% y軸: 70% 的位置, 並且以 Label 的中心點對準此點

 作法: 每加入一個百分比子view, 會配給一個不可見的 ancher view
 這個不可見的ancher view同時也會加入到 layout 下面, 設置長寬約束為0
 並且設置leading約束為此view乘以百分比的x肘位置, y軸以此類推

 最後將需要設置到此點的百分比子view, 針對不可見的ancher view做約束即可
 */
public class MGPercentPositionLayout: UIView {

    private typealias AncherView = UIView

    //加入的百分比子view必定有一個 ancher view 和 attr
    private typealias PercentViewPair = (ancher: AncherView, attr: PercentAttr)

    //正在使用的錨點
    private var activityanchers: [UIView : PercentViewPair] = [:]

    //目前閒置中的錨點
    private var freeAnchers: [AncherView] = []


    //在bounds改變了之後, 需要對所有使用中的錨點做一次重新設置約束的動作
    //正常來說只需要對錨點的 leading 跟 top 約束做變動的動作
    //但此處暫時不處理, 直接重新設置所有的constriant
    override public var bounds: CGRect {
        didSet { resetAllConstraint() }
    }


    //給外部加入子view, 需帶入約束相關屬性
    public func addView(_ view: UIView, attr: PercentAttr) {

        //設置錨點view, 並配給給此 子view
        let ancher = getAncher(view)
        addSubview(ancher)
        addSubview(view)

        //加入(更新)對應表
        activityanchers[view] = (ancher: ancher, attr: attr)
        settingConstraint(view)
    }


    //重新設置所有的約束
    private func resetAllConstraint() {
        activityanchers.forEach {
            settingConstraint($0.key)
        }
    }


    //設置某個子view的約束
    private func settingConstraint(_ view: UIView) {
        //先拿到錨點跟attr, 正常一定要拿到, 以防之後debug難度, 這邊若沒拿到, 直接崩潰
        let pair = activityanchers[view]!

        //設置錨點的約束
        setConstraintForAncher(pair.ancher, attr: pair.attr)

        //接著設置view針對錨點的約束(x軸, y軸)
        setConstraintForView(view, ancher: pair.ancher, attr: pair.attr)
    }


    //設置錨點的約束
    private func setConstraintForAncher(_ ancher: AncherView, attr: PercentAttr) {
        //在設置之前先清除掉所有錨點的約束
        ancher.removeConstraints(ancher.constraints)

        //計算經過百分比運算後, leading 跟 top 的距離
        let distanceX: CGFloat = self.frame.width * CGFloat(attr.percentX)
        let distanceY: CGFloat = self.frame.height * CGFloat(attr.percentY)

        //開始設置錨點, 先設置約束, 長寬設置為0, 設置leading跟top
        ancher.translatesAutoresizingMaskIntoConstraints = false
        ancher.widthAnchor.constraint(equalToConstant: 0).isActive = true
        ancher.heightAnchor.constraint(equalToConstant: 0).isActive = true
        ancher.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: distanceX).isActive = true
        ancher.topAnchor.constraint(equalTo: self.topAnchor, constant: distanceY).isActive = true
    }

    //設置view的約束
    private func setConstraintForView(_ view: UIView, ancher: AncherView, attr: PercentAttr) {
        //在設置之前先清除掉所有view的約束
        view.removeConstraints(view.constraints)

        view.translatesAutoresizingMaskIntoConstraints = false

        setConstraintToAncher(view, ancher: ancher, alignment: attr.alignX, offset: attr.offsetX)
        setConstraintToAncher(view, ancher: ancher, alignment: attr.alignY, offset: attr.offsetY)

        //設置view的寬高約束(若有)
        if let w = attr.width {
            view.widthAnchor.constraint(equalToConstant: w).isActive = true
        }
        if let y = attr.height {
            view.heightAnchor.constraint(equalToConstant: y).isActive = true
        }
    }

    //設置view針對錨點的約束
    private func setConstraintToAncher(_ view: UIView, ancher: AncherView, alignment: Alignment, offset: CGFloat) {

        switch alignment {
        case .top:
            view.topAnchor.constraint(equalTo: ancher.topAnchor, constant: offset).isActive = true
        case .bottom:
            view.bottomAnchor.constraint(equalTo: ancher.bottomAnchor, constant: offset).isActive = true
        case .leading:
            view.leadingAnchor.constraint(equalTo: ancher.leadingAnchor, constant: offset).isActive = true
        case .trailing:
            view.trailingAnchor.constraint(equalTo: ancher.trailingAnchor, constant: offset).isActive = true
        case .centerX:
            view.centerXAnchor.constraint(equalTo: ancher.centerXAnchor).isActive = true
        case .centerY:
            view.centerYAnchor.constraint(equalTo: ancher.centerYAnchor).isActive = true
        }
    }

    //得到此view相對應的錨點, 若無相對應, 則從free anchers裡面配給一個, 若free為空, 則生成一個
    private func getAncher(_ view: UIView) -> AncherView {
        if let pair = activityanchers[view] {
            return pair.ancher
        } else {
            //沒有對應的錨點, 給出一個新的
            let ancher = createNewAncher()
            return ancher
        }
    }

    private func createNewAncher() -> AncherView {
        //尋找是否有閒置中的錨點
        if freeAnchers.isEmpty {
            //沒有閒置中的錨點存在, 因此創建一個新個
            return AncherView()
        } else {
            return freeAnchers.removeLast()
        }
    }


    //百分比位置相關屬性
    public class PercentAttr {
        //對齊百分比點的位置
        var alignX: Alignment = .centerX
        var alignY: Alignment = .centerY

        //所要對齊的點
        var percentX: Double = 0
        var percentY: Double = 0

        //在對其的點上做偏移
        var offsetX: CGFloat = 0
        var offsetY: CGFloat = 0

        //是否設置子view的寬高約束
        var width: CGFloat?
        var height: CGFloat?
    }

    //對齊邊的屬性
    public enum Alignment {
        case centerX
        case centerY
        case leading
        case trailing
        case top
        case bottom
    }
}

