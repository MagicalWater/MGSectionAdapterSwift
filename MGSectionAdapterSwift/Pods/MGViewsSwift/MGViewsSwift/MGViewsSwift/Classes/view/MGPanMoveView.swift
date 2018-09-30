//
//  MGPanMoveView.swift
//  MGViewsSwift
//
//  Created by Magical Water on 2018/5/14.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit
import MGBaseViewSwift

//可隨著手指移動的view
open class MGPanMoveView: MGBaseView {

    //可滑動選項是否開啟
    open var panEnabled: Bool = true

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    //view是否可超出螢幕
    open var canOutScreen: Bool = false

    //開始移動的點
    private var startPoint = CGPoint()

    //螢幕長寬
    private var screenWidth: CGFloat = UIScreen.main.bounds.width
    private var screenHeight: CGFloat = UIScreen.main.bounds.height

    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !panEnabled {
            super.touchesBegan(touches, with: event)
            return
        }
        // 把當前view 移動到最上面
        self.superview?.bringSubviewToFront(self)
        self.startPoint = (touches.first?.location(in: self))!
        super.touchesBegan(touches, with: event)
    }

    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !panEnabled {
            super.touchesMoved(touches, with: event)
            return
        }
        let crtPoint = touches.first?.location(in: self)
        let dx = (crtPoint?.x)! - self.startPoint.x
        let dy = (crtPoint?.y)! - self.startPoint.y

        var centerX = self.center.x + dx
        var centerY = self.center.y + dy

        //如果開啟不能超過螢幕, 則要檢查中心點
        if !canOutScreen {
            let halfW = self.bounds.width / 2
            let halfY = self.bounds.height / 2

            //檢查左右
            if centerX - halfW < 0 {
                centerX = halfW
            } else if centerX + halfW > screenWidth {
                centerX = screenWidth - halfW
            }

            //檢查上下
            if centerY - halfY < 0 {
                centerY = halfY
            } else if centerY + halfY > screenHeight {
                centerY = screenHeight - halfY
            }
        }

        self.center = CGPoint(x: centerX, y: centerY)
        super.touchesMoved(touches, with: event)
    }


}
