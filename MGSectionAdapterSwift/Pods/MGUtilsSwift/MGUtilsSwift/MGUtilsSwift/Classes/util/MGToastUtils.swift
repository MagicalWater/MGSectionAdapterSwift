//
//  MGToastUtils.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/22.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import Toast_Swift

public class MGToastUtils {

    private init() {}

    //初始化toast相關設定
    public static func initToastSetting() {
        //吐司相關設定
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.isQueueEnabled = false
    }

    public static func show(_ text: String) {
        MGThreadUtils.inMain {
            let windowView = UIApplication.shared.keyWindow!
            let centerX = windowView.frame.midX
            let bottomY = windowView.frame.maxY - 100
            let showPoint = CGPoint(x: centerX, y: bottomY)
            windowView.makeToast(text, duration: 1, point: showPoint, title: nil, image: nil, completion: nil)
        }
    }
}
