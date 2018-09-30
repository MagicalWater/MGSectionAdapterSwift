//
//  MGVerticalCollectionAdapter.swift
//  MGSectionAdapterSwift
//
//  Created by Magical Water on 2018/9/30.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

open class MGVerticalCollectionAdapter: MGBaseCollectionAdapter {
    
    public init(_ collectionView: UICollectionView) {
        super.init(collectionView, orientation: MGBaseScrollAdapter.ScrollOrientation.vertical)
    }
    
    final override public func customSectionCellSize(_ indexPath: IndexPath, section: MGSection) -> CGSize? {
        let spanAndHeight = itemSpanAndHeight(section: section)
        let fillCount = spanAndHeight.0
        let height = spanAndHeight.1
        
        let totalWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        let freeSpace = totalWidth - (interitemSpace * CGFloat(fillCount - 1) + 0.1)
        
        let width = freeSpace / CGFloat(fillCount)
        
        return CGSize.init(width: width, height: height)
    }
    
    final override public func customSectionHeaderSize(_ section: Int, header: MGSectionGroup.MGSectionHeader) -> CGSize? {
        let spanAndHeight = itemHeaderSpanAndHeight(section: section)
        let fillCount = spanAndHeight.0
        let height = spanAndHeight.1
        
        let totalWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        
        let width = totalWidth / CGFloat(fillCount)
        
        return CGSize.init(width: width, height: height)
    }
    
    final override public func customSectionFooterSize(_ section: Int, footer: MGSectionGroup.MGSectionFooter) -> CGSize? {
        let spanAndHeight = itemFooterSpanAndHeight(section: section)
        let fillCount = spanAndHeight.0
        let height = spanAndHeight.1
        
        let totalWidth = collectionView.bounds.width - sectionInset.left - sectionInset.right
        
        let width = totalWidth / CGFloat(fillCount)
        
        return CGSize.init(width: width, height: height)
    }
    
    /*
     改寫此方法回傳佔用寬度, 以及精確高度
     此 section 的 item 要佔用一列的寬度比例, 假設現在一列寬度為 100
     (回傳 1 代表佔用 1/1 * 100 = 100, 回傳 2 代表佔用 1/2 * 100 = 50)
     
     回傳 (span: Int, height: CGFloat)
     */
    open func itemSpanAndHeight(section: MGSection) -> (Int,CGFloat) {
        return (1,0)
    }
    
    /*
     改寫此方法回傳section header佔用寬度, 以及精確高度
     此 section 的 item 要佔用一列的寬度比例, 假設現在一列寬度為 100
     (回傳 1 代表佔用 1/1 * 100 = 100, 回傳 2 代表佔用 1/2 * 100 = 50)
     
     回傳 (span: Int, height: CGFloat)
     */
    open func itemHeaderSpanAndHeight(section: Int) -> (Int,CGFloat) {
        return (1,0)
    }
    
    /*
     改寫此方法回傳section footer佔用寬度, 以及精確高度
     此 section 的 item 要佔用一列的寬度比例, 假設現在一列寬度為 100
     (回傳 1 代表佔用 1/1 * 100 = 100, 回傳 2 代表佔用 1/2 * 100 = 50)
     */
    open func itemFooterSpanAndHeight(section: Int) -> (Int,CGFloat) {
        return (1,0)
    }
    
}
