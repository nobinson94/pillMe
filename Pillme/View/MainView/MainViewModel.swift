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
    @Published var allTakables: [Takable] = []
    @Published var todayForgotTakables: [Takable] = []
    @Published var todayTookTakables: [Takable] = []
    @Published var todayLeftTakables: [Takable] = []
    
    func fetch() {
        allTakables = TestTakables.fetchAll()
    }
}

class TestTakables {
    static func fetchAll() -> [Takable] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        
        let dataStore = PillMeDataStore()
        let context = appDelegate.persistentContainer.viewContext
//        let takables = try context.fetch(CDTakable)
        do {
            let cdTakables = try context.fetch(CDTakable.fetchRequest())
            return cdTakables.map { Takable(cdTakable: $0) }
        } catch {
            print("### fetch \(error)")
        }
        return []
//        return [
//            Takable(name: "아연"),
//            Takable(name: "유산균"),
//            Takable(name: "아르기닌"),
//            Takable(name: "칼슘"),
//            Takable(name: "임팩타민"),
//            Takable(name: "마그네슘"),
//            Takable(name: "비타민B"),
//            Takable(name: "비타민K"),
//            Takable(name: "비타민K2"),
//            Takable(name: "오메가3")
//        ]
    }
}
