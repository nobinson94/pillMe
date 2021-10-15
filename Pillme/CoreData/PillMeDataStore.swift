//
//  PillMeDataStore.swift
//  Pillme
//
//  Created by USER on 2021/09/14.
//

import CoreData
import Foundation

class PillMeDataStore {
    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Pill")
        container.loadPersistentStores { _, error in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
        return container
    }()

    func add(object: NSManagedObject) {
        container.viewContext.insert(object)
        do {
            try container.viewContext.save()
        } catch {
            container.viewContext.rollback()
            print("### \(error)")
        }
    }
    
    func fetch<T: NSManagedObject>(with request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: T.description())) -> [T] {
        do {
            return try container.viewContext.fetch(request)
        } catch {
            container.viewContext.rollback()
            print("### \(error)")
            return []
        }
    }
    
    func update(_ closure: @escaping () -> Void) {
        container.viewContext.perform {
            closure()
            do {
                try self.container.viewContext.save()
            } catch {
                self.container.viewContext.rollback()
                print("### \(error)")
            }
        }
    }
    
    func delete(object: NSManagedObject) {
        container.viewContext.delete(object)
        do {
            try container.viewContext.save()
        } catch {
            container.viewContext.rollback()
            print("### \(error)")
        }
    }
}

class PillMeDataManager {
    let dataStore: PillMeDataStore
    static var shared = PillMeDataManager()
    
    private init(dataStore: PillMeDataStore = PillMeDataStore()) {
        self.dataStore = dataStore
    }
    
    func add(_ pill: Pill, completion: (() -> Void)? = nil) {
        let cdPill = CDPill.create(pill: pill, in: dataStore.container.viewContext)
        dataStore.add(object: cdPill)
        completion?()
    }
    
    func deletePill(id: String, completion: (() -> Void)? = nil) {
        guard let cdPill = getCDPill(id: id) else { return }
        dataStore.delete(object: cdPill)
        completion?()
    }
    
    func updatePill(id: String, closure: @escaping (CDPill) -> Void, completion: (() -> Void)? = nil) {
        guard let cdPill = getCDPill(id: id) else { return }
        dataStore.update {
            closure(cdPill)
        }
    }
    
    private func getCDPill(id: String) -> CDPill? {
        let request = NSFetchRequest<CDPill>(entityName: CDPill.description())
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        return dataStore.fetch(with: request).first
    }
    
    func getPill(id: String) -> Pill? {
        guard let cdPill = getCDPill(id: id) else { return nil }
        let pill = Pill(cdPill: cdPill)
        pill.doseMethods = self.getDoseMethods(for: id)
        
        return pill
    }
    
    func getPills(for date: Date? = nil) -> [Pill] {
        let request = NSFetchRequest<CDPill>(entityName: CDPill.description())
        
        let pills: [Pill] = dataStore.fetch(with: request)
            .map {
                let pill = Pill(cdPill: $0)
                pill.doseMethods = self.getDoseMethods(for: $0.id)
                return pill
            }
        
        if let date = date {
            return pills.filter { date.isTakeDay(of: $0) }
        }
        return pills
    }
    
    func getDoseMethods(for pillId: String) -> [DoseMethod] {
        let request = NSFetchRequest<CDDoseMethod>(entityName: CDDoseMethod.description())
        request.predicate = NSPredicate(format: "pill.id == %@", "\(pillId)")
        let doseMethods = dataStore.fetch(with: request).map { DoseMethod(cdDoseMethod: $0) }
        return doseMethods
    }
    
    func deletePill(for pillId: String) -> Pill? {
        guard let cdPill = getCDPill(id: pillId) else {
            return nil
        }
        
        dataStore.delete(object: cdPill)
        
        return Pill(cdPill: cdPill)
    }
}


extension Date {
    func isTakeDay(of pill: Pill) -> Bool {
        let startDate = Calendar.current.startOfDay(for: pill.startDate)
        guard startDate < self else { return false }
        
        if pill.cycle == 1 {
            return true
        } else if pill.cycle > 1 {
            guard let distanceOfDay = Calendar.current.dateComponents([.day], from: startDate, to: Calendar.current.startOfDay(for: self)).day else { return false }
            return (distanceOfDay + 1)%pill.cycle == 0
        } else if !pill.doseDays.isEmpty {
            return pill.doseDays.contains(self.weekDay)
        }
        
        return false
    }
}
