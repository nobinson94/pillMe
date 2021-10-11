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
        cdDoseMethod.pillNum = Int16(doseMethod.pillNum)
        cdDoseMethod.time = Int16(doseMethod.time.rawValue)
        
        return cdDoseMethod
    }
}
