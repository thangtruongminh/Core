//
//  JSONCodable.swift
//  SapoAdminIOS
//
//  Created by ThangTM-PC on 11/7/19.
//  Copyright © 2019 ThangTM-PC. All rights reserved.
//

import Foundation

extension JSONDecoder {
    public static var shared: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

extension JSONEncoder {
    public static var shared: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}


