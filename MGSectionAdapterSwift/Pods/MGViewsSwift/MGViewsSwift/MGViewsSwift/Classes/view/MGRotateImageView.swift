//
//  MGRotateImageView.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/21.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit
import MGUtilsSwift

//自動不停旋轉的view
public class MGRotateImageView: UIImageView {

    private var isRotating: Bool = false
    private var animationUtils = MGAnimationUtils()

    //不斷旋轉圖片
    public func startRotate() {
        let animAttr = MGAnimationAttr.init(MGAnimationKey.rotationZ,
                                            start: nil, end: NSNumber(value: .pi * 2.0),
                                            isCumulative: true)
        animationUtils.animator(self, attr: [animAttr], duration: 1, repeatCount: Float.infinity)
    }

    //停止旋轉
    public func stopRotate() {
        layer.removeAllAnimations()
    }

    public func hideForLoading(_ anim: Bool = true) {
        if anim {
            UIView.animate(withDuration: 0.5) { self.alpha = 0.0 }
        } else {
            self.alpha = 0.0
        }
    }

    public func showForLoading(_ anim: Bool = true) {
        if anim {
            UIView.animate(withDuration: 0.5) { self.alpha = 1.0 }
        } else {
            self.alpha = 1.0
        }
    }

}
