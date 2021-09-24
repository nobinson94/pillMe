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
    
    func fetch<T: NSManagedObject>() -> [T] {
        let request: NSFetchRequest = NSFetchRequest<T>(entityName: T.description())
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
