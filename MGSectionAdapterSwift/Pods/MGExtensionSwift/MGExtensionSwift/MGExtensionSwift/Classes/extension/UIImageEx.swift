//
//  UIImageEx.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/19.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

public extension UIImage {

    //重新設置圖片大小
    public func reSize(_ size: CGSize) -> UIImage {
        //UIGraphicsBeginImageContext(reSize);
        UIGraphicsBeginImageContextWithOptions(size,false,UIScreen.main.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let reSizeImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }

    //等比例縮放
    public func scale(_ coefficient: CGFloat) -> UIImage {
        let size = CGSize(width: self.size.width * coefficient, height: self.size.height * coefficient)
        return reSize(size)
    }

    //依照比例縮放到rect裡
    public func scale(_ aspectFit: CGRect) -> (img: UIImage, rect: CGRect) {
        let w = self.size.width
        let h = self.size.height

        let scaleX = aspectFit.width / w
        let scaleY = aspectFit.height / h

        let scaleCoefficient = scaleX > scaleY ? scaleY : scaleX
        let slideW = w * scaleCoefficient
        let slideH = h * scaleCoefficient

        let spaceW = aspectFit.width - slideW
        let spaceH = aspectFit.height - slideH

        let newRect = CGRect(x: aspectFit.minX + spaceW / 2, y: aspectFit.minY + spaceH / 2,
                             width: aspectFit.width - spaceW, height: aspectFit.height - spaceH)

        return (img: scale(scaleCoefficient), rect: newRect)
    }


    public func imageWithTintColor(tintColor:UIColor, blendMode:CGBlendMode) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        tintColor.setFill()
        let bounds = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)
        self.draw(in: bounds, blendMode: blendMode, alpha: 1.0)
        if blendMode != .destinationIn {
            //            self.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
            self.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)
        }
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return tintedImage!

    }


    //將圖片渲染上特定顏色
    public func mask(_ color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()!

        color.setFill()

        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        let rect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height)
        context.draw(self.cgImage!, in: rect)

        context.setBlendMode(CGBlendMode.sourceIn)
        context.addRect(rect)
        context.drawPath(using: CGPathDrawingMode.fill)

        let coloredImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return coloredImage!
    }
}
