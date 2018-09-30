//
//  MGBaseView.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/18.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

/*
 最基礎的上層view, 封裝了以下功能
 1. 觸摸回饋(透明顯示) - touchAlpha
 2. xib元件載入 - contentView, contentNib
 3. 點擊監聽 - onClickListener
 4. 初始化view呼叫 setupView
 5. padding屬性引入
 */
open class MGBaseView : UIView {
    
    //padding預設值, 以此判斷padding某邊是否有設定
    private static let PADDING_DEFAULT: CGFloat = -1001
    
    //padding屬性, 如果任一邊值不等於-1001, 則以有設定那邊為主
    //取用真實的屬性以 left, right, top, bottom開頭的padding為主
    @IBInspectable public var padding: CGFloat = 0
    @IBInspectable public var paddingLeft: CGFloat = MGBaseView.PADDING_DEFAULT
    @IBInspectable public var paddingRight: CGFloat = MGBaseView.PADDING_DEFAULT
    @IBInspectable public var paddingTop: CGFloat = MGBaseView.PADDING_DEFAULT
    @IBInspectable public var paddingBottom: CGFloat = MGBaseView.PADDING_DEFAULT
    
    //陰影透明值
    @IBInspectable public var shadowOpacity: Float = 0 {
        didSet { settingShadow() }
    }
    
    //陰影範圍, 數值越高陰影越模糊越分散
    @IBInspectable public var shadowRadius: CGFloat = 0 {
        didSet { settingShadow() }
    }
    
    //陰影顏色
    @IBInspectable public var shadowColor: UIColor? = nil {
        didSet { settingShadow() }
    }
    
    //陰影x偏移
    @IBInspectable public var shadowOffsetX: CGFloat = 0 {
        didSet { settingShadow() }
    }
    
    //陰影y偏移
    @IBInspectable public var shadowOffsetY: CGFloat = 0 {
        didSet { settingShadow() }
    }
    
    private var leftPadding: CGFloat {
        get { return paddingLeft == MGBaseView.PADDING_DEFAULT ? padding : paddingLeft }
    }
    private var rightPadding: CGFloat {
        get { return paddingRight == MGBaseView.PADDING_DEFAULT ? padding : paddingRight }
    }
    private var topPadding: CGFloat {
        get { return paddingTop == MGBaseView.PADDING_DEFAULT ? padding : paddingTop }
    }
    private var bottomPadding: CGFloat {
        get { return paddingBottom == MGBaseView.PADDING_DEFAULT ? padding : paddingBottom }
    }
    public var realX: CGFloat {
        get { return 0 + leftPadding }
    }
    public var realY: CGFloat {
        get { return 0 + topPadding }
    }
    public var realEndX: CGFloat {
        get { return bounds.width - rightPadding }
    }
    public var realEndY: CGFloat {
        get { return bounds.height - bottomPadding }
    }
    public var realWidth: CGFloat {
        get { return realEndX - realX }
    }
    public var realHeight: CGFloat {
        get { return realEndY - realY }
    }
    public var realCenterX: CGFloat {
        get { return (realX + realEndX)/2 }
    }
    public var realCenterY: CGFloat {
        get { return (realY + realEndY)/2 }
    }
    
    //觸摸回饋
    @IBInspectable var touchAlpha: Bool = false
    
    //如果有載入xib, 這個就會有值
    public var content: UIView?
    
    private var onClickListener: ((UIView) -> Void)?
    
    //設置陰影
    private func settingShadow() {
        if let clr = shadowColor, shadowOpacity > 0 {
            self.layer.shadowOffset = CGSize.init(width: shadowOffsetX, height: shadowOffsetY)
            self.layer.shadowOpacity = shadowOpacity
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowColor = clr.cgColor
        } else {
            self.layer.shadowOffset = CGSize.init(width: 0, height: -1)
            self.layer.shadowOpacity = 0
        }
    }
    
    //加入子view, 如果需要
    public func loadContentIfNeed() {
        if let content = contentView() {
            addSubview(content)
            self.content = content
            content.frame = self.bounds
            content.translatesAutoresizingMaskIntoConstraints = false
            content.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            content.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            content.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
            content.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        } else if let nib = contentNib() {
            let nibs = nib.instantiate(withOwner: self, options: nil)
            if let view = nibs.first as? UIView {
                self.content = view
                //                view.translatesAutoresizingMaskIntoConstraints = false
                addSubview(view)
                view.frame = self.bounds
                
                view.translatesAutoresizingMaskIntoConstraints = false
                view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
                view.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                view.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
            } else {
                //初始化nib轉為view時發生錯誤, 跳出訊息
                print("初始化 nib 轉為 view 時發生錯誤, nib沒載入")
            }
        }
    }
    
    //是否自動載入xib的view到子view, 判斷此優先, 再來是 Nib 也可以
    open func contentView() -> UIView? { return nil }
    
    //是否自動載入xib的view到子view, 判斷此優先, 再來是 Nib 也可以
    open func contentNib() -> UINib? { return nil }
    
    //view的初始化皆從這裡開始, 以後不用再覆寫 init 的兩個方法
    open func setupView() {}
    
    
    //如同android view一樣
    public func setOnClickListener(_ handler: ((UIView) -> Void)?) {
        self.onClickListener = handler
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchAlpha { self.alpha = 0.7 }
    }
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchAlpha { self.alpha = 1 }
    }
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchAlpha { self.alpha = 1 }
        onClickListener?(self)
    }
}
