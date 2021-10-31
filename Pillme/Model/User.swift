//
//  User.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import Foundation

enum UserInfo: String {
    case name
    case age
    case wakeUpTime
    case breakfastTime
    case lunchTime
    case dinnerTime
    case sleepTime
    
    var title: String {
        switch self {
        case .name: return "이름"
        case .age: return "나이"
        case .wakeUpTime: return "기상 시각"
        case .breakfastTime: return "아침식사 시각"
        case .lunchTime: return "점심식사 시각"
        case .dinnerTime: return "저녁식사 시각"
        case .sleepTime: return "취침 시각"
        }
    }
    
    var value: Any? {
        let userDefault = UserDefaults.standard
        let key = self.rawValue
        
        if self == .age {
            return userDefault.integer(forKey: key)
        } else {
            return userDefault.string(forKey: key)
        }
    }
}

class UserInfoManager {
    static var shared: UserInfoManager = UserInfoManager()
    
    private let minute: Int = 60
    
    var name: String { UserInfo.name.value as? String ?? "" }
    var age: Int? { UserInfo.age.value as? Int }
    
    var wakeUpTime: String { UserInfo.wakeUpTime.value as? String ?? "07:00" }
    var breakfastTime: String { UserInfo.breakfastTime.value as? String ?? "08:30" }
    var lunchTime: String { UserInfo.lunchTime.value as? String ?? "12:30" }
    var dinnerTime: String { UserInfo.dinnerTime.value as? String ?? "19:00" }
    var sleepTime: String { UserInfo.sleepTime.value as? String ?? "23:00" }
    
    func save(name: String, age: Int, wakeUpTime: String, breakfastTime: String, lunchTime: String, dinnerTime: String, sleepTime: String) {
        let userDefault = UserDefaults.standard
        userDefault.set(name, forKey: UserInfo.name.rawValue)
        userDefault.set(age, forKey: UserInfo.age.rawValue)
        userDefault.set(wakeUpTime, forKey: UserInfo.wakeUpTime.rawValue)
        userDefault.set(breakfastTime, forKey: UserInfo.breakfastTime.rawValue)
        userDefault.set(lunchTime, forKey: UserInfo.lunchTime.rawValue)
        userDefault.set(dinnerTime, forKey: UserInfo.dinnerTime.rawValue)
        userDefault.set(sleepTime, forKey: UserInfo.sleepTime.rawValue)
    }
}

private extension String {
    var timeIndex: Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        guard let date = formatter.date(from: self) else { return 0 }
        return date.timeIndex
    }
}

private extension Date {
    var timeIndex: Int {
        return self.hour*60 + self.minute
    }
    
    func add(minute: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minute, to: self) ?? self.addingTimeInterval(TimeInterval(60*minute))
    }
}
