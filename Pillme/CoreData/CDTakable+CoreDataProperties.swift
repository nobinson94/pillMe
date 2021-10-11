//
//  CDTakable+CoreDataProperties.swift
//  Pillme
//
//  Created by USER on 2021/10/10.
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
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var startDate: Date
    @NSManaged public var type: Int16
    @NSManaged public var user: CDUser?
    @NSManaged public var doseMethods: NSOrderedSet
    @NSManaged public var doseRecords: NSSet?

}

// MARK: Generated accessors for doseMethods
extension CDTakable {

    @objc(insertObject:inDoseMethodsAtIndex:)
    @NSManaged public func insertIntoDoseMethods(_ value: CDDoseMethod, at idx: Int)

    @objc(removeObjectFromDoseMethodsAtIndex:)
    @NSManaged public func removeFromDoseMethods(at idx: Int)

    @objc(insertDoseMethods:atIndexes:)
    @NSManaged public func insertIntoDoseMethods(_ values: [CDDoseMethod], at indexes: NSIndexSet)

    @objc(removeDoseMethodsAtIndexes:)
    @NSManaged public func removeFromDoseMethods(at indexes: NSIndexSet)

    @objc(replaceObjectInDoseMethodsAtIndex:withObject:)
    @NSManaged public func replaceDoseMethods(at idx: Int, with value: CDDoseMethod)

    @objc(replaceDoseMethodsAtIndexes:withDoseMethods:)
    @NSManaged public func replaceDoseMethods(at indexes: NSIndexSet, with values: [CDDoseMethod])

    @objc(addDoseMethodsObject:)
    @NSManaged public func addToDoseMethods(_ value: CDDoseMethod)

    @objc(removeDoseMethodsObject:)
    @NSManaged public func removeFromDoseMethods(_ value: CDDoseMethod)

    @objc(addDoseMethods:)
    @NSManaged public func addToDoseMethods(_ values: NSOrderedSet)

    @objc(removeDoseMethods:)
    @NSManaged public func removeFromDoseMethods(_ values: NSOrderedSet)

}

// MARK: Generated accessors for doseRecords
extension CDTakable {

    @objc(addDoseRecordsObject:)
    @NSManaged public func addToDoseRecords(_ value: CDDoseRecord)

    @objc(removeDoseRecordsObject:)
    @NSManaged public func removeFromDoseRecords(_ value: CDDoseRecord)

    @objc(addDoseRecords:)
    @NSManaged public func addToDoseRecords(_ values: NSSet)

    @objc(removeDoseRecords:)
    @NSManaged public func removeFromDoseRecords(_ values: NSSet)

}

extension CDTakable : Identifiable {

}
