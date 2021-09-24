//
//  CDPill+CoreDataProperties.swift
//  Pillme
//
//  Created by USER on 2021/09/15.
//
//

import Foundation
import CoreData


extension CDPill {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPill> {
        return NSFetchRequest<CDPill>(entityName: "CDPill")
    }

    @NSManaged public var name: String?
    @NSManaged public var pilID: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var endDate: Date?
    @NSManaged public var weekDays: NSObject?
    @NSManaged public var cycle: Int16
    @NSManaged public var user: CDUser?

}

extension CDPill : Identifiable {

}
