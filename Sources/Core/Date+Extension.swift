//
// Date+Extension.swift
// 

// Create by Thang Truong ON 16/07/2021.
// Copyright (c) 2021 ___ORGANIZAATIONNAME___. All rights reserved
//


import Foundation

extension Date {
    
    func toString(format: String = "yyyy-MM-dd HH:mm:ss.SSSSSSZ") -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = NSLocale.system
        return dateFormatter.string(from: self)
    }
        
}

extension String {
    func toDate(format: String = "yyyy-MM-dd HH:mm:ss.SSSSSSZ") -> Date? {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        // #5531 24時間ファーマット対応 8/31 wangh start
        dateFormatter.locale = NSLocale.system
        // #5531 24時間ファーマット対応 8/31 wangh end
        return dateFormatter.date(from: self)
    }
}
