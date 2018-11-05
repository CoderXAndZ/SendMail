//
//  Date+Extension.swift
//  API Example
//
//  Created by mac on 2018/11/1.
//  Copyright © 2018年 cho. All rights reserved.
//

import Foundation

/// dateFormatter
private let dateFormatter = DateFormatter()
/// 当前日历对象
private let calendar = Calendar.current

extension Date {
    
    /// 当前时间的string形式
    func nowDateString(formatter: String) -> String {
        let date = Date()
        dateFormatter.dateFormat = formatter
        //        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        //        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let now = dateFormatter.string(from: date)
        return now
    }
    
    /// 当前时间的时间戳
    func nowTimeinterval() -> Int {
        let now = Date()
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let timeStamp = Int(timeInterval)
        return timeStamp
    }
    
    /// 时间戳转化成date formatter: String,
    func stringToDate(timeInterval: Double) -> Date {
//        dateFormatter.dateFormat = formatter
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .short
        //        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        //        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return Date.init(timeIntervalSince1970: timeInterval)
    }
    
    /// 判断是否是今天
    func isToday(date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
}
