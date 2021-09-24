//
//  CDDoseRecord+CoreDataProperties.swift
//  Pillme
//
//  Created by USER on 2021/09/15.
//
//

import Foundation
import CoreData


extension CDDoseRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDoseRecord> {
        return NSFetchRequest<CDDoseRecord>(entityName: "CDDoseRecord")
    }

    @NSManaged public var date: Date?
    @NSManaged public var pill: CDPill?

}

extension CDDoseRecord : Identifiable {

}
