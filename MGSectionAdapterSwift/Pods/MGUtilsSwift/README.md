# MGUtilsSwift

![](https://img.shields.io/cocoapods/v/MGUtilsSwift.svg?style=flat) 
![](https://img.shields.io/badge/platform-ios-lightgrey.svg) 
![](https://img.shields.io/badge/language-swift-orange.svg)  

所有蒐集的工具類    

## 版本 
1.0.0 - 1. 新增 MGNetworkUtils, 處理所有網路要求相關.  
            2. 暫時移除圖片選擇工具 MGPhotoPickerUtils.  
            3. 更新 swift version 到 4.2.  
0.2.0 - 為 MGImageUtils 所使用的 lib: Kingfisher 指定 4.9.0 版本  
0.1.9 - MGNetworkDetectUtils 新增 取得外部ip方法, getPublicIpAddress()  
0.1.8 - MGNetworkDetectUtils 新增 取得區網ip (非外部ip)  
0.1.7 - 新增 MGVersionUtils, 可用來比較版號, 更改 MGSettingUtils 的相關方法名稱  
0.1.6 - MGJsonDataParseUtils 更名為 MGJsonUtils, 反序列化方法增加泛型  
0.1.5 - 新增 MGResourceUtils, 讀取資源文件  
0.1.4 - 依照 MGPhotoPickerUtils 所依賴的 CLImagePickerTool 類名更改 修改對應 code     
0.1.3 - FileUtils新增刪除檔案  

## 添加依賴

### Cocoapods
pod 'MGUtilsSwift', '~> {version}'  
( 其中 {version} 請自行替入此版號 ![](https://img.shields.io/cocoapods/v/MGUtilsSwift.svg?style=flat)  )  
