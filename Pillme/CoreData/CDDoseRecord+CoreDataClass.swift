//
//  CDDoseRecord+CoreDataClass.swift
//  Pillme
//
//  Created by USER on 2021/10/10.
//
//

import Foundation
import CoreData

@objc(CDDoseRecord)
public class CDDoseRecord: NSManagedObject {
    static func create(doseRecord: DoseRecord, in context: NSManagedObjectContext) -> CDDoseRecord {
        let cdDoseRecord = CDDoseRecord(context: context)
        if let takeTime = doseRecord.takeTime {
            cdDoseRecord.takeTime = Int16(takeTime.rawValue)
        }
        cdDoseRecord.date = Calendar.current.startOfDay(for: doseRecord.date)
        
        return cdDoseRecord
    }
}
