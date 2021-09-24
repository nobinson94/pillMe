//
//  NewDoseScheduleViewModel.swift
//  Pillme
//
//  Created by USER on 2021/08/20.
//

import Combine
import Foundation
import SwiftUI

enum NewDoseScheduleStep: Int, CaseIterable {
    case takableTypeStep
    case nameStep
    case startDateStep
    case cycleStep
    case oneDayStep
}

class NewDoseScheduleViewModel: ObservableObject {
    @Published var currentStep: NewDoseScheduleStep = .takableTypeStep
    @Published var pillType: TakableType = .pill
    @Published var pillName: String = ""
    @Published var startDate: Date = Date()
    @Published var cycle: Int = 0
    @Published var hasFixedDays: Bool = false
    @Published var numberOfOneDay: Int = 3
    
    var bag = Set<AnyCancellable>()
    var canGoNext: Bool {
        switch currentStep {
        case .nameStep: return !pillName.isEmpty
        case .cycleStep: return cycle > 0
        default: return true
        }
    }
    
    func next() {
        guard let nextStep = NewDoseScheduleStep(rawValue: currentStep.rawValue + 1), canGoNext else { return }
        currentStep = nextStep
    }
    
    func prev() {
        guard let prevStep = NewDoseScheduleStep(rawValue: currentStep.rawValue - 1) else { return }
        currentStep = prevStep
    }
    
    func reset() {
        guard let firstStep = NewDoseScheduleStep(rawValue: 0) else { return }
        currentStep = firstStep
    }
    
    func save() {
        
    }
}

protocol StepView: View {
    var step: NewDoseScheduleStep { get }
    var isCurrentStep: Bool { get set }
}
