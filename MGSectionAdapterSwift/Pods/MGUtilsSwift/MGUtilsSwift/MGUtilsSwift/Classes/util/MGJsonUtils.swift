//
//  MGJsonDataParseUtils.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/17.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public class MGJsonUtils {

    private init() {}
    
    //反序列化, 將json變成物件, 直接在變數宣告類型
    public static func deserialize<T>(from string: String) -> T? where T : Decodable {
        return deserialize(T.self, from: string)
    }
    
    //反序列化, 將json變成物件, 將需要反序列化的類型帶入
    public static func deserialize<T>(_ type: T.Type, from string: String) -> T? where T : Decodable {
        guard let data = string.data(using: String.Encoding.utf8) else {
            return nil
        }
        var deserialModel: T? = nil
        do {
            deserialModel = try JSONDecoder().decode(type, from: data)
        } catch {
            print("反序列化錯誤: \(error)")
        }
        return deserialModel
    }

    //序列化, 將物件變成json data
    public static func serialize<T>(from model: T) -> String? where T : Encodable {
        var serialString: String? = nil
        do {
            let data = try JSONEncoder().encode(model)
            serialString = String.init(data: data, encoding: String.Encoding.utf8)
        } catch {
            print("序列化錯誤: \(error)")
        }
        return serialString
        
    }

}
