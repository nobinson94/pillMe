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
//        let request: NSFetchRequest = NSFetchRequest<T>(entityName: T.description())
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
    
    func add(_ takable: Takable, completion: (() -> Void)? = nil) {
        let cdTakable = CDTakable.create(takable: takable, in: dataStore.container.viewContext)
        dataStore.add(object: cdTakable)
        completion?()
    }
    
    func delete(id: String, completion: (() -> Void)? = nil) {
        guard let cdTakable = getTakable(id: id) else { return }
        dataStore.delete(object: cdTakable)
        completion?()
    }
    
    func update(id: String, closure: @escaping (CDTakable) -> Void, completion: (() -> Void)? = nil) {
        guard let cdTakable = getTakable(id: id) else { return }
        dataStore.update {
            closure(cdTakable)
        }
    }
    
    private func getTakable(id: String) -> CDTakable? {
        let request = NSFetchRequest<CDTakable>(entityName: CDTakable.description())
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        return dataStore.fetch(with: request).first
    }
    
    func getTakables(for date: Date? = nil) -> [Takable] {
        let request = NSFetchRequest<CDTakable>(entityName: CDTakable.description())
        
        let takables = dataStore.fetch(with: request).map { Takable(cdTakable: $0) }
        if let date = date {
            return takables.filter { date.isTakeDay(of: $0) }
        }
        return takables
    }
}


extension Date {
    func isTakeDay(of takable: Takable) -> Bool {
        let startDate = Calendar.current.startOfDay(for: takable.startDate)
        guard startDate < self else { return false }
        
        if takable.cycle == 1 {
            return true
        } else if takable.cycle > 1 {
            guard let distanceOfDay = Calendar.current.dateComponents([.day], from: startDate, to: Calendar.current.startOfDay(for: self)).day else { return false }
            return (distanceOfDay + 1)%takable.cycle == 0
        } else if !takable.doseDays.isEmpty {
            return takable.doseDays.contains(self.weekDay)
        }
        
        return false
    }
}
