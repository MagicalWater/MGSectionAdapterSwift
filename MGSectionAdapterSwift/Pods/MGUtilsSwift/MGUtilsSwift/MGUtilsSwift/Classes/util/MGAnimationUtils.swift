//
//  MGAnimationUtils.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/31.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

//此動畫不會更改view的真實位置, 觸摸事件仍然在原地, 因此若是要view真的改變位置不可使用
public class MGAnimationUtils : NSObject, CAAnimationDelegate {

    public override init() {}

    //儲存播放的動畫與回傳
    private var animEndHandler: [String : (() -> Void)] = [:]

    //animTag, 只有在 需要處理回調endHandler時才調用
    //endHandler 動畫結束時回調
    public func animator(_ view: UIView, attr: [MGAnimationAttr],
                         duration: CFTimeInterval, repeatCount: Float? = 1,
                         animTag: String? = nil,
                         endHandler: (() -> Void)? = nil) {
        view.layer.removeAllAnimations()
        var anims: [CABasicAnimation] = []

        attr.forEach { attr in
            let anim = CABasicAnimation(keyPath: attr.name)
            anim.fromValue = attr.start
            anim.toValue = attr.end

            //這個值是指動畫結束後跟上一次的值累加(true)，或是直接重來(false)
            //測試上沒有加這個也不會有問題
            anim.isCumulative = anim.isCumulative
            anims.append(anim)
        }

        let group: CAAnimationGroup = CAAnimationGroup()
        group.animations = anims
        group.duration = duration

        if let count = repeatCount {
            group.repeatCount = count
        }
        //莫認為true，代表動畫執行完畢後就從塗層上移除, 恢復到動畫執行前的狀態
        //如果想讓塗層保持顯示動畫執行後的狀態. 設為 false 即可, 不過還需要設置 fillMode = kCAFillModeForwards
        //設置方式要先設置 isRemovedOnCompletion 再設置 fillMode 才有效
        group.isRemovedOnCompletion = false
        group.fillMode = CAMediaTimingFillMode.forwards
        group.delegate = self

//        group.repeatCount = 1 //重複次數
//        group.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn) //速率差值

        if let handler = endHandler, let tag = animTag {
            animEndHandler[tag] = handler
            group.setValue(tag, forKey: "animType")
        }

        view.layer.add(group, forKey: "groupAnimations")
    }


    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        //動畫結束
        let animType = anim.value(forKey: "animType") as? String
        if let type = animType, let handler = animEndHandler[type] {
            //動畫結束呼叫回調
            handler()
            animEndHandler.removeValue(forKey: type)
        }
    }

}

public struct MGAnimationAttr {
    let name: String
    let start: Any?
    let end: Any?
    let isCumulative: Bool //重複時是否從上次循環結束時的狀態開始

    public init(_ name: String, start: Any?, end: Any?, isCumulative: Bool = false) {
        self.name = name
        self.start = start
        self.end = end
        self.isCumulative = isCumulative
    }
}

public struct MGAnimationKey {
    public static let scale = "transform.scale"
    public static let scaleX = "transform.scale.x"
    public static let scaleY = "transform.scale.y"
    public static let translateX = "transform.translation.x"
    public static let translateY = "transform.translation.y"
    public static let rotationZ = "transform.rotation.z"
    public static let opacity = "opacity"
    public static let margin = "margin"
    public static let zPosition = "zPosition"
    public static let backgroundColor = "backgroundColor"
    public static let cornerRadius = "cornerRadius"
    public static let borderWidth = "borderWidth"
    public static let bounds = "bounds"
    public static let contents = "contents"
    public static let contentsRect = "contentsRect"
    public static let frame = "frame"
    public static let mask = "mask"
    public static let masksToBounds = "masksToBounds"
    public static let position = "position"
    public static let shadowColor = "shadowColor"
    public static let shadowOffset = "shadowOffset"
    public static let shadowOpacity = "shadowOpacity"
    public static let shadowRadius = "shadowRadius"
}
