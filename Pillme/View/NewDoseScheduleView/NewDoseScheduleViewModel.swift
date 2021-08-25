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
    @Published var step: NewDoseScheduleStep = .takableTypeStep
    @Published var pillType: TakableType? = .pill
    @Published var pillName: String = ""
    @Published var startDate: Date = Date()
    @Published var cycle: Int = 1
    @Published var hasFixedDays: Bool = false
    @Published var numberOfOneDay: Int = 3
}

protocol StepView: View {
    var step: Int { get }
    var isCurrentStep: Bool { get set }
}
