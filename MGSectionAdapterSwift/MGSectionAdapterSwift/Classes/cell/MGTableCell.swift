//
//  MGTableCell.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/22.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

//基礎table cell物件
open class MGBaseTableCell : UITableViewCell {

    public var section: MGSection? = nil
    public var header: MGSectionGroup.MGSectionHeader? = nil
    public var footer: MGSectionGroup.MGSectionFooter? = nil

    //觸摸回饋
    @IBInspectable public var touchAlpha: Bool = false

    private var onClickListener: ((MGBaseTableCell) -> Void)?

    //如同android view一樣
    public func setOnClickListener(_ handler: ((MGBaseTableCell) -> Void)?) {
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
