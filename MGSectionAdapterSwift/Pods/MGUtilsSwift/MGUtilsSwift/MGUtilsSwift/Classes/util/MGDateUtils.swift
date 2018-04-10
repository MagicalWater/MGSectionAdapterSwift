//
//  MGDataUtils.swift
//  mgbaseproject
//
//  Created by Magical Water on 2018/2/18.
//  Copyright © 2018年 Magical Water. All rights reserved.
//

import Foundation

public class MGDateUtils {

    //格式化日期
    public static func format(d: Date, format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: d)
    }

    //格式化日期
    public static func format(time: TimeInterval, format: String) -> String {
        let d = Date(timeIntervalSince1970: time)
        return MGDateUtils.format(d: d, format: format)
    }

    public static func convertToDate(_ dateText: String, pattern: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = pattern
        guard let date = dateFormatter.date(from: dateText) else {
            print("錯誤: 無法將日期字串轉化為Date: text = \(dateText), pattern = \(pattern)")
            return nil
        }
        return date
    }

    // use date constant here


    //給出二個date, 得到兩個 Date 之間的差距天數, 一律回傳正數
    public static func getDateDistance(first: Date, second: Date) -> Int {
        let distance = second.timeIntervalSince(first)
        let day = distance / (24*60*60)
        return abs(Int(day))
    }

    //給出二個date, 得到兩個 Date 是否超過給定的距離
    //max 的結構必須由大到小 年 -> 月 -> 日...
    public static func isDateOutter(_ first: Date, second: Date, attr: MGDateAttr...) -> Bool {
        let fDate = getDate(first, attrs: attr)
        //判斷 second 是否大於 lDate, 如果大於代表超過
        return second.timeIntervalSince1970 - fDate.timeIntervalSince1970 > 0
    }


    /*
     得到指定 date 指定周幾的 date(最大的日期為指定date, 所以當指定週數的date大於 指定 date的話, 則往前推一個星期)
     weekDay 的對應
     1 -> 星期日
     2 -> 星期一
     ...
     7 -> 星期六
     */
    public static func getWeekFirstTime(_ max: Date, week: Int) -> Date {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var components = gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: max)
        //得到今天是星期幾
        let weekDay = components.weekday!
        //開始設定attr
        var attr = MGDateAttr.init(.day, value: nil, offset: nil)
        //獲取week的date
        if weekDay >= week {
            //當weekDay大於指定week時, 只需將date往前推 weekDay 和 week 的差距即可
            attr.offset = week - weekDay
        } else {
            //當weekDay小於指定week時, 則需要將 weekDay + 7 在與week比較差距
            attr.offset = week - (weekDay + 7)
        }
        return getDateFirstByAttr(max, attrs: attr)
    }

    public static func getWeekLastTime(_ max: Date, week: Int) -> Date {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var components = gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second, .weekday], from: max)
        //得到今天是星期幾
        let weekDay = components.weekday!
        //開始設定attr
        var attr = MGDateAttr.init(.day, value: nil, offset: nil)
        //獲取week的date
        if weekDay >= week {
            //當weekDay大於指定week時, 只需將date往前推 weekDay 和 week 的差距即可
            attr.offset = week - weekDay
        } else {
            //當weekDay小於指定week時, 則需要將 weekDay + 7 在與week比較差距
            attr.offset = week - (weekDay + 7)
        }
        return getDateLastByAttr(max, attrs: attr)
    }


    //比較兩個日期是否為同天
    public static func inSameDay(_ first: Date, second: Date) -> Bool {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let comp1 = gregorianCalendar.dateComponents([.year,.month,.day], from: first)
        let comp2 = gregorianCalendar.dateComponents([.year,.month,.day], from: second)

        //開始比較
        return comp1.year == comp2.year && comp1.month == comp2.month && comp1.day == comp2.day
    }

    //給出一個date, 得到它往前或往後推的date
    public static func getDate(_ d: Date, attrs: MGDateAttr...) -> Date {
        return getDate(d, attrs: attrs)
    }

    //給出一個date, 得到它往前或往後推的date
    public static func getDate(_ d: Date, attrs: [MGDateAttr]) -> Date {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var components = gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: d)
        settingDateInAttr(&components, attrs: attrs)
        return gregorianCalendar.date(from: components)!
    }


    public static func getDateFirstTime(_ d: Date) -> Date {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var components = gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: d)
        settingInFirstTime(&components)
        return gregorianCalendar.date(from: components)!
    }

    public static func getDateLastTime(_ d: Date) -> Date {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var components = gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: d)
        settingInLastTime(&components)
        return gregorianCalendar.date(from: components)!
    }

    public static func getDateFirstByAttr(_ d: Date, attrs: MGDateAttr...) -> Date {
        return getDateFirstByAttr(d, attrs: attrs)
    }

    public static func getDateFirstByAttr(_ d: Date, attrs: [MGDateAttr]) -> Date {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var components = gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: d)
        settingDateInAttr(&components, attrs: attrs)
        settingInFirstTime(&components)
        return gregorianCalendar.date(from: components)!
    }

    public static func getDateLastByAttr(_ d: Date, attrs: MGDateAttr...) -> Date {
        return getDateLastByAttr(d, attrs: attrs)
    }

    public static func getDateLastByAttr(_ d: Date, attrs: [MGDateAttr]) -> Date {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var components = gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: d)
        settingDateInAttr(&components, attrs: attrs)
        settingInLastTime(&components)
        return gregorianCalendar.date(from: components)!
    }


    private static func settingDateInAttr(_ components: inout DateComponents, attrs: [MGDateAttr]) {

        for i in 0..<attrs.count {
            let type = attrs[i].type
            let value = attrs[i].value
            let offset = attrs[i].offset

            if let v = value {
                switch type {
                case .year:     components.year! = v
                case .month:    components.month! = v
                case .day:      components.day! = v
                case .hour:     components.hour! = v
                case .minute:   components.minute! = v
                case .second:   components.second! = v
                }
            }

            if let o = offset {
                switch type {
                case .year:     components.year! += o
                case .month:    components.month! += o
                case .day:      components.day! += o
                case .hour:     components.hour! += o
                case .minute:   components.minute! += o
                case .second:   components.second! += o
                }
            }
        }
    }


    private static func settingInFirstTime(_ components: inout DateComponents) {
        components.hour   = 0
        components.minute = 0
        components.second = 0
    }


    private static func settingInLastTime(_ components: inout DateComponents) {
        components.hour   = 23
        components.minute = 59
        components.second = 59
    }


    //計算當月天數
    public static func getDayCount(_ inMonth: Date) -> Int {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        var components = gregorianCalendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: inMonth)
        let year =  components.year!
        let month = components.month!

        var startComps = DateComponents()
        startComps.day = 1
        startComps.month = month
        startComps.year = year

        var endComps = DateComponents()
        endComps.day = 1
        endComps.month = month == 12 ? 1 : month + 1
        endComps.year = month == 12 ? year + 1 : year

        let startDate = gregorianCalendar.date(from: startComps)!
        let endDate = gregorianCalendar.date(from: endComps)!

        let diff = gregorianCalendar.dateComponents([.day], from: startDate, to: endDate)
        return diff.day!
    }

    public struct MGDateAttr {
        public var type: MGDateType //類型
        public var value: Int? //直接設置值
        public var offset: Int? //偏移值

        public init(_ type: MGDateType, value: Int? = nil, offset: Int? = nil) {
            self.type = type
            self.value = value
            self.offset = offset
        }

    }


    //時間類型
    public enum MGDateType {
        case year
        case month
        case day
        case hour
        case minute
        case second
    }
}


