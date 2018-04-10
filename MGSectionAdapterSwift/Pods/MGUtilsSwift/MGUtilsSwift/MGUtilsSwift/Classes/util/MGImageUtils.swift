//
//  MGImageUtils.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/24.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher


//將圖檔轉為字串, 或者字串轉為圖檔
public class MGImageUtils {

    private init() {}

    public static func toBase64String(_ image: UIImage) -> String? {
        //Now use image to create into NSData format
        let imageData = UIImagePNGRepresentation(image)
        let strBase64 = imageData?.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }

    public static func toImage(_ base64: String) -> UIImage? {
        let dataDecoded = Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
        if let data = dataDecoded {
            return UIImage(data: data)
        }
        return nil
    }

    static public func load(_ imageView: UIImageView, url: URL) {
        imageView.kf.setImage(with: url)
    }

    public static func load(_ url: URL, handler: @escaping (UIImage?) -> Void) {
        KingfisherManager.shared.retrieveImage(
            with: url,
            options: nil,
            progressBlock: nil
        ) { (image, error, cacheType, imageURL) -> () in
            handler(image)
        }
    }
}
