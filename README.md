# MGSectionAdapterSwift
![](https://img.shields.io/cocoapods/v/MGSectionAdapterSwift.svg?style=flat) 
![](https://img.shields.io/badge/platform-ios-lightgrey.svg) 
![](https://img.shields.io/badge/language-swift-orange.svg)  

TableView/CollectionView 通用 Adapter  
如同於 Android 的 RecyclerView Adapter 的概念  
功能:  
1. 置頂/更多加載, 下拉刷新  
2. 擁有無限層級, 讓每個cell都可為一個section  

## 版本
1.0.0 - 1. 更新 swift 版本至 4.2.  
            2. 修正 MGBaseTableAdapter 的 section header/footer 無法正常顯示的問題.  
            3. 加入 MGVerticalCollectionAdapter, 直式collection adapter的封裝.  
            4. 刪除 MGBaseCollectionAdapter 中默認加入自適應寬高, 造成自訂 size 出錯的問題.  
            5. 修正 MGBaseCollectionAdapter 使用 sectionHeaderView 後出現崩潰.  
            6. 修正 MGBaseCollectionAdapter 若設置寬高距離會造成排版出錯.  
0.0.3 - 因應 MGUtils 的 JSON 工具名稱改變, 修改相對應的名稱  
0.0.2 - 因應操作流暢度問題, 置頂/更多 加載方式更改為靜態顯示, 而非動畫顯示
0.0.1 - 初始提交專案  

## 添加依賴  

### Cocoapods
pod 'MGSectionAdapterSwift', '~> {version}'  
( 其中 {version} 請自行替入此版號 ![](https://img.shields.io/cocoapods/v/MGSectionAdapterSwift.svg?style=flat) )  
