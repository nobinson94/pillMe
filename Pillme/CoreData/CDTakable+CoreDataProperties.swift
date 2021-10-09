//
//  CDTakable+CoreDataProperties.swift
//  Pillme
//
//  Created by USER on 2021/10/06.
//
//

import Foundation
import CoreData


extension CDTakable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTakable> {
        return NSFetchRequest<CDTakable>(entityName: "CDTakable")
    }

    @NSManaged public var cycle: Int16
    @NSManaged public var doseDays: [Int]
    @NSManaged public var endDate: Date?
    @NSManaged public var name: String
    @NSManaged public var id: String
    @NSManaged public var startDate: Date
    @NSManaged public var type: Int16
    @NSManaged public var doseMethods: [CDDoseMethod]
    @NSManaged public var user: CDUser?

}

extension CDTakable : Identifiable {

}
