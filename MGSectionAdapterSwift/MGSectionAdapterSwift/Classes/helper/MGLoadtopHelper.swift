//
//  MGLoadtopHelper.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/19.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import MGUtilsSwift

class MGLoadtopHelper {
    //是否正在加載置頂
    var isLoading: Bool = false

    //動畫花費時間
    var animDuration: TimeInterval = 2

    var timerUtils: MGTimerUtils = MGTimerUtils()

    //加載更多是否正在冷卻中, 休息一段時間之後自動更改回 false
    var isBreath: Bool = false {
        didSet {
            if isBreath {
                timerUtils.startCountdown(what: 0x1, byDelay: 5) {
                    self.isBreath = false

                }
            }
        }
    }
}
