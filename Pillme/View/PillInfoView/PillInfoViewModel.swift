//
//  PillInfoViewModel.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import Combine
import CoreData
import Foundation
import SwiftUI

enum DoseScheduleQuestion: Int, CaseIterable {
    case pillType
    case name
    case startDate
    case cycle
    case oneDay
}

class PillInfoViewModel: ObservableObject {
    @Published var currentQuestion: DoseScheduleQuestion? = .pillType
    @Published var lastQuestion: DoseScheduleQuestion? = .pillType
    
    @Published var id: String = UUID().uuidString
    @Published var name: String = ""
    @Published var type: PillType?
    @Published var startDate: Date = Date()
    @Published var endDate: Date?
    @Published var cycle: Int = 0
    @Published var doseDays: [WeekDay] = []
    @Published var doseMethods: [DoseMethod] = []
    
    var bag = Set<AnyCancellable>()
    var isNewpill: Bool = true
    
    @Published var isEditMode: Bool = true
    @Published var nameDuplicated: Bool = false
    
    var title: String = ""

    var canConfirm: Bool {
        switch currentQuestion {
        case .pillType: return type != nil
        case .name: return !name.isEmpty && !nameDuplicated
        case .cycle: return !doseDays.isEmpty || cycle > 0
        case .oneDay: return !doseMethods.isEmpty
        default: return true
        }
    }
    
    var isCompleted: Bool {
        return lastQuestion == nil
    }
    
    init(id: String? = nil) {
        self.isNewpill = id == nil
        self.id = id ?? UUID().uuidString
        
        $name
            .filter { _ in self.isEditMode }
            .sink { [weak self] name in
                guard let pill = PillMeDataManager.shared.getPill(name: name) else {
                    self?.nameDuplicated = false
                    return
                }
                self?.nameDuplicated = pill.id != self?.id
            }
            .store(in: &bag)
    }
    
    func fetch(id: String) {
        guard let pill = PillMeDataManager.shared.getPill(id: id) else {
            return
        }
        self.name = pill.name
        self.type = pill.type
        self.startDate = pill.startDate
        self.endDate = pill.endDate
        self.cycle = pill.cycle
        self.doseDays = pill.doseDays
        self.doseMethods = pill.doseMethods
    }
    
    func setEditMode(_ editing: Bool) {
        self.isEditMode = editing
        if !editing {
            self.nameDuplicated = false
        }
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
        guard !isNewpill else {
            self.setTitle("새로운 약 추가하기")
            reset()
            return
        }
        self.fetch(id: id)
        self.setEditMode(false)
        self.setTitle(self.name)
        self.currentQuestion = nil
        self.lastQuestion = nil
    }
    
    func reset() {
        guard let firstQuestion = DoseScheduleQuestion(rawValue: 0) else { return }
        self.currentQuestion = firstQuestion
    }
    
    private func setTitle(_ title: String) {
        self.title = title
    }
    
    func save(_ completion: (() -> Void)? = nil) {
        guard let type = type, isEditMode else { return }
        if isNewpill {
            let pill = Pill(name: name, type: type, startDate: startDate, cycle: cycle, doseDays: doseDays, doseMethods: doseMethods)
            PillMeDataManager.shared.add(pill) {
                self.isNewpill = false
                self.setTitle(self.name)
                self.setEditMode(false)
                completion?()
            }
        } else {
            let pill = Pill(id: self.id, name: self.name, type: type, startDate: self.startDate, endDate: self.endDate, cycle: self.cycle, doseDays: self.doseDays, doseMethods: self.doseMethods)
            PillMeDataManager.shared.update(pill: pill) {
                self.setTitle(self.name)
                self.setEditMode(false)
                completion?()
            }
        }
    }
    
    func deletePill(_ completion: (() -> Void)? = nil) {
        guard !isNewpill else { return }
        PillMeDataManager.shared.deletePill(id: id) {
            completion?()
        }
    }
}
