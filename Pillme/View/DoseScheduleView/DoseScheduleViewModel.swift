//
//  NewDoseScheduleViewModel.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import Combine
import CoreData
import Foundation
import SwiftUI

enum DoseScheduleQuestion: Int, CaseIterable {
    case takableType
    case name
    case startDate
    case cycle
    case oneDay
}

class DoseScheduleViewModel: ObservableObject {
    @Published var currentQuestion: DoseScheduleQuestion? = .takableType
    @Published var lastQuestion: DoseScheduleQuestion? = .takableType
    
    @Published var id: String = UUID().uuidString
    @Published var name: String = ""
    @Published var type: TakableType?
    @Published var startDate: Date = Date()
    @Published var endDate: Date?
    @Published var cycle: Int = 0
    @Published var doseDays: [WeekDay] = []
    @Published var doseMethods: [DoseMethod] = []
    
    var bag = Set<AnyCancellable>()
    var isNewTakable: Bool = true
    
    var title: String {
        guard !isNewTakable else {
            return "새로운 약 추가하기"
        }
        
        return "[\(name)] 정보"
    }
    
    var canConfirm: Bool {
        switch currentQuestion {
        case .takableType: return type != nil
        case .name: return !name.isEmpty
        case .cycle: return !doseDays.isEmpty || cycle > 0
        case .oneDay: return !doseMethods.isEmpty
        default: return true
        }
    }
    
    var isCompleted: Bool {
        return lastQuestion == nil
    }
    
    init(id: String? = nil) {
        self.isNewTakable = id == nil
        self.id = id ?? UUID().uuidString
    }
    
    func fetch(id: String) {
        guard let takable = PillMeDataManager.shared.getTakable(id: id) else {
            return
        }
        self.name = takable.name
        self.type = takable.type
        self.startDate = takable.startDate
        self.endDate = takable.endDate
        self.cycle = takable.cycle
        self.doseDays = takable.doseDays
        self.doseMethods = takable.doseMethods
    }
    
    func confirm() {
        guard let currentQuestion = currentQuestion else {
            return
        }

        guard !isCompleted else {
            self.currentQuestion = nil
            return
        }
        
        if self.lastQuestion == currentQuestion {
            if currentQuestion == .oneDay {
                self.currentQuestion = nil
                self.lastQuestion = nil
                return
            }
            if let nextQuestion = DoseScheduleQuestion(rawValue: currentQuestion.rawValue + 1), canConfirm {
                self.currentQuestion = nextQuestion
                self.lastQuestion = nextQuestion
            }
            return
        }
        
        self.currentQuestion = lastQuestion
    }

    func prepare() {
        guard !isNewTakable else {
            reset()
            return
        }
        fetch(id: id)
        self.currentQuestion = nil
        self.lastQuestion = nil
    }
    
    func reset() {
        guard let firstQuestion = DoseScheduleQuestion(rawValue: 0) else { return }
        self.currentQuestion = firstQuestion
    }
    
    func save(_ completion: (() -> Void)? = nil) {
        guard let type = type else { return }
        if isNewTakable {
            let takable = Takable(name: name, type: type, startDate: startDate, cycle: cycle, doseDays: doseDays, doseMethods: doseMethods)
            PillMeDataManager.shared.add(takable) {
                self.isNewTakable = false
                completion?()
            }
        } else {
            PillMeDataManager.shared.updateTakable(id: id) { cdTakable in
                cdTakable.name = self.name
                cdTakable.type = Int16(type.rawValue)
                cdTakable.cycle = Int16(self.cycle)
                cdTakable.startDate = self.startDate
                cdTakable.doseDays = self.doseDays.map { $0.rawValue }
            } completion: {
                completion?()
            }
        }
    }
}
