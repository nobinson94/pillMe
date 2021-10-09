//
//  CDDoseMethod+CoreDataProperties.swift
//  Pillme
//
//  Created by USER on 2021/10/06.
//
//

import Foundation
import CoreData


extension CDDoseMethod {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDDoseMethod> {
        return NSFetchRequest<CDDoseMethod>(entityName: "CDDoseMethod")
    }

    @NSManaged public var time: Int16
    @NSManaged public var pillNum: Int16
    @NSManaged public var pill: CDTakable?

}

extension CDDoseMethod : Identifiable {

}
