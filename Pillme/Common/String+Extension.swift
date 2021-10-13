//
//  String+Extension.swift
//  Pillme
//
//  Created by USER on 2021/09/25.
//

import Foundation

extension String {
    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: self) ?? Date()
    }
    
    var time: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: self) ?? Date()
    }
}
