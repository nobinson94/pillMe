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
    var id: String = UUID().uuidString
    var name: String = ""
    var type: PillType = .medicine
    var startDate: Date = Date()
    var endDate: Date?
    var cycle: Int = 0
    var doseDays: [WeekDay] = []
    var doseMethods: [DoseMethod] = []
    
    init(name: String,
         type: PillType = .medicine,
         startDate: Date = Date(),
         endDate: Date? = nil,
         cycle: Int = 0,
         doseDays: [WeekDay] = [],
         doseMethods: [DoseMethod] = []) {
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
