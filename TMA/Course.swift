//
//  Course.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

class Course: Object {
    dynamic var name: String!
    dynamic var instructor: String!
    dynamic var units: Int = 0
    dynamic var quarter: String!
    dynamic var numberOfHoursLogged : Float = 0
    dynamic var numberOfHoursAllocated : Float = 0
    
//    override class func primaryKey() -> String? {
//        return "name"
//    }
    
    func get_number_of_hours_logged() -> Float{
        return numberOfHoursLogged
    }
    
    func get_number_of_hours_allocated() -> Float{
        return numberOfHoursAllocated
    }
    
    func get_number_of_hours_logged(from: NSDate, to: NSDate) -> Float{
        return 10
    }
    
    func get_number_of_hours_allocated(from: NSDate, to: NSDate) -> Float{
        return 10
    }
    
    
    // Specify properties to ignore (Realm won't persist these)
    override static func ignoredProperties() -> [String] {
        return []
    }
}
