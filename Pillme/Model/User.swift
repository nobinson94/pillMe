//
//  User.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import Foundation

struct User {
    var name: String
    var age: Int
    
    var wakeUpTime: String = "07:00"
    var breakfastTime: String = "08:30"
    var lunchTime: String = "12:30"
    var dinnerTime: String = "18:00"
    var sleepTime: String = "23:00"
}

extension User {
    static func createTest() -> User {
        return User(name: "Yongtae", age: 28)
    }
}

extension String {
    var time: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.date(from: self)
    }
}
