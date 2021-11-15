//
//  MainViewModel.swift
//  Pillme
//
//  Created by USER on 2021/10/06.
//

import Combine
import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var allPills: [Pill] = []
    @Published var currentSchedules: [DoseSchedule] = []
    @Published var prevSchedules: [DoseSchedule] = []
    @Published var nextSchedules: [DoseSchedule] = []
    
    var schedules: [DoseSchedule] {
        currentSchedules + prevSchedules + nextSchedules
    }
    
    var currentTime: TakeTime {
        TakeTime.current
    }
    
    var prevTime: TakeTime? {
        if currentTime.prevTime == .beforeSleep { return nil }
        return currentTime.prevTime
    }
    
    var nextTime: TakeTime? {
        if currentTime.nextTime == .afterWakeup { return nil }
        return currentTime.nextTime
    }
    
    var randomCurrentPill: DoseSchedule? {
        if currentSchedules.count > 0 {
            let randomIndex = Int.random(in: 0..<currentSchedules.count)
            return currentSchedules[randomIndex]
        }
        return nil
    }
    
    func fetch() {
        let today = Calendar.current.startOfDay(for: Date())
        
        self.currentSchedules = PillMeDataManager.shared.getPills(for: today, takeTime: currentTime)
            .map { DoseSchedule(pill: $0, date: today, takeTime: currentTime) }
        
        if let nextTime = nextTime {
            nextSchedules = PillMeDataManager.shared.getPills(for: today, takeTime: nextTime)
                .map { DoseSchedule(pill: $0, date: today, takeTime: nextTime) }
        }
        if let prevTime = prevTime {
            prevSchedules = PillMeDataManager.shared.getPills(for: today, takeTime: prevTime)
                .map { DoseSchedule(pill: $0, date: today, takeTime: prevTime) }
        }
        allPills = PillMeDataManager.shared.getPills()
    }
}
