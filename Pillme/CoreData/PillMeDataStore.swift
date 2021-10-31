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

    func add(object: NSManagedObject, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            let semaphore = DispatchSemaphore(value: 0)
            self.container.viewContext.insert(object)
            do {
                try self.container.viewContext.save()
            } catch {
                self.container.viewContext.rollback()
                print("### \(error)")
            }
            semaphore.signal()
            
            switch semaphore.wait(timeout: .distantFuture) {
            case .success:
                DispatchQueue.main.async {
                    completion?()
                }
            case .timedOut:
                print("### TIMEOUT")
                completion?()
            }
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
    
    func update(_ execution: @escaping () -> Void, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            let semaphore = DispatchSemaphore(value: 0)
            self.container.viewContext.perform {
                execution()
                do {
                    try self.container.viewContext.save()
                } catch {
                    self.container.viewContext.rollback()
                    print("### \(error)")
                }
                semaphore.signal()
            }
            
            switch semaphore.wait(timeout: .distantFuture) {
            case .success:
                DispatchQueue.main.async {
                    completion?()
                }
            case .timedOut:
                print("### TIMEOUT")
                completion?()
            }
        }
    }
    
    func delete(object: NSManagedObject, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            let semaphore = DispatchSemaphore(value: 0)
            self.container.viewContext.delete(object)
            do {
                try self.container.viewContext.save()
            } catch {
                self.container.viewContext.rollback()
                print("### \(error)")
            }
            semaphore.signal()

            switch semaphore.wait(timeout: .distantFuture) {
            case .success:
                DispatchQueue.main.async {
                    completion?()
                }
            case .timedOut:
                print("### TIMEOUT")
                completion?()
            }
        }
    }
}

class PillMeDataManager {
    let dataStore: PillMeDataStore
    let notiCenter: PillMeNotificationCenter
    
    static var shared = PillMeDataManager()
    
    private init(dataStore: PillMeDataStore = PillMeDataStore(),
                 notiCenter: PillMeNotificationCenter = PillMeNotificationCenter()) {
        self.dataStore = dataStore
        self.notiCenter = notiCenter
    }
    
    func add(_ pill: Pill, completion: (() -> Void)? = nil) {
        let cdPill = CDPill.create(pill: pill, in: dataStore.container.viewContext)
        dataStore.add(object: cdPill) { [weak self] in
            self?.notiCenter.setNextNotification(for: pill)
            completion?()
        }
    }
    
    func update(pill: Pill, completion: (() -> Void)? = nil) {
        guard let cdPill = getCDPill(id: pill.id) else { return }
        dataStore.update({ [weak self] in
            guard let self = self else { return }
            cdPill.name = pill.name
            cdPill.type = Int16(pill.type.rawValue)
            cdPill.cycle = Int16(pill.cycle)
            cdPill.startDate = pill.startDate
            cdPill.doseDays = pill.doseDays.map { $0.rawValue }
            let cdDoseMethods = pill.doseMethods.map { CDDoseMethod.create(doseMethod: $0, in: self.dataStore.container.viewContext) }
            cdPill.doseMethods = NSOrderedSet(array: cdDoseMethods)
        }, completion: { [weak self] in
            guard let self = self else { return }
            self.notiCenter.setNextNotification(for: pill)
            completion?()
        })
    }
    
    func getPill(id: String) -> Pill? {
        guard let cdPill = getCDPill(id: id) else { return nil }
        
        let pill = Pill(cdPill: cdPill)
        pill.doseMethods = self.getDoseMethods(for: id)
        
        return pill
    }
    
    func getPills(for date: Date? = nil) -> [Pill] {
        let request = NSFetchRequest<CDPill>(entityName: CDPill.description())
        let pills: [Pill] = dataStore.fetch(with: request).map { Pill(cdPill: $0) }
        
        if let date = date {
            return pills.filter { date.isTakeDay(of: $0) }
        }
        return pills
    }
    
    func getPills(for date: Date, takeTime: TakeTime) -> [Pill] {
        let pills = getPills(for: date)

        return pills.filter { pill in
            pill.doseMethods.contains { method in
                method.time == takeTime
            }
        }
    }
    
    func getPills(weekday: WeekDay) -> [Pill] {
        let pills = getPills()
        
        return pills.filter { pill in
            pill.doseDays.contains(weekday)
        }
    }
    
    func getDoseMethods(for pillID: String) -> [DoseMethod] {
        let request = NSFetchRequest<CDDoseMethod>(entityName: CDDoseMethod.description())
        request.predicate = NSPredicate(format: "pill.id == %@", "\(pillID)")
        let doseMethods = dataStore.fetch(with: request).map { DoseMethod(cdDoseMethod: $0) }.sorted { lhs, rhs in
            lhs.time.rawValue < rhs.time.rawValue
        }
        return doseMethods
    }
    
    func deletePill(id: String, completion: (() -> Void)? = nil) {
        guard let cdPill = getCDPill(id: id) else {
            completion?()
            return
        }
        
        let pill = Pill(cdPill: cdPill)
        dataStore.delete(object: cdPill) { [weak self] in
            self?.notiCenter.setNextNotification(for: pill)
            completion?()
        }
    }
    
    func takePill(for pillID: String, time: TakeTime, date: Date = Date()) {
        guard let cdPill = getCDPill(id: pillID), let pill = getPill(id: pillID) else {
            return
        }
        let doseRecord = DoseRecord(pill: pill, takeTime: time, date: date)
        let cdDoseRecord = CDDoseRecord.create(doseRecord: doseRecord, in: dataStore.container.viewContext)
        cdDoseRecord.pill = cdPill
        
        dataStore.add(object: cdDoseRecord)
    }
    
    func untakePill(for pillID: String, time: TakeTime, date: Date = Date()) {
        guard let cdDoseRecord = getCDDoseRecords(pillID: pillID, takeTime: time, date: date).first else {
            return
        }
        
        dataStore.delete(object: cdDoseRecord)
    }
    
    func getDoseRecords(pillID: String?, takeTime: TakeTime?, date: Date?) -> [DoseRecord] {
        let cdDoseRecords = self.getCDDoseRecords(pillID: pillID, takeTime: takeTime, date: date)
        
        return cdDoseRecords.map { DoseRecord(cdDoseRecord: $0) }
    }
}

extension PillMeDataManager {
    private func getCDPill(id: String) -> CDPill? {
        let request = NSFetchRequest<CDPill>(entityName: CDPill.description())
        request.predicate = NSPredicate(format: "id == %@", "\(id)")
        return dataStore.fetch(with: request).first
    }
    
    private func getCDDoseRecords(pillID: String?, takeTime: TakeTime?, date: Date?) -> [CDDoseRecord] {
        let request = NSFetchRequest<CDDoseRecord>(entityName: CDDoseRecord.description())
        var predicates: [NSPredicate] = []
        
        if let date = date {
            predicates.append(NSPredicate(format: "date = %@", Calendar.current.startOfDay(for: date) as NSDate))
        }
        if let pillID = pillID {
            predicates.append(NSPredicate(format: "pill.id = %@", "\(pillID)"))
        }
        if let takeTime = takeTime {
            predicates.append(NSPredicate(format: "takeTime = %@", takeTime.rawValue))
        }
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        return dataStore.fetch(with: request)
    }
}
