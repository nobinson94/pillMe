//
//  CDTakable+CoreDataClass.swift
//  Pillme
//
//  Created by USER on 2021/10/10.
//
//

import Foundation
import CoreData

@objc(CDTakable)
public class CDTakable: NSManagedObject {
    static func create(takable: Takable, in context: NSManagedObjectContext) -> CDTakable {
        let cdTakable = CDTakable(context: context)
        cdTakable.id = takable.id
        cdTakable.name = takable.name
        cdTakable.startDate = takable.startDate
        cdTakable.endDate = takable.endDate
        cdTakable.cycle = Int16(takable.cycle)
        cdTakable.doseDays = takable.doseDays.map { $0.rawValue }
        
        let cdDoseMethods = takable.doseMethods.map { doseMethod -> CDDoseMethod in
            let cdDoseMethod = CDDoseMethod.create(doseMethod: doseMethod, in: context)
            cdDoseMethod.takable = cdTakable
            return cdDoseMethod
        }
        cdTakable.addToDoseMethods(NSOrderedSet(array: cdDoseMethods))
        
        return cdTakable
    }
}
