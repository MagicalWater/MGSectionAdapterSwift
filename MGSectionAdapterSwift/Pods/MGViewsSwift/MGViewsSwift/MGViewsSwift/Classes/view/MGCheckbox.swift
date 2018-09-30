//
//  MGCheckbox.swift
//  AuthorizedStore
//
//  Created by Magical Water on 2018/2/27.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit

public typealias CheckboxValueChangedBlock = (_ checkBox: MGCheckbox, _ isOn: Bool) -> Void

@objc public enum MGCheckboxLine: Int {
    case Normal
    case Thin
}

@IBDesignable public class MGCheckbox: UIView {
    // MARK: - Properties

    /**
     Private property which indicates current state of checkbox
     Default value is false
     - See: isOn()
     */
    private var on: (value: Bool, callback: Bool) = (value: false, callback: true) {
        didSet {
            if on.callback { self.checkboxValueChangedBlock?(self, on.value) }
        }
    }

    /**
     Closure which called when property 'on' is changed
     */
    public var checkboxValueChangedBlock: CheckboxValueChangedBlock?

    // MARK: Customization

    /**
     Set background color of checkbox
     */
    @IBInspectable var bgColor: UIColor = UIColor.clear {
        didSet {
            if !self.isOn() {
                self.backgroundColor = bgColor
            }
        }
    }

    /**
     Set background color of checkbox in selected state
     */
    @IBInspectable var bgColorSelected = UIColor.clear {
        didSet {
            if self.isOn() {
                self.backgroundColor = bgColorSelected
            }
        }
    }

    /**
     Set checkmark color
     */
    @IBInspectable var color: UIColor = UIColor.blue {
        didSet {
            self.checkmark.color = color
        }
    }

    /**
     Set checkbox border width
     */
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    /**
     Set checkbox border color
     */
    @IBInspectable var borderColor: UIColor! {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    /**
     Set checkbox corner radius
     */
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }

    /**
     Set line type
     Default value is Normal
     - See: MGCheckboxLine enum
     */
    public var line = MGCheckboxLine.Normal

    // MARK: Private properties

    private var button    = UIButton()
    private var checkmark = MGCheckmarkView()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }

    private func setupView() {
        // Init base properties
        self.backgroundColor        = UIColor.clear
        self.cornerRadius           = 8
        self.borderWidth            = 3
        self.borderColor            = UIColor.darkGray
        self.color                  = UIColor(red: 46/255, green: 119/255, blue: 217/255, alpha: 1)

        // Setup checkmark
        self.checkmark.frame = self.bounds
        self.checkmark.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(self.checkmark)

        // Setup button
        self.button.frame = self.bounds
        self.button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.button.addTarget(self, action: #selector(MGCheckbox.buttonDidSelected), for: .touchUpInside)
        self.addSubview(self.button)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        self.button.bounds    = self.bounds
        self.checkmark.bounds = self.bounds
    }
}

// MARK: - Public
public extension MGCheckbox {
    /**
     Function allows you to set checkbox state
     - Parameter on Checkbox state
     */
    public func setOn(on: Bool) {
        self.setOn(on: on, animated: false)
    }

    public func setOn(on: Bool, callback: Bool) {
        self.setOn(on: on, animated: false, callback: callback)
    }

    /**
     Function allows you to set checkbox state with animation
     - Parameter on Checkbox state
     - Parameter animated Enable anomation
     */
    public func setOn(on: Bool, animated: Bool, callback: Bool = true) {
        if self.on.value == on {
            return
        }

        self.on = (value: on, callback: callback)
        self.showCheckmark(show: on, animated: animated)

        if animated {
            UIView.animate(withDuration: 0.275, animations: {
                self.backgroundColor = on ? self.bgColorSelected : self.bgColor
            })
        } else {
            self.backgroundColor = on ? self.bgColorSelected : self.bgColor
        }
    }

    /**
     Function allows to check current checkbox state
     - Returns: State as Bool value
     */
    public func isOn() -> Bool {
        return self.on.value
    }
}

// MARK: - Private
extension MGCheckbox {
    @objc func buttonDidSelected() {
        self.setOn(on: !self.on.value, animated: true)
    }

    func showCheckmark(show: Bool, animated: Bool) {
        if show == true {
            self.checkmark.strokeWidth = self.bounds.width / (self.line == .Normal ? 10 : 20)
            self.checkmark.show(animated: animated)
        } else {
            self.checkmark.hide(animated: animated)
        }
    }
}

//
//  MGCheckbox.swift
//  MGCheckmarkView
//
//  Created by Vladislav Kovalyov on 8/22/16.
//  Copyright © 2016 WOOPSS.com http://woopss.com/ All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
class MGCheckmarkView: UIView {
    var color: UIColor = UIColor.blue

    var animationDuration: TimeInterval = 0.275
    var strokeWidth: CGFloat = 0

    var checkmarkLayer: CAShapeLayer!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupCheckmark()
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupCheckmark()
    }

    private func setupCheckmark() {
        self.checkmarkLayer             = CAShapeLayer()
        self.checkmarkLayer.fillColor   = nil

        self.backgroundColor = UIColor.clear
    }
}

extension MGCheckmarkView {
    func show(animated: Bool) {
        self.alpha = 1

        self.checkmarkLayer.removeAllAnimations()

        let checkmarkPath = UIBezierPath()
        checkmarkPath.move(to: CGPoint(x: self.bounds.width * 0.28, y: self.bounds.height * 0.5))
        checkmarkPath.addLine(to: CGPoint(x: self.bounds.width * 0.42, y: self.bounds.height * 0.66))
        checkmarkPath.addLine(to: CGPoint(x: self.bounds.width * 0.72, y: self.bounds.height * 0.36))
        checkmarkPath.lineCapStyle  = .square
        self.checkmarkLayer.path    = checkmarkPath.cgPath

        self.checkmarkLayer.strokeColor = self.color.cgColor
        self.checkmarkLayer.lineWidth   = self.strokeWidth
        self.layer.addSublayer(self.checkmarkLayer)

        if animated == false {
            checkmarkLayer.strokeEnd = 1
        } else {
            let checkmarkAnimation: CABasicAnimation = CABasicAnimation(keyPath:"strokeEnd")
            checkmarkAnimation.duration = animationDuration
            checkmarkAnimation.isRemovedOnCompletion = false
            checkmarkAnimation.fillMode = CAMediaTimingFillMode.both
            checkmarkAnimation.fromValue = 0
            checkmarkAnimation.toValue = 1
            checkmarkAnimation.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeIn)
            self.checkmarkLayer.add(checkmarkAnimation, forKey:"strokeEnd")
        }
    }

    func hide(animated: Bool) {
        var duration = self.animationDuration

        if animated == false {
            duration = 0
        }

        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }) { (_) in
            self.checkmarkLayer.removeFromSuperlayer()
        }
    }
}

