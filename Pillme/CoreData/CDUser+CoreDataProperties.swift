//
//  CDUser+CoreDataProperties.swift
//  Pillme
//
//  Created by USER on 2021/09/15.
//
//

import Foundation
import CoreData


extension CDUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUser> {
        return NSFetchRequest<CDUser>(entityName: "CDUser")
    }

    @NSManaged public var name: String?
    @NSManaged public var gender: String?

}

extension CDUser : Identifiable {

}
