//
//  Takable.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

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

protocol Takable {
    var name: String { get set }
    var type: TakableType { get }
}

struct Pill: Takable {
    var name: String
    var type: TakableType { .pill }
}

struct Supplement: Takable {
    var name: String
    var type: TakableType { .supplement }
}

struct DoseMethod {
    var time: Date
    var pillNum: Int
}

struct DoseSchedule {
    var startDate: Date
    var doseDays: [WeekDay]
    var doseMethods: [DoseMethod]
}

