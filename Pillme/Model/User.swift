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
}

extension User {
    static func createTest() -> User {
        return User(name: "Yongtae", age: 28)
    }
}
