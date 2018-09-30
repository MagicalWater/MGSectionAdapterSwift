//
//  MGBaseLabel.swift
//  AuthorizedStore
//
//  Created by Magical Water on 2018/2/28.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit

public class MGBaseLabel: UILabel {

    //觸摸回饋
    @IBInspectable public var touchAlpha: Bool = false
    
    //陰影透明值
    @IBInspectable public var shadowOpacity: Float = 0 {
        didSet { settingShadow() }
    }
    
    //陰影範圍, 數值越高陰影越模糊越分散
    @IBInspectable public var shadowRadius: CGFloat = 0 {
        didSet { settingShadow() }
    }
    
    //陰影顏色
    @IBInspectable public var shadowForColor: UIColor? = nil {
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

    private var onClickListener: ((UIView) -> Void)?

    //如同android view一樣
    public func setOnClickListener(_ handler: ((UIView) -> Void)?) {
        self.onClickListener = handler
    }
    
    //設置陰影
    private func settingShadow() {
        if let clr = shadowForColor, shadowOpacity > 0 {
            self.layer.shadowOffset = CGSize.init(width: shadowOffsetX, height: shadowOffsetY)
            self.layer.shadowOpacity = shadowOpacity
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowColor = clr.cgColor
        } else {
            self.layer.shadowOffset = CGSize.init(width: 0, height: -1)
            self.layer.shadowOpacity = 0
        }
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
