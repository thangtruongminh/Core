//
// File.swift
// 
 
// Create by Thang Truong ON 16/07/2021.
// Copyright (c) 2021 ___ORGANIZAATIONNAME___. All rights reserved
//


import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
