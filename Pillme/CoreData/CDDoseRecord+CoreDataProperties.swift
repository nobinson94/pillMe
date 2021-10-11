//
//  CDDoseRecord+CoreDataProperties.swift
//  Pillme
//
//  Created by USER on 2021/10/10.
//
//

import Foundation
import CoreData


extension CDDoseRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDoseRecord> {
        return NSFetchRequest<CDDoseRecord>(entityName: "CDDoseRecord")
    }

    @NSManaged public var date: Date?
    @NSManaged public var takable: CDTakable?

}

extension CDDoseRecord : Identifiable {

}
