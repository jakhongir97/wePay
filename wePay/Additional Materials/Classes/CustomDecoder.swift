//
//  CustomDecoder.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 22/12/20.
//

import Foundation

final class CustomDecoder: JSONDecoder {
    override init() {
        super.init()
        keyDecodingStrategy = .convertFromSnakeCase
    }
}
