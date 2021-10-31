//
//  DoseRecord.swift
//  Pillme
//
//  Created by USER on 2021/10/16.
//

import Foundation

class DoseRecord {
    var date: Date
    var pill: Pill
    var takeTime: TakeTime?
    
    init(pill: Pill, takeTime: TakeTime, date: Date = Date()) {
        self.pill = pill
        self.takeTime = takeTime
        self.date = Calendar.current.startOfDay(for: date)
    }
    
    init(cdDoseRecord: CDDoseRecord) {
        self.date = cdDoseRecord.date
        self.takeTime = TakeTime(rawValue: Int(cdDoseRecord.takeTime))
        self.pill = Pill(cdPill: cdDoseRecord.pill)
    }
}
