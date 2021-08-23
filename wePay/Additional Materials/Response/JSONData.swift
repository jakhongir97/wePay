//
//  JSONData.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 22/12/20.
//

import Foundation

struct JSONData<T: Decodable>: Decodable {
    let code: Int
    let message: String
    let lang: String
    let isAuth: Bool

    let data: T
}
