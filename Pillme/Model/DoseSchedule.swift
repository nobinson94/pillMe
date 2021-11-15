//
//  DoseSchedule.swift
//  Pillme
//
//  Created by USER on 2021/11/15.
//

import Foundation

class DoseSchedule {
    var id: String { "\(pill.id)_takeOn\(takeTime)_\(date.dateString)"}
    var pill: Pill
    var date: Date
    var takeTime: TakeTime
    var isTaken: Bool = false
    
    init(pill: Pill, date: Date, takeTime: TakeTime) {
        self.pill = pill
        self.date = date
        self.takeTime = takeTime
        self.isTaken = PillMeDataManager.shared.isTaken(pillID: pill.id, takeTime: takeTime, date: date)
    }
    
    func updateTakeStatus() {
        if isTaken {
            PillMeDataManager.shared.untakePill(for: pill.id, time: takeTime, date: Date()) {
                self.isTaken = false
            }
        } else {
            PillMeDataManager.shared.takePill(for: pill.id, time: takeTime, date: Date()) {
                self.isTaken = true
            }
        }
    }
    
}

extension DoseSchedule: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }

    static func == (lhs: DoseSchedule, rhs: DoseSchedule) -> Bool {
        return lhs.id == rhs.id
    }
}
