//
//  MGNetworkDetectUtils.swift
//  MGBaseSwift
//
//  Created by Magical Water on 2018/3/26.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import Reachability

//網路狀態檢測
public class MGNetworkDetectUtils {

    private let reachability = Reachability()!

    weak public var networkDelegate: MGNetworkDetectDelegate?

    //此參數獲取當前網路狀態
    public var status: NetworkStatus {
        get {
            switch reachability.connection {
            case .wifi: return .wifi
            case .cellular: return .cellular
            case .none: return .none
            }
        }
    }

    public init() {}

    //Cellular: 表示「行動通訊」的功能，也就是擁有 3G 以及 4G 這類的行動上網能力！
    public enum NetworkStatus {
        case wifi
        case cellular
        case none
    }

    //開始檢測, 在得到網路狀態之前會先傳一次當前狀態
    public func start() {

        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
        do{
            try reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }

    }

    //停止檢測
    public func stop() {
        NotificationCenter.default.removeObserver(self)
    }

    deinit {
        stop()
    }

    @objc private func reachabilityChanged() {
        networkDelegate?.networkStatusChange(status)
    }

}


//網路檢測回調
public protocol MGNetworkDetectDelegate : class {
    func networkStatusChange(_ status: MGNetworkDetectUtils.NetworkStatus)
}
