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
    public static var documentDir: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

    //寫入字串, 帶入檔案跟路徑
    public static func write(_ name: String, content: String, path: URL = documentDir) {
        let p = path.appendingPathComponent(name)
        write(p, content: content)
    }

    //寫入字串, 直接帶入url
    public static func write(_ url: URL, content: String) {
        do {
            try content.write(to: url, atomically: false, encoding: String.Encoding.utf8)
            print("寫入檔案成功: \n 檔名: \(url.lastPathComponent) \n路徑: \(url.absoluteString)")
        } catch {
            print("寫入檔案失敗: \n 檔名: \(url.lastPathComponent) \n路徑: \(url.absoluteString)")
        }
    }

    //讀取檔案內容, 帶入路徑跟檔名
    public static func read(_ name: String, path: URL = documentDir) -> String? {
        let p = path.appendingPathComponent(name)
        return read(p)
    }

    //讀取檔案內容, 直接帶入url
    public static func read(_ url: URL) -> String? {
        var t: String?
        do {
            t = try String(contentsOf: url, encoding: String.Encoding.utf8)
            print("讀取檔案成功: \n 檔名: \(url.lastPathComponent) \n路徑: \(url.absoluteString)")
        } catch {
            print("讀取檔案失敗: \n 檔名: \(url.lastPathComponent) \n路徑: \(url.absoluteString)")
        }
        return t
    }

    //刪除某個文件(夾), 帶入路徑跟檔名
    public static func delete(_ name: String, path: URL = documentDir) -> Bool {
        let p = path.appendingPathComponent(name)
        if FileManager.default.isDeletableFile(atPath: p.absoluteString) {
            do { try FileManager.default.removeItem(at: p) }
            catch { return false }
            return true
        }
        return false
    }

    //刪除某個文件夾裡的所有資料
    public static func delete(_ dirURL: URL) -> Bool {
        var fileList: [String] = []
        do {
            fileList = try FileManager.default.contentsOfDirectory(atPath: dirURL.absoluteString)
        } catch {
            return false
        }

        for fileName in fileList {
            _ = delete(fileName, path: dirURL)
        }
        return true
    }

    //得到在document底下某個資料夾的URL, 若底下沒有此資料夾, 則自動創建
    public static func getDirURL(_ dirName: String, path: URL = documentDir) -> URL {
        let p = path.appendingPathComponent(dirName)
        //檢查資料夾是否存在
        if !FileManager.default.fileExists(atPath: p.absoluteString) {
            //withIntermediateDirectories: 不管指定的目錄名稱中間的目錄是否存在，它都會自動不存在的目錄並將所有目錄建立完成
            try? FileManager.default.createDirectory(at: p, withIntermediateDirectories: true, attributes: nil)
        }
        return p
    }

    public static func getFilePath(_ name: String, path: URL = documentDir) -> URL {
        let p = path.appendingPathComponent(name)
        return p
    }

}
