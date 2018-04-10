//
//  MGFileUtils.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/18.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public class MGFileUtils {

    private init() {}

    //預設的儲存資料夾, 所有api也都存在這裡
    public static var storageDir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    public static func wirte(name: String, content: String, path: URL) {
        let p = path.appendingPathComponent(name)

        do {
            try content.write(to: p, atomically: false, encoding: String.Encoding.utf8)
            print("寫入檔案成功: \n 檔名: \(name) \n路徑: \(path)\(name)")
        } catch {
            print("寫入檔案失敗: \n 檔名: \(name) \n 路徑: \(path)\(name)")
        }
    }


    public static func read(name: String, path: URL) -> String? {
        let p = path.appendingPathComponent(name)
        var t: String?
        //reading
        do {
            t = try String(contentsOf: p, encoding: String.Encoding.utf8)
            print("讀取檔案成功: \n 檔名: \(name) \n路徑: \(path)\(name)")
        } catch {
            print("讀取檔案失敗: \n 檔名: \(name) \n路徑: \(path)\(name)")
        }
        return t
    }


    public static func getFilePath(name: String) -> URL {
        let p = storageDir.appendingPathComponent(name)
        return p
    }

}
