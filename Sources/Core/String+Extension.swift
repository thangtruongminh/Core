//
// File.swift
// 
 
// Create by Thang Truong ON 16/07/2021.
// Copyright (c) 2021 ___ORGANIZAATIONNAME___. All rights reserved
//


import Foundation

public extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    func writeToFile(path: String) {
        print(path)
        guard let data = self.data(using: String.Encoding.utf8) else {return}

        if FileManager.default.fileExists(atPath: path) == false {
            print(path, "is creating....")
            if FileManager.default.createFile(atPath: path, contents: nil, attributes: nil) {
                print(path, "is created")
            }
        }
        let fileHandle = FileHandle(forWritingAtPath: path)
        fileHandle?.seekToEndOfFile()
        fileHandle?.write(data)
        fileHandle?.closeFile()
        print(path, "is successfully saved")
    }
}
