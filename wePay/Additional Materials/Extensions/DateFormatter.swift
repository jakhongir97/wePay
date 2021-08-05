//
//  DateFormatter.swift
//  wePay
//
//  Created by Admin NBU on 05/08/21.
//

import Foundation

extension DateFormatter {
    
    static let dateOnly: DateFormatter = {
         let formatter = DateFormatter()
         formatter.dateFormat = "dd.MM.yy"
         return formatter
    }()

    static func string(timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        return  DateFormatter.dateOnly.string(from: date)
    }
}
