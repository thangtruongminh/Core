//
// File.swift
// 
 
// Create by Thang Truong ON 19/07/2021.
// Copyright (c) 2021 ___ORGANIZAATIONNAME___. All rights reserved
//


import Foundation
extension Dictionary where Key == String {
    func toJsonString() throws -> String {
        let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        return String(data: jsonData, encoding: String.Encoding.utf8) ?? ""
    }
}
