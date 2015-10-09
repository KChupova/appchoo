//
//  User.swift
//  
//
//  Created by Kate Chupova on 01.10.15.
//
//

import Foundation
import CoreData

@objc(User)
class User: NSManagedObject {

   // @NSManaged var isOwner: Bool
    @NSManaged var firstName: String
    @NSManaged var ahchoos: NSOrderedSet

}
