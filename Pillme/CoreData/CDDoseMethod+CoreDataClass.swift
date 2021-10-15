//
//  CDDoseMethod+CoreDataClass.swift
//  Pillme
//
//  Created by USER on 2021/10/10.
//
//

import Foundation
import CoreData

@objc(CDDoseMethod)
public class CDDoseMethod: NSManagedObject {
    static func create(doseMethod: DoseMethod, in context: NSManagedObjectContext) -> CDDoseMethod {
        let cdDoseMethod = CDDoseMethod(context: context)
        cdDoseMethod.num = Int16(doseMethod.num)
        cdDoseMethod.time = Int16(doseMethod.time.rawValue)
//        cdDoseMethod.pill = CDPill doseMethod.pill
        
        return cdDoseMethod
    }
}
