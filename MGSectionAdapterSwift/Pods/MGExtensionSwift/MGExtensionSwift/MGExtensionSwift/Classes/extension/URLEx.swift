//
//  URLEx.swift
//  MGExtensionSwift
//
//  Created by Magical Water on 2018/9/10.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public extension URL {
    public var queryDictionary: [String: String]? {
        guard let query = URLComponents(string: self.absoluteString)?.query else { return nil }
        
        var queryStrings = [String: String]()
        for pair in query.components(separatedBy: "&") {
            
            let key = pair.components(separatedBy: "=")[0]
            
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            
            queryStrings[key] = value
        }
        return queryStrings
    }
    
    //在url基礎上加入query
    public mutating func addQuerys(_ query: [String:String]) {
        //這有可能拋出錯誤, 若是出現錯誤直接返回nil
        //將 需要帶入的 param 參數以 query item的方式加入url
        var urlComponment = URLComponents.init(url: self, resolvingAgainstBaseURL: false)
        var queryItems: [URLQueryItem] = urlComponment?.queryItems ?? []
        query.forEach {
            queryItems.append(URLQueryItem.init(name: $0.key, value: $0.value))
        }
        urlComponment?.queryItems = queryItems
        if let componment = urlComponment, let url = componment.url {
            self = url
        }
    }
}
