//
//  MGNetworkResponse.swift
//  MGUtilsSwift
//
//  Created by Magical Water on 2018/9/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public class MGNetworkResponse {
    public private(set) var statusCode: Int?
    public private(set) var headers: [AnyHashable : Any]?
    public private(set) var error: Error?
    
    private(set) var data: Data?
    
    //將data轉為字串
    public var dataString: String? {
        if let data = data {
            return String.init(data: data, encoding: .utf8)
        } else {
            return nil
        }
    }
    
    //當 html 狀態碼是 200才是成功的
    public var success: Bool {
        return statusCode == 200
    }
    
    public init(data: Data?, statusCode: Int?, responseHeaders: [AnyHashable : Any]?, error: Error?) {
        self.data = data
        self.headers = responseHeaders
        self.statusCode = statusCode
        self.error = error
    }
}
