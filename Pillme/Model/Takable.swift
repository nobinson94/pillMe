//
//  Takable.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import Combine
import Foundation

enum TakableType: Int, CaseIterable, Identifiable {
    var id: Int { self.rawValue }
    
    case pill
    case supplement
    
    var name: String {
        switch self {
        case .pill: return "내복약"
        case .supplement: return "영양제"
        }
    }
}

class Takable {
    var id: String = UUID().uuidString
    var name: String = ""
    var type: TakableType = .pill
    var startDate: Date = Date()
    var endDate: Date?
    var cycle: Int = 0
    var doseDays: [WeekDay] = []
    var doseMethods: [DoseMethod] = []
    
    init(name: String,
         type: TakableType = .pill,
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
    
    init(cdTakable: CDTakable) {
        self.id = cdTakable.id
        self.name = cdTakable.name
        self.type = TakableType(rawValue: Int(cdTakable.type)) ?? .pill
        self.startDate = cdTakable.startDate
        self.endDate = cdTakable.endDate
        self.cycle = Int(cdTakable.cycle)
        self.doseDays = cdTakable.doseDays.compactMap { WeekDay(rawValue: $0) }
        self.doseMethods = (cdTakable.doseMethods as? [CDDoseMethod] ?? []).compactMap { DoseMethod(cdDoseMethod: $0) }
    }
}

extension Takable: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }

    static func == (lhs: Takable, rhs: Takable) -> Bool {
        return lhs.id == rhs.id
    }
}
