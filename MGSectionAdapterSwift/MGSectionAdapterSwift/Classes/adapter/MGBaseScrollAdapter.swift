//
//  MGBaseAdapter.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/5.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit


/*
 adapter最底層, 監測滑動
 之所以不另封裝成helper
 是因為tableView和collectionView的delegate繼承於UIScrollViewDelegate
 因此兩者無法分開設置
 */
open class MGBaseScrollAdapter: NSObject {

    //滑動方向委託回調
    weak var scrollDirectionDelegate: MGBaseScrollDelegate?

    //滑動監測方向默認為垂直
    var scrollOrientation: ScrollOrientation = .vertical

    //檢測當滑動距離(nowScrollValue)超過此值, 則判定滑動某個方向中開始
    var scrollActiveRange: CGFloat = 50

    //儲存滑動累積的距離
    private var nowScrollValue: CGFloat = 0


    //儲存當前的scrollView位置是否為頂/底
    private var isTop = false
    private var isBottom = false

    //滑動監測方向
    public enum ScrollOrientation{
        case vertical
        case horizontal
    }


    //正在滑動的方向
    public enum ScrollDirection {
        case none
        case up
        case down
        case left
        case right
    }

    //滑動邊界
    public enum ScrollBoundary {
        case none
        case top
        case bottom
        case leading
        case trailing
    }

}


//基於滑動方向之類
extension MGBaseScrollAdapter: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {

        //只有當委託回調有設置了才會進行回調
        guard let delegate = scrollDirectionDelegate else {
            return
        }


        var offset: CGFloat //將要依照方向不同儲存位移的距離
        var viewBound: CGFloat //依照方向不同儲存view的寬或高
        var viewContent: CGFloat //依照方向不同儲存內容的寬或高

        var upperBound: ScrollBoundary //上邊界
        var lowerBound: ScrollBoundary //下邊界

        var negativeDirection: ScrollDirection //負向滑動 (例: 垂直滑動 -> 向上滑動, 水平滑動 -> 向左滑動)
        var positiveDirection: ScrollDirection //正向滑動 (例: 垂直滑動 -> 向下滑動, 水平滑動 -> 向右滑動)

        //依照監測方向不同而獲取不同數值
        switch scrollOrientation {
        case .vertical:
            offset = scrollView.contentOffset.y
            viewBound = scrollView.bounds.height
            viewContent = scrollView.contentSize.height
            upperBound = .top
            lowerBound = .bottom
            negativeDirection = .up
            positiveDirection = .down
        case .horizontal:
            offset = scrollView.contentOffset.x
            viewBound = scrollView.bounds.width
            viewContent = scrollView.contentSize.width
            upperBound = .leading
            lowerBound = .trailing
            negativeDirection = .left
            positiveDirection = .right
        }

        //檢測是否超過上下界, 若是則不用判定滑動方向, 直接傳送值給 delegate
        if offset <= 0 {
            if !isTop {
                //超過上界, 依照方向分別是 top 或 leading
                isTop = true
                topReach(delegate, boundary: upperBound)
            }
            return
        } else if offset >= viewContent - viewBound {
            if !isBottom {
                //到底步, 下方欄位彈出
                isBottom = true
                bottomReach(delegate, boundary: lowerBound)
            }
            return
        } else {
            isTop = false
            isBottom = false
        }


        if nowScrollValue == 0 {
            nowScrollValue = scrollView.contentOffset.y
        } else if offset - nowScrollValue > scrollActiveRange {
            //超過判定數值, 依照方向判定為滑動方向 down 或者 right(正向滑動)
            delegate.scrollActive(positiveDirection, boundary: .none)
            nowScrollValue = scrollView.contentOffset.y
        } else if scrollView.contentOffset.y - nowScrollValue < -scrollActiveRange {
            //超過判定數值, 依照方向判定為滑動方向 up 或者 left(負向滑動)
            delegate.scrollActive(negativeDirection, boundary: .none)
            nowScrollValue = scrollView.contentOffset.y
        }

    }


    //上邊界達到
    private func topReach(_ delegate: MGBaseScrollDelegate, boundary: MGBaseScrollAdapter.ScrollBoundary) {
        scrollDirectionDelegate?.scrollActive(.none, boundary: boundary)
    }


    //下邊界達到
    private func bottomReach(_ delegate: MGBaseScrollDelegate, boundary: MGBaseScrollAdapter.ScrollBoundary) {
        scrollDirectionDelegate?.scrollActive(.none, boundary: boundary)
    }
}

//監測滑動狀態委託
public protocol MGBaseScrollDelegate: class {
    func scrollActive(_ direction: MGBaseScrollAdapter.ScrollDirection, boundary: MGBaseScrollAdapter.ScrollBoundary)
}

