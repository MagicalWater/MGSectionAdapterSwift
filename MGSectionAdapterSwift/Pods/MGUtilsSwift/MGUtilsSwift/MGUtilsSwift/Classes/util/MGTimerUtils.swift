//
//  MGTimerUtils.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/31.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

//倒數計時工具
public class MGTimerUtils {

    public init() {}

    typealias MissionPair = (what: Int, handler: () -> Void)

    //儲存正在倒數的任務
    private var missions: [Int : Timer?] = [:]

    //開始倒數計時
    public func startCountdown(what: Int, byDelay: TimeInterval, handler: @escaping () -> Void) {

        cancelIfNeed(what: what)
        missions[what] = Timer.scheduledTimer(timeInterval: byDelay,
                                                   target: self,
                                                   selector: #selector(missionUP(t:)),
                                                   userInfo: MissionPair(what: what, handler: handler),
                                                   repeats: false)

    }

    //取消某比任務
    public func cancelIfNeed(what: Int) {
        if let t = missions[what] {
            t?.invalidate()
            missions[what] = nil
        }
        missions.removeValue(forKey: what)
    }

    @objc private func missionUP(t: Timer) {
        //倒數時間到
        let mp = t.userInfo as! MissionPair
        cancelIfNeed(what: mp.what)
        mp.handler()
    }

}
