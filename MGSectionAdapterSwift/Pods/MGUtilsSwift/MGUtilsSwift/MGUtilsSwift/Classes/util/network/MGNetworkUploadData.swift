//
//  MGNetworkUploadData.swift
//  MGUtilsSwift
//
//  Created by Magical Water on 2018/9/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

//上傳檔案的struct
public class MGNetworkUploadData {
    public var name: String
    public var fileName: String
    public var data: Any
    
    public init(name: String, fileName: String, data: Any) {
        self.name = name
        self.fileName = fileName
        self.data = data
    }
}
