//
//  MGPhotoPickerUtils.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/3/1.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import CLImagePickerTool


//照片選擇工具
public class MGPhotoPickerUtils {

    weak public var pickerDelegate: MGPhotoPickerDelegate?
//    var photoPicker
    public init() {}

    //選擇圖庫圖片
    public func singlePicker(_ inVC: UIViewController, crop: Bool) {
        let imagePickTool = CLImagePickerTool()
        imagePickTool.singleImageChooseType = crop ? CLImagePickerToolType.singlePictureCrop : CLImagePickerToolType.singlePicture
        imagePickTool.setupImagePickerWith(MaxImagesCount: 1, superVC: inVC) { (asset, cutImage) in

            self.pickerDelegate?.pickerImage(cutImage!)

            //获取缩略图，耗时较短
//            let imageArr = CLImagePickersTool.convertAssetArrToThumbnailImage(assetArr: asset, targetSize: CGSize(width: 80, height: 80))
//            print(imageArr)


            // 获取原图，异步
//            var imageArr = [UIImage]()

//            CLImagePickersTool.convertAssetArrToOriginImage(
//                assetArr: asset, scale: 1,
//                successClouse: { [weak self] (image,assetItem) in
////                    imageArr.append(image)
//                    self?.pickerDelegate?.pickerImage(image)
//                }, failedClouse: { () in
//                    MGToastUtils.show("發生錯誤")
//            })
        }
    }

}


//得到uiimage回調
public protocol MGPhotoPickerDelegate : class {
    func pickerImage(_ image: UIImage)
}
