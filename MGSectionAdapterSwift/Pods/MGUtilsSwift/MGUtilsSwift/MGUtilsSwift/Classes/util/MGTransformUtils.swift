//
//  MGTransformUtils.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/26.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

public class MGTransformUtils {

    private init() {}


    public static func animator(_ view: UIView, attrs: [MGAnimationAttr], duration: TimeInterval) {
        var tranform = CGAffineTransform.identity

        var transformX: CGFloat?
        var transformY: CGFloat?
        var scale: CGFloat?

        attrs.forEach { attr in
            switch attr.name {
            case MGAnimationKey.translateX:
                transformX = attr.end as? CGFloat
            case MGAnimationKey.translateY:
                transformY = attr.end as? CGFloat
            case MGAnimationKey.scale:
                scale = attr.end as? CGFloat
            default: break
            }
        }

        if transformX != nil || transformY != nil {
            tranform = tranform.translatedBy(x: transformX ?? 0, y: transformY ?? 0)
        }

        if let scale = scale {
            tranform = tranform.scaledBy(x: scale, y: scale)
        }

        UIView.animate(withDuration: duration) {
            view.transform = tranform
        }

    }
}
