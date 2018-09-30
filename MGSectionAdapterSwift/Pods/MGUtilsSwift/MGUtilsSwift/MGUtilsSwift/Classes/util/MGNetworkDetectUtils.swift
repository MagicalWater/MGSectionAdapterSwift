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

    //取得內部ip, 因為是複製別人的方法, 目前還沒瞭解具體操作流程, 因此留下原本的註解
    // Return IP address of WiFi interface (en0) as a String, or `nil`
    func getWiFiAddress() -> String? {
        var address : String?
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0 else { return nil }
        guard let firstAddr = ifaddr else { return nil }
        
        // For each interface ...
        for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
            let interface = ifptr.pointee
            
            // Check for IPv4 or IPv6 interface:
            let addrFamily = interface.ifa_addr.pointee.sa_family
            if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
                
                // Check interface name:
                let name = String(cString: interface.ifa_name)
                if  name == "en0" {
                    
                    // Convert interface address to a human readable string:
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                                &hostname, socklen_t(hostname.count),
                                nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
        }
        freeifaddrs(ifaddr)
        
        return address
    }
    
    //取得外部ip, 使用第三方lib -> Ipify
    //Ipify: https://github.com/vincent-peng/swift-ipify
    //api: https://api.ipify.org?format=json
    func getPublicIpAddress(handler: @escaping ((String?) -> Void)) {
        let url = URL.init(string: "https://api.ipify.org?format=json")!
        MGNetworkUtils.share.get(url: url, params: nil, paramEncoding: MGURLEncoding.default, headers: nil) { response in
            if response.success {
                let jsonText = String.init(data: response.data!, encoding: .utf8)!
                let model: ApiIPModel = MGJsonUtils.deserialize(from: jsonText)!
                handler(model.ip)
            } else {
                handler(nil)
            }
        }
    }
    
    //反序列化對外ip的api json text
    class ApiIPModel: Codable {
        var ip: String
    }
}


//網路檢測回調
public protocol MGNetworkDetectDelegate : class {
    func networkStatusChange(_ status: MGNetworkDetectUtils.NetworkStatus)
}
