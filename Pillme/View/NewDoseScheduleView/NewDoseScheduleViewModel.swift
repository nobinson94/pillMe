//
//  NewDoseScheduleViewModel.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import Combine
import Foundation
import SwiftUI

enum NewDoseScheduleQuestion: Int, CaseIterable {
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
    var question: NewDoseScheduleQuestion { get }
}

extension QuestionView {
    var currentStep: Int { 0 }
    var totalStep: Int { 1 }
    var goNextQuestion: (() -> Void)? { nil }
}

class NewDoseScheduleViewModel: ObservableObject {
    @Published var currentQuestion: NewDoseScheduleQuestion? = .takableType
    @Published var lastQuestion: NewDoseScheduleQuestion? = .takableType
    @Published var pillType: TakableType?
    @Published var pillName: String = ""
    @Published var startDate: Date = Date()
    @Published var cycle: Int = 1
    @Published var hasFixedDays: Bool = false
    @Published var weekdays: [WeekDay] = []
    @Published var numberOfOneDay: Int = 3
    @Published var timesOfOneDay: [TakeTime] = []
    
    var pillID: String
    var bag = Set<AnyCancellable>()
    var canConfirm: Bool {
        switch currentQuestion {
        case .name: return !pillName.isEmpty
        case .cycle:
            if hasFixedDays { return weekdays.count > 0}
            return cycle > 0
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
            if let nextQuestion = NewDoseScheduleQuestion(rawValue: currentQuestion.rawValue + 1), canConfirm {
                self.currentQuestion = nextQuestion
                self.lastQuestion = nextQuestion
            }
            return
        }
        
        self.currentQuestion = lastQuestion
    }
//
//    func prev() {
//        guard let currentQuestion = currentQuestion, let prev = NewDoseScheduleQuestion(rawValue: currentQuestion.rawValue - 1) else { return }
//        self.currentQuestion = prev
//    }
//
    func reset() {
        guard let firstQuestion = NewDoseScheduleQuestion(rawValue: 0) else { return }
        self.currentQuestion = firstQuestion
    }
    
    func save() {
        
    }
}

enum TakeTime: Int, CaseIterable {
    case afterWakeup
    case beforeBreakfast
    case afterBreakfast
    case betweenBreakfastLunch
    case beforeLunch
    case afterLunch
    case betweenLunchDinner
    case beforeDinner
    case afterDinner
    case beforeSleep
    
    var title: String {
        switch self {
        case .afterWakeup: return "일어나자마자"
        case .beforeBreakfast: return "아침 먹기 전"
        case .afterBreakfast: return "아침 먹은 후"
        case .betweenBreakfastLunch: return "아침-점심 식간"
        case .beforeLunch: return "점심 먹기 전"
        case .afterLunch: return "점심 먹은 후"
        case .betweenLunchDinner: return "점심-저녁 식간"
        case .beforeDinner: return "저녁 먹기 전"
        case .afterDinner: return "저녁 먹은 후"
        case .beforeSleep: return "잠들기 전"
        }
    }
}
