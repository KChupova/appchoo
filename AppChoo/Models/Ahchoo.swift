//
//  Ahchoo.swift
//  
//
//  Created by Kate Chupova on 01.10.15.
//
//

import Foundation
import CoreData

@objc(Ahchoo)
class Ahchoo: NSManagedObject {
    
    @NSManaged var date: NSDate
    @NSManaged var intensity: NSNumber
    @NSManaged var user: NSManagedObject

}
