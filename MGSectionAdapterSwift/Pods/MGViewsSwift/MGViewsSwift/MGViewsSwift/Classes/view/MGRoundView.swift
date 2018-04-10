//
//  MGRoundView.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/18.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit
import MGBaseViewSwift

@IBDesignable public class MGRoundView : MGBaseView {


    public enum RoundType: Int {
        case rect = 0 //方形
        case traingle = 1 //三角形
        case circle = 2 //圓形
    }

    //支持在nib直接設定元件類型
    @IBInspectable public var roundTypeNib: Int = RoundType.rect.rawValue {
        didSet { roundType = RoundType.init(rawValue: roundTypeNib)! }
    }

    //元件形狀類型
    public var roundType: RoundType = .rect {
        didSet { updateUI() }
    }


    //************** 方形用 **************
    //各個角邊圓弧, 只有在形狀是方形時有用
    @IBInspectable public var radius: CGFloat = 10 {
        didSet { updateUI() }
    }

    @IBInspectable public var topLeft: Bool = true {
        didSet { updateUI() }
    }
    @IBInspectable public var bottomLeft: Bool = true {
        didSet { updateUI() }
    }
    @IBInspectable public var topRight: Bool = true {
        didSet { updateUI() }
    }
    @IBInspectable public var bottomRight: Bool = true {
        didSet { updateUI() }
    }
    //************** 方形用 **************


    //************** 三角形用 **************
    //儲存三角形的三個點
    //點對應的代號
    //1 2 3
    //4 5 6
    //7 8 9

    //這邊填入 string, 在分割成陣列
    @IBInspectable public var pointString: String = "1,5,3" {
        didSet { updateUI() }
    }
    //************** 三角形用 **************


    //虛線設置相關
    @IBInspectable public var strokeDash: Bool = false {
        didSet { updateUI() }
    }

    //虛線繪製: phase表示开始绘制之前跳过多少点进行绘制，默认一般设置为0，第二张图片是设置5的实际效果图.

    //虛線繪製: lengths通常都包含两个数字，第一个是绘制的宽度，第二个表示跳过的宽度，也可以设置多个，第三张图是设置为三个参数的实际效果图.绘制按照先绘制，跳过，再绘制，再跳过，无限循环.
    //例如 let lengths:[CGFloat] = [10,20,10] // 绘制 跳过 无限循环</code></pre>


    @IBInspectable public var dashLength: Double = 10 {
        didSet { updateUI() }
    }

    @IBInspectable public var dashSpace: Double = 5 {
        didSet { updateUI() }
    }


    @IBInspectable public var strokeColor: UIColor = UIColor.black {
        didSet { updateUI() }
    }

    //漸變顏色的角度(目前只支持設置45的倍數角度: 0, 45, 90, 135, 180, -45, -90, -135)
    @IBInspectable public var angle: Int = 0 {
        didSet { updateUI() }
    }

    //渲染的顏色, start center end 皆是方便快速設定, 最後組成陣列會是 [start, center, end]
    @IBInspectable public var startColor: UIColor = UIColor.black {
        didSet { updateUI() }
    }
    @IBInspectable public var centerColor: UIColor? {
        didSet { updateUI() }
    }
    @IBInspectable public var endColor: UIColor = UIColor.black {
        didSet { updateUI() }
    }

    //渲染的顏色陣列, 當此值為nil時使用 start, center ,end
    public var shapeColors: [UIColor]? {
        didSet { updateUI() }
    }

    //填滿的圖片, 若設定圖片, 則上方 填滿顏色 及 漸變方向 失效
    @IBInspectable public var contentImage: UIImage? {
        didSet { updateUI() }
    }

    //stroke的寬度
    @IBInspectable public var strokeWidth: CGFloat = 1 {
        didSet { updateUI() }
    }

    //依照其餘屬性所得到的外筐 Rect
    private var strokeRect: CGRect {
        get {
            return CGRect(x: self.bounds.minX + strokeWidth/2,
                          y: self.bounds.minY + strokeWidth/2,
                          width: self.bounds.width - strokeWidth,
                          height: self.bounds.height - strokeWidth)
        }
    }

    //最終繪製(layer加入邊邊, 漸層渲染, 圖案)時需要的path
    private var strokePath: UIBezierPath = UIBezierPath()
    private var maskPath: UIBezierPath = UIBezierPath()

    private var strokeLayer: CAShapeLayer!
    private var maskLayer: CAShapeLayer!
    private var fillLayer: CAGradientLayer!

    override public var bounds: CGRect {
        didSet { updateUI() }
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }


    override public func setupView() {
        creatUI()
    }

    private func creatUI() {

        fillLayer = CAGradientLayer()
        layer.addSublayer(fillLayer)

        maskLayer = CAShapeLayer()
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.strokeColor = UIColor.clear.cgColor

        strokeLayer = CAShapeLayer()
        //设置填充色
        strokeLayer.fillColor = UIColor.clear.cgColor
        //添加到layer
        layer.addSublayer(strokeLayer)


        updateUI()
    }

    //更新ui顯示, 順序為先設定好path之後進行顯示
    private func updateUI() {
        //依照不同類型而有不同設置
        switch roundType {
        case .rect:      settingRectPath()
        case .circle:    settingCirclePath()
        case .traingle:  settingTrianglePath()
        }
        display()
    }

    //方形顯示
    private func settingRectPath() {
        var rounds: UIRectCorner = []
        //繪製需要圓角的邊
        if topLeft     { rounds.insert(.topLeft)     }
        if topRight    { rounds.insert(.topRight)    }
        if bottomLeft  { rounds.insert(.bottomLeft)  }
        if bottomRight { rounds.insert(.bottomRight) }

        let radiusSize = CGSize(width: radius, height: radius)
        strokePath = UIBezierPath.init(roundedRect: strokeRect, byRoundingCorners: rounds, cornerRadii: radiusSize)
        maskPath = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: rounds, cornerRadii: radiusSize)
        strokePath.lineWidth = strokeWidth
        maskPath.lineWidth = strokeWidth
    }

    //圓形顯示
    private func settingCirclePath() {
        strokePath = UIBezierPath.init(ovalIn: strokeRect)
        maskPath = UIBezierPath.init(ovalIn: self.bounds)
        strokePath.lineWidth = strokeWidth
        maskPath.lineWidth = strokeWidth
    }

    //三角形顯示
    private func settingTrianglePath() {
        //得到畫三角形各個方向的8個點
        let topLeft     : CGPoint = CGPoint(x: bounds.minX, y: bounds.minY) //1
        let topCenter   : CGPoint = CGPoint(x: bounds.midX, y: bounds.minY) //2
        let topRight    : CGPoint = CGPoint(x: bounds.maxX, y: bounds.minY) //3

        let centerLeft  : CGPoint = CGPoint(x: bounds.minX, y: bounds.midY) //4
        let center      : CGPoint = CGPoint(x: bounds.midX, y: bounds.midY) //5
        let centerRight : CGPoint = CGPoint(x: bounds.maxX, y: bounds.midY) //6

        let bottomLeft  : CGPoint = CGPoint(x: bounds.minX, y: bounds.maxY) //7
        let bottomCenter: CGPoint = CGPoint(x: bounds.midX, y: bounds.maxY) //8
        let bottomRight : CGPoint = CGPoint(x: bounds.maxX, y: bounds.maxY) //9

        //將字串分割成三個點
        let anchorPoints: [CGPoint] = pointString.components(separatedBy: ",").map( {
            let i = Int($0)!
            switch i {
            case 1: return topLeft
            case 2: return topCenter
            case 3: return topRight
            case 4: return centerLeft
            case 5: return center
            case 6: return centerRight
            case 7: return bottomLeft
            case 8: return bottomCenter
            case 9: return bottomRight
            default: return topLeft
            }
        } )

        strokePath = UIBezierPath()
        strokePath.move(to: anchorPoints[0])
        for i in 1..<anchorPoints.count {
            strokePath.addLine(to: anchorPoints[i])
        }

        strokePath.close()
        strokePath.lineWidth = 1

        maskPath = strokePath
    }


    //設定好path之後, 呼叫此方法進行顯示
    private func display() {
        //判斷 填充顏色 或 填滿圖片
        if let img = contentImage {
            fillLayer.frame = maskPath.bounds
            fillLayer.contents = img.cgImage
            fillLayer.colors = [UIColor.clear]

        } else {
            fillLayer.frame = maskPath.bounds

            if let colors = shapeColors {
                fillLayer.colors = colors.map { $0.cgColor }
            } else if let center = centerColor {
                fillLayer.colors = [startColor.cgColor, center.cgColor, endColor.cgColor]
            } else {
                fillLayer.colors = [startColor.cgColor, endColor.cgColor]
            }

            let startPoint: CGPoint
            switch angle {
            case 0:     startPoint = CGPoint(x: 0, y: 0.5)
            case 45:    startPoint = CGPoint(x: 0, y: 1)
            case 90:    startPoint = CGPoint(x: 0.5, y: 1)
            case 135:   startPoint = CGPoint(x: 0, y: 0.5)
            case 180:   startPoint = CGPoint(x: 1, y: 0.5)
            case -45:   startPoint = CGPoint(x: 0, y: 0)
            case -90:   startPoint = CGPoint(x: 0.5, y: 0)
            case -135:  startPoint = CGPoint(x: 0, y: 0.5)
            default:    startPoint = CGPoint(x: 0, y: 0)
            }

            fillLayer.startPoint = startPoint
            fillLayer.endPoint = CGPoint(x: 1-startPoint.x, y: 1-startPoint.y)
        }


        //接著畫線
        strokeLayer.strokeColor = strokeColor.cgColor
        strokeLayer.path = strokePath.cgPath
        strokeLayer.lineWidth = strokeWidth

        if strokeDash {
            strokeLayer.lineDashPhase = 0
            strokeLayer.lineDashPattern = [NSNumber.init(value: dashLength), NSNumber.init(value: dashSpace)]
        }

        maskLayer.path = maskPath.cgPath
        fillLayer.mask = maskLayer
    }


    //當所有顏色皆為透明無色時, 就不需要渲染
    private func isNeedShapeColor() -> Bool {
        if let fillArray = shapeColors {
            for clr in fillArray where clr != UIColor.clear {
                return true
            }
            return false
        } else if let center = centerColor {
            return startColor != UIColor.clear || center != UIColor.clear || endColor != UIColor.clear
        } else {
            return startColor != UIColor.clear || endColor != UIColor.clear
        }
    }


}
