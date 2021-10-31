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
    @Published var currentPills: [Pill] = []
    @Published var prevPills: [Pill] = []
    @Published var nextPills: [Pill] = []
    
    var nowPills: [Pill] {
        currentPills + prevPills + nextPills
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
    
    var randomCurrentPill: Pill? {
        if currentPills.count > 0 {
            let randomIndex = Int.random(in: 0..<currentPills.count)
            return currentPills[randomIndex]
        } else if nextPills.count > 0 {
            let randomIndex = Int.random(in: 0..<nextPills.count)
            return nextPills[randomIndex]
        }
        return nil
    }
    
    func fetch() {
        let todayPills = PillMeDataManager.shared.getPills(for: Date())
        
        currentPills = todayPills.filter { $0.doseMethods.contains { $0.time == currentTime }}
        
        if prevTime == .beforeSleep {
            let yesterdayPills = PillMeDataManager.shared.getPills(for: Date())
            prevPills = yesterdayPills.filter { $0.doseMethods.contains { $0.time == prevTime }}
        } else {
            prevPills = todayPills.filter { $0.doseMethods.contains { $0.time == prevTime }}
        }
        
        if prevTime == .beforeSleep {
            let tommorrowPills = PillMeDataManager.shared.getPills(for: Date())
            nextPills = tommorrowPills.filter { $0.doseMethods.contains { $0.time == nextTime }}
        } else {
            nextPills = todayPills.filter { $0.doseMethods.contains { $0.time == nextTime }}
        }
        
        allPills = PillMeDataManager.shared.getPills()
    }
}
