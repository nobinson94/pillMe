//
//  User.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import Foundation


class UserInfoManager {
    static var shared: UserInfoManager = UserInfoManager()
    
    var name: String = ""
    var age: Int = 0
    
    var wakeUpTime: String = "07:00"
    var breakfastTime: String = "08:30"
    var lunchTime: String = "12:30"
    var dinnerTime: String = "18:00"
    var sleepTime: String = "23:00"
    
    private init() {
        let userDefault = UserDefaults.standard
        self.name = userDefault.string(forKey: "userName") ?? ""
        self.age = userDefault.integer(forKey: "age")
        self.wakeUpTime = userDefault.string(forKey: "wakeUpTime") ?? "07:00"
        self.breakfastTime = userDefault.string(forKey: "breakfastTime") ?? "08:30"
        self.lunchTime = userDefault.string(forKey: "lunchTime") ?? "12:30"
        self.dinnerTime = userDefault.string(forKey: "dinnerTime") ?? "18:00"
        self.sleepTime = userDefault.string(forKey: "sleepTime") ?? "23:00"
    }
    
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
