//
//  MGParamEncoding.swift
//  MGUtilsSwift
//
//  Created by Magical Water on 2018/9/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

/*
 參數的編碼方式 - 參考 alamofire 的做法
 alamofire 中有三種 1. URLEncoding, 2. JSONEncoding, 3. PropertyListEncoding
 URLEncoding 的作法即是按照一班般知的方式
 * get - 將參數以 key value pair 的方式加入 url 裏
 * post - 將參數以 key value pair 的方式加入 httpbody 裏
 
 JSONEncoding 則是將參數包裝成 json 格式直接加入 httpbody 裏
 
 PropertyListEncoding 暫時沒用到, 因此沒研究, 因因此此處不加入此選項
 */
//alamofire 分成了三種,
public protocol MGParamEncoding {
    func encode(request: inout URLRequest, params: [String : Any], method: MGNetworkUtils.Method) throws
}

public class MGURLEncoding: MGParamEncoding {
    
    private init() {}
    
    public static var `default`: MGURLEncoding { return MGURLEncoding() }
    
    public func encode(request: inout URLRequest, params: [String : Any], method: MGNetworkUtils.Method) throws {
        
        switch method {
        case .get:
            
            if var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false), !params.isEmpty {
                let percentEncodedQuery = (urlComponents.percentEncodedQuery.map { $0 + "&" } ?? "") + MGNetworkUtils.query(params)
                urlComponents.percentEncodedQuery = percentEncodedQuery
                request.url = urlComponents.url
            }
            
        case .post:
            
            //設置content type, 默認使用 utf8, 類型為 application/x-www-form-urlencoded
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
            }
            
            request.httpBody = MGNetworkUtils.query(params).data(using: .utf8, allowLossyConversion: false)
        }
        
    }
}

public class MGJSONEncoding: MGParamEncoding {
    
    public static var `default`: MGJSONEncoding { return MGJSONEncoding() }
    
    public static var prettyPrinted: MGJSONEncoding { return MGJSONEncoding(options: .prettyPrinted) }
    
    public let options: JSONSerialization.WritingOptions
    
    enum JSONError: Error {
        case jsonEncodingError(error: Error)
    }
    
    private init(options: JSONSerialization.WritingOptions = []) {
        self.options = options
    }
    
    public func encode(request: inout URLRequest, params: [String : Any], method: MGNetworkUtils.Method) throws {
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: options)
            
            if request.value(forHTTPHeaderField: "Content-Type") == nil {
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
            request.httpBody = data
        } catch {
            throw JSONError.jsonEncodingError(error: error)
        }
    }
}
