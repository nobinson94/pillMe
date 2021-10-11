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
    @Published var todayTakables: [Takable] = []
    @Published var nowTakables: [Takable] = []
    
    var currentTime: TakeTime {
        UserInfoManager.shared.currentTime
    }
    
    var prevTime: TakeTime {
        currentTime
    }
    
    func fetch() {
        todayTakables = PillMeDataManager.shared.getTakables(for: Date())
    }
}
