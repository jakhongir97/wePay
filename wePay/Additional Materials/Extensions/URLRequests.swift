//
//  URLRequests.swift
//  Turon Telecom
//
//  Created by Jakhongir Nematov on 22/12/20.
//

import Foundation

extension URLRequest {
    // MARK: - JSON
    mutating func setJSONParameters(_ parameters: [String: Any]?) {
        guard let parameters = parameters else {
            httpBody = nil
            return
        }
        
        httpBody = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions(rawValue: 0))
    }
}
