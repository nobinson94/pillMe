//
//  CDPill+CoreDataClass.swift
//  Pillme
//
//  Created by USER on 2021/10/10.
//
//

import Foundation
import CoreData

@objc(CDPill)
public class CDPill: NSManagedObject {
    static func create(pill: Pill, in context: NSManagedObjectContext) -> CDPill {
        let cdPill = CDPill(context: context)
        cdPill.id = pill.id
        cdPill.name = pill.name
        cdPill.startDate = pill.startDate
        cdPill.endDate = pill.endDate
        cdPill.cycle = Int16(pill.cycle)
        cdPill.doseDays = pill.doseDays.map { $0.rawValue }
        
        let cdDoseMethods = pill.doseMethods.map { doseMethod -> CDDoseMethod in
            let cdDoseMethod = CDDoseMethod.create(doseMethod: doseMethod, in: context)
            cdDoseMethod.pill = cdPill
            return cdDoseMethod
        }
        cdPill.addToDoseMethods(NSOrderedSet(array: cdDoseMethods))
        
        return cdPill
    }
}
