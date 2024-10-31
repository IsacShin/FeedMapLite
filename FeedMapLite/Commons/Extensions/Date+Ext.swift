//
//  Date+Ext.swift
//  FeedMapLite
//
//  Created by 신이삭 on 10/30/24.
//

import Foundation

extension Date {
    func wddSimpleDateForm() -> String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return outputFormatter.string(from: self)
    }
}
