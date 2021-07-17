//
// File.swift
// 
 
// Create by Thang Truong ON 16/07/2021.
// Copyright (c) 2021 ___ORGANIZAATIONNAME___. All rights reserved
//


import XCTest
@testable import Core

final class DateConvertTests: XCTestCase {
    func testExample() {
        let str = "2021-07-16 14:53:50.032000+0700"
        let date = str.toDate()
        let dateString = date?.toString()
        XCTAssertEqual(str, dateString)
        
    }
}
