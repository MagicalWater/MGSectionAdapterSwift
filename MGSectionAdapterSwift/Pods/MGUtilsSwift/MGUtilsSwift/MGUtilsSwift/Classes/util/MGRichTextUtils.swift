//
//  MGAttrStringUtils.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/1/5.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

/*
 創建text的屬性字串
 除了在外部自行創建 RichAttr 最後呼叫comb之外, 也可進行鏈結呼叫的方式進行組裝
 */
public class MGRichTextUtils {

    public init() {}

    private var attrs: [RichAttr] = []

    private var defaultSize: CGFloat = 12

    //設置預設字體大小, 已設置的文字大小不會改變, 之後進行append的才會改變
    public func setDefaultTextSize(_ size: CGFloat) -> MGRichTextUtils {
        self.defaultSize = size
        return self
    }

    //呼叫此方法設置字串, 此方法會清空所有已設置數值
    public func setString(_ text: String) -> MGRichTextUtils {
        attrs.removeAll()
        return appendString(text)
    }

    //增加字串
    public func appendString(_ text: String) -> MGRichTextUtils {
        let attr = RichAttr.init(text, size: defaultSize)
        attrs.append(attr)
        return self
    }

    //設置當前最後一串文字的屬性
    public func setTextColor(_ color: UIColor) -> MGRichTextUtils {
        var attr = attrs.last!
        attr.color = color
        attrs[attrs.count-1] = attr
        return self
    }

    //設置當前最後一串文字的屬性
    public func setTextSize(_ size: CGFloat) -> MGRichTextUtils {
        var attr = attrs.last!
        attr.size = size
        attrs[attrs.count-1] = attr
        return self
    }

    //設置當前最後一串文字的屬性
    public func setTextBold(_ isBold: Bool) -> MGRichTextUtils {
        var attr = attrs.last!
        attr.isBold = isBold
        attrs[attrs.count-1] = attr
        return self
    }

    //設置當前最後一串文字的屬性
    public func setTextDelete(_ isDelete: Bool) -> MGRichTextUtils {
        var attr = attrs.last!
        attr.isDelete = isDelete
        attrs[attrs.count-1] = attr
        return self
    }

    //設置當前最後一串文字的屬性
    public func setTextAlignemtn(_ alignment: NSTextAlignment) -> MGRichTextUtils {
        var attr = attrs.last!
        attr.alignment = alignment
        attrs[attrs.count-1] = attr
        return self
    }

    public func build() -> NSMutableAttributedString {
        let string = MGRichTextUtils.comb(attrs)

        //build後清除所有設置的資料
        attrs.removeAll()

        return string
    }


    //多行時, 並且多個 nsattr
    public static func comb(_ texts: [NSMutableAttributedString], space: CGFloat) -> NSMutableAttributedString {

        let stAttr: NSMutableAttributedString = NSMutableAttributedString.init()
        let paraph = NSMutableParagraphStyle()
        paraph.lineSpacing = space

        var addNewLine = false

        for t in texts {

            if addNewLine {

                let attrArray = [
                    NSAttributedStringKey.paragraphStyle : paraph
                ]
                let nsAttr = NSAttributedString.init(string: "\n", attributes: attrArray)
                stAttr.append(nsAttr)

            } else {
                addNewLine = true
            }

            let range = (t.string as NSString).range(of: t.string)
            t.addAttribute(NSAttributedStringKey.paragraphStyle, value: paraph, range: range)
            stAttr.append(t)

        }

        return stAttr
    }


    //多個text組成一行, join 為每個attr之間加入的字串(通常用空格加入)
    public static func comb(_ attrs: [RichAttr]) -> NSMutableAttributedString {
        let stAttr: NSMutableAttributedString = NSMutableAttributedString()
        attrs.forEach {
            let attrString = getAttrString($0)
            stAttr.append(attrString)
        }
        return stAttr
    }


    //lineSpace是每一行的距離
    private static func getAttrString(_ attr: RichAttr) -> NSAttributedString {

        var attrArray = [
            NSAttributedStringKey.font : attr.isBold ? UIFont.boldSystemFont(ofSize: attr.size) : UIFont.systemFont(ofSize: attr.size),
            NSAttributedStringKey.foregroundColor : attr.color,
            NSAttributedStringKey.baselineOffset : NSNumber(value: 0) //設定基準線偏移
        ]

        let paraph = NSMutableParagraphStyle()
        paraph.alignment = attr.alignment

        if attr.isDelete {
            attrArray[NSAttributedStringKey.strikethroughStyle] = NSNumber.init(value: 1)
        }

        if let ls = attr.lineSpace { paraph.lineSpacing = ls }
        attrArray[NSAttributedStringKey.paragraphStyle] = paraph

        let nsAttr = NSAttributedString(string: attr.text, attributes: attrArray)
        return nsAttr
    }


    public struct RichAttr {
        public var text: String
        public var color: UIColor
        public var size: CGFloat
        public var isBold: Bool
        public var alignment: NSTextAlignment
        public var lineSpace: CGFloat?
        public var isDelete: Bool = false

        public init(_ text: String, color: UIColor = UIColor.black,
                    size: CGFloat, isBold: Bool = false,
                    alignment: NSTextAlignment = .left, lineSpace: CGFloat? = nil,
                    isDelete: Bool = false) {
            self.text = text
            self.color = color
            self.size = size
            self.isBold = isBold
            self.alignment = alignment
            self.lineSpace = lineSpace
            self.isDelete = isDelete
        }
    }

}

