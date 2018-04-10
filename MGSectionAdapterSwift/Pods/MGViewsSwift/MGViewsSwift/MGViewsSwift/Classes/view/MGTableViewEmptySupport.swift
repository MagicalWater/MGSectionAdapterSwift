//
//  MGTableViewEmptySupport.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/19.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import UIKit

//可以在資料數量為0時顯示資料為空提示文字
public class MGTableViewEmptySupport: UITableView {

    @IBInspectable var textSize: CGFloat = 20 {
        didSet {
            if let label = emptyLabel { label.font = label.font.withSize(textSize) }
        }
    }

    @IBInspectable var textColor: UIColor = UIColor.white {
        didSet {
            if let label = emptyLabel { label.textColor = textColor }
        }
    }

    public var emptyLabel: UILabel!

    public override func didMoveToSuperview() {
        if emptyLabel == nil {
            createEmptyLabel(superview!)
        }
    }

    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func createEmptyLabel(_ inView: UIView) {
        emptyLabel = UILabel(frame: self.bounds)
        inView.addSubview(emptyLabel)
        emptyLabel.font = emptyLabel?.font.withSize(textSize)
        emptyLabel.textColor = textColor
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        emptyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }

    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing(true)
    }

}

