//
//  MGBaseHeaderFooterTabelCell.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/3/2.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

open class MGBaseHeaderFooterTableCell: MGBaseTableCell {

    public var label: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.clipsToBounds = true
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.clipsToBounds = true
    }


    open override func didMoveToSuperview() {
        //加入基本顯示的 text label
        self.clipsToBounds = true
        if label == nil { label = UILabel() }
        settingLabel()
    }

    //加入基本顯示的 text label
    private func settingLabel() {
        label.textAlignment = .center
        label.font = label.font.withSize(13)
        addSubview(label)

        //設置此變數, 在加入約束後才會自動更新frame
        label.translatesAutoresizingMaskIntoConstraints = false

        //置中約束
        //更好的寫法
        label.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
//        label.topAnchor.constraint(equalTo: self.topAnchor, constant: 16).isActive = true
//        label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 16).isActive = true

        label.sizeToFit()
        //普通的寫法
        //            let centerXConstraint = NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.centerX,
        //                                                            relatedBy: NSLayoutRelation.equal,
        //                                                            toItem: self, attribute: NSLayoutAttribute.centerX,
        //                                                            multiplier: 1, constant: 0)
        //
        //            let centerYConstraint = NSLayoutConstraint.init(item: label, attribute: NSLayoutAttribute.centerY,
        //                                                            relatedBy: NSLayoutRelation.equal,
        //                                                            toItem: self, attribute: NSLayoutAttribute.centerY,
        //                                                            multiplier: 1, constant: 0)
        //
        //            NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
    }
}
