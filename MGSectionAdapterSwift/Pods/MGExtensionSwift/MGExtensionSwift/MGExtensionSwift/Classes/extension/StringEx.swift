//
//  StringEx.swift
//  MGBaseProject
//
//  Created by Magical Water on 2018/3/1.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation
import UIKit

public extension String {

    //將解析html字串到屬性字串
    public var htmlParse: NSAttributedString {
        guard let data = self.data(using: String.Encoding.utf8, allowLossyConversion: true) else { return NSAttributedString() }

        let result = try? NSAttributedString(data: data,
                                             options:[NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
                                                      NSAttributedString.DocumentReadingOptionKey.characterEncoding: NSNumber.init(value: String.Encoding.utf8.rawValue)],
                                             documentAttributes: nil)
        return result ?? NSAttributedString()
    }

    public subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }

//    subscript (i: Int) -> String {
//        return String(self[i] as Character)
//    }

    //搜索子字串出現的位置
    public func index(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }

    //搜索子字串結束的位置
    public func endIndex(of string: String, options: CompareOptions = .literal) -> Index? {
        return range(of: string, options: options)?.upperBound
    }

    //搜索子字串所有出現的位置
    public func indexes(of string: String, options: CompareOptions = .literal) -> [Index] {
        var result: [Index] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range.lowerBound)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }

    //搜索子字串出現的範圍
    public func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }


    //將index轉換成int
    public func coverToInt(_ index: String.Index) -> Int {
        return distance(from: startIndex, to: index)
    }

    public func coverToIndex(_ pos: Int) -> String.Index {
        return index(startIndex, offsetBy: pos)
    }

    public func subString(_ start: Int, length: Int) -> String {
        let sIndex = index(startIndex, offsetBy: start)
        let eIndex = index(startIndex, offsetBy: start + length)
        return String(self[sIndex..<eIndex])
    }

    public func subString(_ start: Int) -> String {
        let sIndex = index(startIndex, offsetBy: start)
        return String(self[sIndex...])
    }


    public mutating func insert(_ str: String, at: Int) {
        let insertPos = coverToIndex(at)
        let strCount: Int = str.count
        for i in (0..<strCount).reversed() {
            let char = str[i]
            insert(char, at: insertPos)
        }
    }

    //字串寬度
    public func width(_ font: UIFont?) -> CGFloat {
        return size(font).width
    }

    //字串高度
    public func height(_ font: UIFont?) -> CGFloat {
        return size(font).height
    }

    //字串size
    public func size(_ font: UIFont?) -> CGSize {
        let attributes = font != nil ? [NSAttributedString.Key.font: font!] : [:]
        let size = self.size(withAttributes: attributes)
        return size
    }

    //字串高度(有限制寬度)
    public func height(_ font: UIFont?, withWidth: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: withWidth, height: .greatestFiniteMagnitude)
        let attributes = font != nil ? [NSAttributedString.Key.font: font!] : [:]
        let boundingBox = self.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
        return boundingBox.height
    }

}
