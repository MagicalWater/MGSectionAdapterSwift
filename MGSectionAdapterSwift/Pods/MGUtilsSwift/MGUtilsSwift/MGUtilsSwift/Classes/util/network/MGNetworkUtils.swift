//
//  MGNetworkUtils.swift
//  MGUtilsSwift
//
//  Created by Magical Water on 2018/9/29.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit
import CoreServices

public class MGNetworkUtils: NSObject {
    
    public override init() {
        super.init()
    }
    
    public static var share: MGNetworkUtils { return MGNetworkUtils() }
    
    private var downloadSessionConfig: URLSessionConfiguration = {
        let configiguration = URLSessionConfiguration.default
        configiguration.timeoutIntervalForRequest = .infinity
        return configiguration
    }()
    
    private lazy var downloadSession: URLSession = {
        //當 delegateQueue 沒有設置時,session会创建一个串行隊列，並且在該隊列中執行操作
        return URLSession(configuration: downloadSessionConfig, delegate: self, delegateQueue: nil)
    }()
    
    //儲存正在下載的task request, 對應要下載到的目錄位置
    private var donwloadingTask: [URLRequest : (URL, URLSessionDownloadTask)] = [:]
    
    public enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    
    /*
     GET 異步獲取
     */
    public func get(url: URL, params: [String : Any]?, paramEncoding: MGParamEncoding,
                    headers: [String : String]?, completeHandler: ((MGNetworkResponse) -> Void)? = nil) {
        do {
            let request = try generateRequest(url: url, params: params, paramEncoding: paramEncoding, headers: headers, method: .get)
            executeRequest(request: request, completeHandler: completeHandler)
        } catch {
            let response = MGNetworkResponse.init(data: nil, statusCode: nil, responseHeaders: nil, error: error)
            completeHandler?(response)
        }
    }
    
    /*
     POST 異步獲取
     */
    public func post(url: URL, params: [String : Any]?, paramEncoding: MGParamEncoding, headers: [String : String]?, completeHandler: ((MGNetworkResponse) -> Void)? = nil) {
        do {
            let request = try generateRequest(url: url, params: params, paramEncoding: paramEncoding, headers: headers, method: .post)
            executeRequest(request: request, completeHandler: completeHandler)
        } catch {
            let response = MGNetworkResponse.init(data: nil, statusCode: nil, responseHeaders: nil, error: error)
            completeHandler?(response)
        }
    }
    
    /*
     上傳 使用 POST
     */
    public func upload(url: URL, datas: [MGNetworkUploadData], params: [String : Any]?, paramEncoding: MGParamEncoding,
                       headers: [String : String]?, completeHandler: ((MGNetworkResponse) -> Void)? = nil) {
        let requestPair = generateUploadRequest(url: url, datas: datas, params: params, headers: headers)
        executeUploadRequest(request: requestPair.0, data: requestPair.1)
    }
    
    /*
     下載 使用 GET
     */
    public func download(url: URL, destination: URL, params: [String : Any]?, headers: [String : String]?, completeHandler: ((MGNetworkResponse) -> Void)? = nil) {
        let request = generateDownloadRequest(url: url, params: params, headers: headers)
        executeDownloadRequest(request: request, destination: destination, completeHandler: completeHandler)
    }
    
    private func handleResponse(data: Data?, response: URLResponse?, error: Error?) -> MGNetworkResponse {
        
        if let httpResponse = response as? HTTPURLResponse {
            let statusCode: Int? = httpResponse.statusCode
            let headers = httpResponse.allHeaderFields
            return MGNetworkResponse.init(data: data, statusCode: statusCode, responseHeaders: headers, error: error)
        } else {
            return MGNetworkResponse.init(data: data, statusCode: nil, responseHeaders: nil, error: error)
        }
    }
    
}

//生成 URLRequest 實例
extension MGNetworkUtils {
    
    //取得一般資料的 URLRequest 實例
    private func generateRequest(url: URL, params: [String : Any]?, paramEncoding: MGParamEncoding,
                                 headers: [String : String]?, method: Method) throws -> URLRequest {
        var request = URLRequest.init(url: url)
        request.httpMethod = method.rawValue
        
        setHeader(request: &request, headers: headers)
        
        guard let params = params else {
            return request
        }
        
        try paramEncoding.encode(request: &request, params: params, method: method)
        
        return request
    }
    
    //取得上傳檔案的 URLRequest 實例
    private func generateUploadRequest(url: URL, datas: [MGNetworkUploadData], params: [String : Any]?, headers: [String : String]?) -> (URLRequest, Data) {
        
        var request = URLRequest.init(url: url)
        request.httpMethod = Method.post.rawValue
        
        setHeader(request: &request, headers: headers)
        
        //有看到另外一個人寫法是這樣, 但不清楚是否都可以, 因此保留
        //        let boundary = "Boundary+\(arc4random())\(arc4random())"
        let boundary = String(format: "boundary.%08x%08x", arc4random(), arc4random())
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        //將上傳的 檔案 與 參數 包裝成 Data
        let data = combinationData(boundary: boundary, datas: datas, params: params)
        
        return (request, data)
    }
    
    //取得下載檔案的 URLRequest 實例
    private func generateDownloadRequest(url: URL, params: [String : Any]?, headers: [String : String]?) -> URLRequest {
        
        var request = URLRequest.init(url: url)
        request.httpMethod = Method.get.rawValue
        
        setHeader(request: &request, headers: headers)
        
        guard let params = params else {
            return request
        }
        
        try! MGURLEncoding.default.encode(request: &request, params: params, method: .get)
        
        return request
    }
}

//處理參數
extension MGNetworkUtils {
    
    //設置要求頭
    func setHeader(request: inout URLRequest, headers: [String : String]?) {
        if let headers = headers {
            for (headerField, headerValue) in headers {
                request.setValue(headerValue, forHTTPHeaderField: headerField)
            }
        }
    }
    
    //傳入參數, 轉為參數字串
    static func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    //傳入參數, 平鋪所有key以及對應的參數
    static func queryDictionary(_ parameters: [String: Any]) -> [String : String] {
        var components: [(String, String)] = []
        
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        
        var maps: [String:String] = [:]
        components.forEach {
            maps[$0.0] = $0.1
        }
        return maps
    }
    
    /*
     傳入某個key與對應的value, 平鋪此key下的所有的參數
     */
    private static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            //value是個字典, 需要再繼續往下循環調用此方法取出平鋪的參數
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            //value是個陣列, 依照陣列的顯示方式, 將key後面加上順序Index - [0] [1]...,  之後往下循環調用取出平鋪的參數
            for i in 0..<array.count {
                components += queryComponents(fromKey: "\(key)[\(i)]", value: array[i])
            }
        } else if let value = value as? NSNumber {
            //value是數字相關的值
            components.append((escape(key), escape("\(value)")))
        } else if let bool = value as? Bool {
            //value是布爾相關的值
            components.append((escape(key), escape("\(bool)")))
        } else {
            //value不再上列(直接轉成字串)
            components.append((escape(key), escape("\(value)")))
        }
        
        return components
    }
    
    
    /*
     這邊參考 alamofire 加入參數時對字串的處理, 具體如何還不清楚, 因此此段說明暫先保留
     */
    /// Returns a percent-escaped string following RFC 3986 for a query string key or value.
    ///
    /// RFC 3986 states that the following characters are "reserved" characters.
    ///
    /// - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
    /// - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
    ///
    /// In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
    /// query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
    /// should be percent-escaped in the query string.
    ///
    /// - parameter string: The string to be percent-escaped.
    ///
    /// - returns: The percent-escaped string.
    private static func escape(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowedCharacterSet = CharacterSet.urlQueryAllowed
        allowedCharacterSet.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        
        let escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? string
        
        return escaped
    }
    
}

//處理上傳檔案的資料
extension MGNetworkUtils {
    
    //換行符號, 上傳檔案的參數與檔案需要按照一定格式
    private var crlf: String {
        return "\r\n"
    }
    
    enum UploadError: Error {
        case noSupportUrl //暫時不支援url上傳
        case noMatchType //沒有找到可以處理的類型
        
        var localizedDescription: String {
            switch self {
            case .noMatchType:
                return "上傳檔案出錯 - 沒有找到對應的類型"
            case .noSupportUrl:
                return "上傳檔案出錯 - 暫時不支援 url"
            }
        }
    }
    
    //將上傳檔案需要帶入的參數與檔案包裝成Data
    private func combinationData(boundary: String, datas: [MGNetworkUploadData], params: [String : Any]?) -> Data {
        //使用 Data 裝載參數以及檔案
        var body = Data()
        
        //處理參數加入
        if let params = params {
            for (paramKey, paramValue) in params {
                body.append(string: "--\(boundary)\(crlf)")
                body.append(string: "Content-Disposition: form-data; name=\"\(paramKey)\"\(crlf)\(crlf)")
                body.append(string: "\(paramValue)\(crlf)")
            }
        }
        
        //處理上傳的文件
        for uploadData in datas {
            body.append(string: "--\(boundary)\(crlf)")
            body.append(string: "Content-Disposition: form-data; name=\"\(uploadData.name)\"; filename=\"\(uploadData.fileName)\"\(crlf)")
            
            do {
                let dataPart = try convertData(data: uploadData.data)
                if let mimeType = dataPart.1 {
                    body.append(string: "Content-Type: \(mimeType)\(crlf)\(crlf)")
                }
                body.append(dataPart.0)
            } catch {
                print("\(error.localizedDescription)")
            }
            body.append(string: "\(crlf)")
        }
        
        body.append(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    //傳入一個資料, 自動將其轉換成可上傳的類型以及mimetype
    private func convertData(data: Any) throws -> (Data,String?) {
        if let data = data as? Data {
            return (data, nil)
        } else if let img = data as? UIImage {
            //這邊自動將圖片壓縮為jpg
            let jpegData = img.jpegData(compressionQuality: 1.0)!
            return (jpegData, "image/jpg")
        } else if let string = data as? String {
            //若是一個字串, 則應該轉為 data
            let stringData = string.data(using: .utf8)!
            return (stringData, nil)
        } else if let _ = data as? URL {
            //上傳的 url 必須是一個 fileURL, 後續步驟過於複雜, 這邊暫時不加入
            throw UploadError.noSupportUrl
        }
        
        //沒找到對應的類型
        throw UploadError.noMatchType
    }
    
    //根據 url 的尾端 extesion 判斷 mineType
    private func mimeType(forPathExtension pathExtension: String) -> String {
        if let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return contentType as String
        }
        
        return "application/octet-stream"
    }
}

//處理下載相關回調
extension MGNetworkUtils: URLSessionDownloadDelegate {
    
    //下載完成回傳通知
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        if let requst =  downloadTask.currentRequest,
            let downloadPair = donwloadingTask[requst] {
            //系統默認下載位置
//            print("系統默認下載位置: \(location)")
            //移動到目地位置
            let fileMaanager = FileManager.default
            do {
                try fileMaanager.moveItem(at: location, to: downloadPair.0)
            } catch {
                print("下載檔案後, 移動過程出現錯誤: \(error.localizedDescription)")
            }
//            print("移動完畢: \(downloadPair.0)")
        }
    }
    
    //在此監控進度
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                           didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print(progress)
    }
    
}


//執行任務
extension MGNetworkUtils {
    
    //執行一般 request, 使用獲取資料的 URLSession
    private func executeRequest(request: URLRequest, completeHandler: ((MGNetworkResponse) -> Void)? = nil) {
        let getTask = URLSession.shared.dataTask(with: request) { data, response, error in
            let connectResponse = self.handleResponse(data: data, response: response, error: error)
            completeHandler?(connectResponse)
//            if let connectResponse = self.handleResponse(data: data, response: response, error: error) {
//                completeHandler?(connectResponse)
//            }
        }
        
        getTask.resume()
    }
    
    //執行下載任務
    private func executeDownloadRequest(request: URLRequest, destination: URL, completeHandler: ((MGNetworkResponse) -> Void)? = nil) {
        let downloadTask = downloadSession.downloadTask(with: request) { fileURL, response, error in
            self.donwloadingTask.removeValue(forKey: request)
            let connectResponse = self.handleResponse(data: nil, response: response, error: error)
            completeHandler?(connectResponse)
//            if let connectResponse = self.handleResponse(data: nil, response: response, error: error) {
//                completeHandler?(connectResponse)
//            }
        }
        donwloadingTask[request] = (destination, downloadTask)
        downloadTask.resume()
    }
    
    //執行上傳任務
    private func executeUploadRequest(request: URLRequest, data: Data, completeHandler: ((MGNetworkResponse) -> Void)? = nil) {
        let uploadTask = URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            let connectResponse = self.handleResponse(data: data, response: response, error: error)
            completeHandler?(connectResponse)
//            if let connectResponse = self.handleResponse(data: data, response: response, error: error) {
//                completeHandler?(connectResponse)
//            }
        }
        uploadTask.resume()
    }
}

//上傳檔案時, 讓 Data 可以直接傳入字串
public extension Data{
    
    mutating func append(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}
