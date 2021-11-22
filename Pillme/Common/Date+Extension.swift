//
//  Date+Pillme.swift
//  Pillme
//
//  Created by USER on 2021/11/22.
//

import Foundation

extension Date {
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    var weekDay: WeekDay {
        let weekDayIndex = Calendar.current.component(.weekday, from: self)
        return WeekDay(rawValue: weekDayIndex) ?? .mon
    }
    
    var isLeapYear: Bool {
        self.year % 4 == 0 && self.year % 100 != 0
    }
    
    var dateCountOfMonth: Int {
        switch month {
        case 2:
            if isLeapYear {
                return 29
            } else {
                return 28
            }
        case 1, 3, 5, 7, 8, 10, 12: return 31
        default: return 30
        }
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        if self.year == Date().year {
            formatter.dateFormat = "M월 dd일"
        } else {
            formatter.dateFormat = "yyyy년 M월 dd일"
        }
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = Locale.current
        
        if Calendar.current.isDateInToday(self) {
            return "오늘 (\(formatter.string(from: self)))"
        }
        
        return formatter.string(from: self)
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.timeZone = TimeZone.autoupdatingCurrent
        formatter.locale = Locale.current
        
        return formatter.string(from: self)
    }
    
    func compareOnlyTime(_ other: Date) -> ComparisonResult {
        guard self.hour != other.hour else {
            if self.minute == other.minute {
                return .orderedSame
            } else if self.minute < other.minute {
                return .orderedAscending
            } else {
                return .orderedDescending
            }
        }
        
        if self.hour < other.hour {
            return .orderedAscending
        } else {
            return .orderedDescending
        }
    }
    
    var tommorrow: Date {
        self.addingTimeInterval(86400)
    }
    
    var yesterday: Date {
        self.addingTimeInterval(-86400)
    }
    
    var hourMinuteIndex: Int {
        return self.hour*60 + self.minute
    }
}
