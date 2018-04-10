//
//  MGCollectionCell.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/25.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit

open class MGBaseCollectionCell: UICollectionViewCell {

    public var section: MGSection? = nil
    public var header: MGSectionGroup.MGSectionHeader? = nil
    public var footer: MGSectionGroup.MGSectionFooter? = nil

    //觸摸回饋
    @IBInspectable public var touchAlpha: Bool = false

    private var onClickListener: ((MGBaseCollectionCell) -> Void)?

    //如同android view一樣
    public func setOnClickListener(_ handler: ((MGBaseCollectionCell) -> Void)?) {
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


    //若想完全控制cell的高度可複寫此方法(不讓cell自適應)
    //重寫此方法可以全面控制cell的寬高
    //preferredLayoutAttributesFitting 默認調整size達成self-sizing Cell
    //所以需要先調用super.preferredLayoutAttributesFitting
    //在返回的UICollectionViewLayoutAttributes上做你想要的修改
    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes: UICollectionViewLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        return attributes
    }

}
