//
//  CDDoseMethod+CoreDataProperties.swift
//  Pillme
//
//  Created by USER on 2021/10/10.
//
//

import Foundation
import CoreData


extension CDDoseMethod {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDoseMethod> {
        return NSFetchRequest<CDDoseMethod>(entityName: "CDDoseMethod")
    }

    @NSManaged public var num: Int16
    @NSManaged public var time: Int16
    @NSManaged public var pill: CDPill

}

extension CDDoseMethod : Identifiable {

}
