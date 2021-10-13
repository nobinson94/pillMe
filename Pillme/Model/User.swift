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
    
    var name: String { UserInfo.name.value as? String ?? "" }
    var age: Int? { UserInfo.age.value as? Int }
    
    var wakeUpTime: String { UserInfo.wakeUpTime.value as? String ?? "07:00" }
    var breakfastTime: String { UserInfo.breakfastTime.value as? String ?? "08:30" }
    var lunchTime: String { UserInfo.lunchTime.value as? String ?? "12:30" }
    var dinnerTime: String { UserInfo.dinnerTime.value as? String ?? "19:00" }
    var sleepTime: String { UserInfo.sleepTime.value as? String ?? "23:00" }
    
    var currentTime: TakeTime {
        let current = Date()

        switch current.timeIndex {
        case midTimeIndex(sleepTime.timeIndex, wakeUpTime.timeIndex)..<wakeUpTime.timeIndex:
            return .afterWakeup
        case wakeUpTime.timeIndex..<breakfastTime.timeIndex:
            if (breakfastTime.timeIndex - current.timeIndex) > (current.timeIndex-wakeUpTime.timeIndex) {
                return .beforeBreakfast
            } else {
                return .afterWakeup
            }
        case breakfastTime.timeIndex..<lunchTime.timeIndex:
            let oneThird = oneThirdTimeIndex(breakfastTime.timeIndex, lunchTime.timeIndex)
            if current.timeIndex < oneThird {
                return .afterBreakfast
            } else if current.timeIndex < 2*oneThird {
                return .betweenBreakfastLunch
            } else {
                return .beforeLunch
            }
        case lunchTime.timeIndex..<dinnerTime.timeIndex:
            let oneThird = oneThirdTimeIndex(lunchTime.timeIndex, dinnerTime.timeIndex)
            if current.timeIndex < oneThird {
                return .afterLunch
            } else if current.timeIndex < 2*oneThird {
                return .betweenLunchDinner
            } else {
                return .beforeDinner
            }
        case dinnerTime.timeIndex..<sleepTime.timeIndex:
            if (sleepTime.timeIndex - current.timeIndex) > (current.timeIndex-dinnerTime.timeIndex) {
                return .afterDinner
            } else {
                return .beforeSleep
            }
        default:
            return .beforeSleep
        }
    }
    
    private func midTimeIndex(_ firstTimeIndex: Int, _ secondTimeIndex: Int) -> Int {
        var sum = (firstTimeIndex + secondTimeIndex)
        if sum > 1440 {
            sum -= 1440 // 60*24
        }
        
        return sum / 2
    }
    
    private func oneThirdTimeIndex(_ firstTimeIndex: Int, _ secondTimeIndex: Int) -> Int {
        var sum = (firstTimeIndex + secondTimeIndex)
        if sum > 1440 {
            sum -= 1440 // 60*24
        }
        
        return sum / 3
    }
    
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
}
