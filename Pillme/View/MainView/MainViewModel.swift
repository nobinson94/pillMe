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
    
    var date: Date {
        let today = Calendar.current.startOfDay(for: Date())
        if TakeTime.isOverNight {
            return today.yesterday
        }
        return today
    }
    
    var schedules: [DoseSchedule] {
        currentSchedules + prevSchedules + nextSchedules
    }
    
    var currentTime: TakeTime {
        TakeTime.current
    }
    
    var encourageMessage: String? {
        guard let currentScheudle = randomCurrentSchedule else { return nil }
        return currentTime.encourageMessage(pillName: currentScheudle.pill.name)
    }
    
    var prevTime: TakeTime? {
        if currentTime.prevTime == .beforeSleep { return nil }
        return currentTime.prevTime
    }
    
    var nextTime: TakeTime? {
        if currentTime.nextTime == .afterWakeup { return nil }
        return currentTime.nextTime
    }
    
    var randomCurrentSchedule: DoseSchedule? {
        if currentSchedules.count > 0 {
            let randomIndex = Int.random(in: 0..<currentSchedules.count)
            return currentSchedules[randomIndex]
        }
        return nil
    }
    
    func fetch() {
        self.currentSchedules = PillMeDataManager.shared.getPills(for: date, takeTime: currentTime)
            .map { DoseSchedule(pill: $0, date: date, takeTime: currentTime) }
        
        if let nextTime = nextTime {
            nextSchedules = PillMeDataManager.shared.getPills(for: date, takeTime: nextTime)
                .map { DoseSchedule(pill: $0, date: date, takeTime: nextTime) }
        }
        if let prevTime = prevTime {
            prevSchedules = PillMeDataManager.shared.getPills(for: date, takeTime: prevTime)
                .map { DoseSchedule(pill: $0, date: date, takeTime: prevTime) }
        }
        
        allPills = PillMeDataManager.shared.getPills()
    }
}
