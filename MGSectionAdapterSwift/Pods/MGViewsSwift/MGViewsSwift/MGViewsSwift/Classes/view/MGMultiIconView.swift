//
//  MGMultiIconView.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/19.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit
import MGExtensionSwift
import MGBaseViewSwift

@IBDesignable class MGMultiIconView: MGBaseView {

    @IBInspectable var normalImage: UIImage? {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var highlightImage: UIImage? {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var normalImageColor: UIColor? {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var highlightImageColor: UIColor? {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var normalTextColor: UIColor = UIColor.black {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var highlightTextColor: UIColor = UIColor.black {
        didSet { setNeedsDisplay() }
    }

    //圖片跟文字得距離
    @IBInspectable var spaceBetweenTextImag: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var normalText: String? {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable var highlightText: String? {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var textSize: CGFloat = 10 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable var isHighlight: Bool = false {
        didSet { setNeedsDisplay() }
    }


    override var bounds: CGRect {
        didSet { setNeedsDisplay() }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override public func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)

        let realRect = CGRect(x: realX, y: realY, width: realWidth, height: realHeight)
        let imgRect: CGRect!

        var text: String? = nil
        var img: UIImage? = nil

        if isHighlight {
            text = highlightText ?? normalText ?? nil
            img = highlightImage ?? normalImage ?? nil
        } else {
            text = normalText ?? highlightText ?? nil
            img = normalImage ?? highlightImage ?? nil
        }

        let inTextColor = isHighlight ? highlightTextColor : normalTextColor
        let inImageColor = isHighlight ? highlightImageColor : normalImageColor

        if let t = text {
            let font: UIFont = UIFont.systemFont(ofSize: textSize)
            let lineH = font.lineHeight
            imgRect = CGRect(x: realRect.minX, y: realRect.minY, width: realRect.width, height: realRect.height - lineH - spaceBetweenTextImag)
            let txtRect = CGRect(x: rect.minX, y: imgRect.maxY + spaceBetweenTextImag, width: rect.width, height: lineH)
            let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
            style.alignment = .center
            let stingAttrs: [NSAttributedStringKey : Any] = [
                NSAttributedStringKey.font : font
                , NSAttributedStringKey.foregroundColor : inTextColor
                , NSAttributedStringKey.paragraphStyle : style
            ]
            t.draw(in: txtRect, withAttributes: stingAttrs)
        } else {
            imgRect = realRect

        }

        if let showImg = img {
            let scaleImg = showImg.scale(imgRect)
            if let maskColor = inImageColor {
                let tintImg = scaleImg.img.mask(maskColor)
                tintImg.draw(in: scaleImg.rect)
            } else {
                scaleImg.img.draw(in: scaleImg.rect)
            }
        }

    }



}
