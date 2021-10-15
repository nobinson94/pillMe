//
//  CDUser+CoreDataProperties.swift
//  Pillme
//
//  Created by USER on 2021/10/10.
//
//

import Foundation
import CoreData


extension CDUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
    }

    @NSManaged public var gender: String?
    @NSManaged public var name: String?
    @NSManaged public var pills: CDPill?

}

extension CDUser : Identifiable {

}
