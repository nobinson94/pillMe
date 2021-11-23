//
//  Pill.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import Combine
import Foundation

enum PillType: Int, CaseIterable, Identifiable {
    var id: Int { self.rawValue }
    
    case medicine
    case supplement
    
    var name: String {
        switch self {
        case .medicine: return "내복약"
        case .supplement: return "영양제"
        }
    }
}

class Pill {
    var id: String
    var name: String = ""
    var type: PillType = .medicine
    var startDate: Date = Date()
    var endDate: Date?
    var cycle: Int = 0
    var doseDays: [WeekDay] = []
    var doseMethods: [DoseMethod] = []
    
    init(id: String = UUID().uuidString,
         name: String,
         type: PillType = .medicine,
         startDate: Date = Date(),
         endDate: Date? = nil,
         cycle: Int = 0,
         doseDays: [WeekDay] = [],
         doseMethods: [DoseMethod] = []) {
        self.id = id
        self.name = name
        self.type = type
        self.startDate = startDate
        self.endDate = endDate
        self.cycle = cycle
        self.doseDays = doseDays
        self.doseMethods = doseMethods
    }
    
    init(cdPill: CDPill) {
        self.id = cdPill.id
        self.name = cdPill.name
        self.type = PillType(rawValue: Int(cdPill.type)) ?? .medicine
        self.startDate = cdPill.startDate
        self.endDate = cdPill.endDate
        self.cycle = Int(cdPill.cycle)
        self.doseDays = cdPill.doseDays.compactMap { WeekDay(rawValue: $0) }
        
        self.doseMethods = []
        if let cdDoseMethods = cdPill.doseMethods.array as? [CDDoseMethod] {
            cdDoseMethods.forEach {
                let doseMethod = DoseMethod(cdDoseMethod: $0)
                guard doseMethods.contains(doseMethod) == false else { return }
                self.doseMethods.append(doseMethod)
            }
        }
    }
    
    var nextTakeTime: TakeTime? {
        let nowComponents = Calendar.current.dateComponents([.hour, .minute], from: Date())
        
        return self.doseMethods.first(where: { method in
            nowComponents < method.time.components
        })?.time
    }
    
    func getNextTakeDate(of date: Date = Date()) -> Date {
        var nextDate = Date()
        let calendar = Calendar.current
        let maxDate = endDate ?? (calendar.date(byAdding: .day, value: 100, to: date) ?? Date())
        let components = DateComponents(hour: 0, minute: 0, second: 0)
        
        calendar.enumerateDates(startingAfter: date, matching: components, matchingPolicy: .nextTime) { date, exactMatch, stop in
            guard let date = date, date <= maxDate else {
                stop = true
                return
            }
            
            if doseDays.isEmpty, cycle > 0 {
                if calendar.numberOfDaysBetween(from: startDate, to: date)%cycle == 0 {
                    stop = true
                    nextDate = date
                }
            } else if doseDays.contains(date.weekDay) {
                nextDate = date
                stop = true
            }
        }
        
        return calendar.startOfDay(for: nextDate)
    }
    
    func getNextTakeTime(of takeTime: TakeTime) -> TakeTime? {
        if let nextTakeTime = self.doseMethods.first(where: { method in
            method.time.rawValue > takeTime.rawValue
        })?.time {
            return nextTakeTime
        } else if let firstTakeTime = doseMethods.first?.time {
            return firstTakeTime
        }
        return nil
    }
}

extension Pill: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }

    static func == (lhs: Pill, rhs: Pill) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Date {
    func isTakeDay(of pill: Pill) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: self)
        let startDate = Calendar.current.startOfDay(for: pill.startDate)
        guard startDate <= startOfDay else { return false }
        
        if let endDate = pill.endDate, Calendar.current.startOfDay(for: endDate) < startOfDay { return false }
        
        if pill.cycle == 1 {
            return true
        } else if pill.cycle > 1 {
            guard let distanceOfDay = Calendar.current.dateComponents([.day], from: startDate, to: startOfDay).day else { return false }
            return (distanceOfDay + 1)%pill.cycle == 0
        } else if !pill.doseDays.isEmpty {
            return pill.doseDays.contains(self.weekDay)
        }
        
        return false
    }
}

extension Calendar {
    func numberOfDaysBetween(from: Date, to: Date) -> Int {
        return dateComponents([.day], from: startOfDay(for: from), to: startOfDay(for: to)).day ?? 0
    }
}
