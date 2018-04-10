//
//  MGBannerView.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/2/22.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit
//import MGBase

/*
 輪播view, 最外層由一個scroll view跟 page control 組成
 scrollview裡面加入兩個需要輪播得view, 達成無限多個view的效果
 */

public class MGBannerView: UIView {

    public var autoScrollTimeInterval: TimeInterval = 5  //自動滾動間隔
    private var scrollView: UIScrollView?                //左右滑動view
    private var pageControl: UIPageControl?              //分頁控制器
    private var currentView: UIView?                     //當前view
    private var nextView: UIView?                        //下個view
    private var currentIndex: NSInteger?                 //當前index
    private var nextIndex: NSInteger?                    //下一個index
    private var timer: Timer?                            //定時器

    public weak var bannerDelegate: MGBannerDelegate? {          //banner相關delegate
        didSet { setupView() }
    }

    override public var bounds: CGRect {
        didSet { setupView() }
    }

    //是否無限輪播
    @IBInspectable var infiniteLoop: Bool = true

    //自動滾動
    @IBInspectable var enableAutoScroll: Bool = true {
        didSet {
            if enableAutoScroll { self.startTimer() }
            else { self.stopTimer() }
        }
    }

    public var direction: Direction = .none {                   //滾動方向
        didSet {
            guard let bannerCount = pageControl?.numberOfPages,
                let d = bannerDelegate, bannerCount > 0,
                direction != oldValue else {
                    return
            }

            switch direction {
            case .right:
                //向右滾動
                nextView?.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
                nextIndex = currentIndex!-1
                if nextIndex! < 0 {
                    nextIndex = bannerCount - 1
                }
            case .left:
                //向左滾動
                nextView?.frame = CGRect(x: 2 * frame.width, y: 0, width: frame.width, height: frame.height)
                nextIndex = (currentIndex!+1) % bannerCount
            default: break
            }

            if let i = nextView {
                d.willChange(view: i, index: nextIndex!)
            }
        }
    }


    public enum Direction {
        case left    //向左滑
        case right   //向右滑
        case none    //未滑动
    }


    override public init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }


    //初始化scroll view 跟 page control
    private func initView() {

        scrollView = UIScrollView(frame: frame)
        scrollView?.delegate = self
        scrollView?.isPagingEnabled = true
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.bounces = false
        self.addSubview(scrollView!)

        scrollView?.translatesAutoresizingMaskIntoConstraints = false
        scrollView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        scrollView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        scrollView?.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        scrollView?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true

        pageControl = UIPageControl(frame: CGRect(x: 0, y: frame.height - CGFloat(20), width: frame.width, height: 20))
        pageControl?.pageIndicatorTintColor = UIColor.lightGray.withAlphaComponent(0.6)
        pageControl?.currentPageIndicatorTintColor = UIColor.white.withAlphaComponent(0.7)
        pageControl?.isUserInteractionEnabled = false
        self.addSubview(pageControl!)

        pageControl?.translatesAutoresizingMaskIntoConstraints = false
        pageControl?.heightAnchor.constraint(equalToConstant: 20).isActive = true
        pageControl?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        pageControl?.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        pageControl?.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }

    //設定廣告橫幅相關
    private func setupView() {
        guard let d = bannerDelegate else {
            return
        }

        scrollView?.contentSize = CGSize(width: self.bounds.width * 3, height: self.bounds.height)
        scrollView?.setContentOffset(CGPoint(x: self.bounds.width, y: 0), animated: false)

        currentView?.removeFromSuperview()
        nextView?.removeFromSuperview()

        let nowRect = CGRect(x: bounds.width, y: 0, width: bounds.width, height: bounds.height)
        let nextRect = CGRect(x: bounds.width * 2, y: 0, width: bounds.width, height: bounds.height)
        let vs = d.bannerView(nowRect, next: nextRect)

        currentView = vs.current
        nextView = vs.next

        scrollView?.addSubview(vs.next)
        scrollView?.addSubview(vs.current)

        resetDisplay()

    }


    public func getCurrentIndex() -> Int {
        return currentIndex ?? 0
    }

    //重置顯示
    public func resetDisplay() {

        guard let bannerDelegate = bannerDelegate, let cv = currentView else {
            return
        }
        bannerDelegate.willChange(view: cv, index: 0)

        currentIndex = 0
        nextIndex = 0

        pageControl?.currentPage = currentIndex!
        pageControl?.numberOfPages = bannerDelegate.bannerCount()

        if enableAutoScroll {
            self.startTimer()
        } else {
            self.stopTimer()
        }
    }

    deinit {
        stopTimer()
    }

    //開啟計時器
    private func startTimer() {
        self.stopTimer()
        if let n = pageControl?.numberOfPages, n > 1 {
            timer = Timer.scheduledTimer(timeInterval: autoScrollTimeInterval, target: self, selector: #selector(self.nextImage), userInfo: nil, repeats: true)
        }
    }

    //關閉計時器
    private func stopTimer() {
        if let t = timer, t.isValid {
            t.invalidate()
        }
        timer = nil
    }

    //滾動到下個view, 滾動時禁止觸摸
    @objc public func nextImage() {
        self.isUserInteractionEnabled = false
        scrollView?.setContentOffset(CGPoint(x: frame.width * 2, y: 0), animated: true)
    }

    //滾動到上個view, 滾動時禁止觸摸
    public func preImage() {
        self.isUserInteractionEnabled = false
        scrollView?.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }


    //停止滾動
    private func pauseScroll() {
        let offset = self.scrollView!.contentOffset.x

        let index = offset / frame.width

        //1表示沒有滾動
        if index == 1 { return }

        //滑動結束後, 將當前頁面轉為 中間頁面
        self.currentIndex = self.nextIndex
        self.pageControl?.currentPage = self.currentIndex!

        self.currentView?.frame = CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height)
        self.scrollView?.setContentOffset(CGPoint(x: frame.width, y: 0), animated: false)

        if let cv = currentView, let ci = currentIndex {
            bannerDelegate?.willChange(view: cv, index: ci)
        }

    }

}


extension MGBannerView : UIScrollViewDelegate {

    // MARK: - ----UIScrollViewDelegate-----
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX = scrollView.contentOffset.x

        //判斷是否無限輪播
        if infiniteLoop {
            self.direction = offsetX > frame.width ? .left : offsetX < frame.width ? .right : .none
        } else {
            if pageControl!.currentPage + 1 == pageControl?.numberOfPages && offsetX > frame.width {
                scrollView.setContentOffset(CGPoint.init(x: frame.width, y: 0), animated: false)
                self.direction = .none
            } else if pageControl!.currentPage == 0 && offsetX < frame.width {
                scrollView.setContentOffset(CGPoint.init(x: frame.width, y: 0), animated: false)
                self.direction = .none
            } else {
                self.direction = offsetX > frame.width ? .left : offsetX < frame.width ? .right : .none
            }
        }
    }

    //當結束滾動時, 開啟觸摸
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isUserInteractionEnabled = true
        self.pauseScroll()
    }

    //當結束滾動時, 開啟觸摸
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.isUserInteractionEnabled = true
        self.pauseScroll()
    }

    //開始拖曳時, 停止計時器
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.stopTimer()
    }

    //拖曳結束後, 判斷是否需要自動滾動
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isUserInteractionEnabled = true
        if enableAutoScroll {
            self.startTimer()
        }
    }

}

public protocol MGBannerDelegate: class {
    func bannerView(_ current: CGRect, next: CGRect) -> (current: UIView, next: UIView)
    func willChange(view: UIView, index: Int)
    func bannerCount() -> Int
}



