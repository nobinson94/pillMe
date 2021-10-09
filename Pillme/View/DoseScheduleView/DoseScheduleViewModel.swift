//
//  NewDoseScheduleViewModel.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import Combine
import Foundation
import SwiftUI

enum DoseScheduleQuestion: Int, CaseIterable {
    case takableType
    case name
    case startDate
    case cycle
    case oneDay
    
    var showNextButton: Bool {
        switch self {
        case .takableType: return false
        default: return true
        }
    }
}

protocol QuestionView: View {
    var currentStep: Int { get set }
    var totalStep: Int { get set }
    var goNextQuestion: (() -> Void)? { get set }
    var isCurrentQuestion: Bool { get set }
    var question: DoseScheduleQuestion { get }
}

extension QuestionView {
    var currentStep: Int { 0 }
    var totalStep: Int { 1 }
    var goNextQuestion: (() -> Void)? { nil }
}

class DoseScheduleViewModel: ObservableObject {
    @Published var currentQuestion: DoseScheduleQuestion? = .takableType
    @Published var lastQuestion: DoseScheduleQuestion? = .takableType
//    @Published var takable: Takable
    
    @Published var id: String = UUID().uuidString
    @Published var name: String = ""
    @Published var type: TakableType = .pill
    @Published var startDate: Date = Date()
    @Published var endDate: Date?
    @Published var cycle: Int = 0
    @Published var doseDays: [WeekDay] = []
    @Published var doseMethods: [DoseMethod] = []
    
    @State var isEditMode: Bool = true
    
    var pillID: String
    var bag = Set<AnyCancellable>()
    var canConfirm: Bool {
        switch currentQuestion {
        case .name: return !name.isEmpty
        case .cycle: return doseDays.count > 0 || cycle > 0
        case .oneDay: return false
        default: return true
        }
    }
    var isCompleted: Bool {
        return lastQuestion == nil
    }
    
    init(pillID: String = UUID().uuidString) {
        self.pillID = pillID
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
            if let nextQuestion = DoseScheduleQuestion(rawValue: currentQuestion.rawValue + 1), canConfirm {
                self.currentQuestion = nextQuestion
                self.lastQuestion = nextQuestion
            }
            return
        }
        
        self.currentQuestion = lastQuestion
    }

    func reset() {
        guard let firstQuestion = DoseScheduleQuestion(rawValue: 0) else { return }
        self.currentQuestion = firstQuestion
    }
    
    func save() {
        
    }
}
