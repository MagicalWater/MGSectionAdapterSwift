//
//  MGBlankShadowView.swift
//  AuthorizedStore
//
//  Created by Magical Water on 2018/2/23.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit
import MGBaseViewSwift

@IBDesignable public class MGBlankShadowView: MGBaseView {

    public var blankPath: UIBezierPath? {
        didSet { drawBlankPath() }
    }

    @IBInspectable var blankColor: UIColor = UIColor.clear {
        didSet { drawBlankPath() }
    }

    @IBInspectable var outerColor: UIColor = UIColor.init(white: 0.1, alpha: 0.5) {
        didSet { drawBlankPath() }
    }

    override public var bounds: CGRect {
        didSet { drawBlankPath() }
    }

    private var fillLayer: CAShapeLayer!

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override public func setupView() {
        fillLayer = CAShapeLayer()
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        self.layer.addSublayer(fillLayer)

        drawBlankPath()
    }


    private func drawBlankPath() {
        //背景
        let shadowPath = UIBezierPath(rect: bounds)

        //簍空
        if let bp = blankPath {
            shadowPath.append(bp)
            shadowPath.usesEvenOddFillRule = true
        }

        fillLayer.fillColor = outerColor.cgColor
        fillLayer.path = shadowPath.cgPath
    }

}
