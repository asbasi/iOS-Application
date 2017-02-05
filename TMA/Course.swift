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
    
    dynamic var id: Int = 0 //TODO: manage that with the DB
    dynamic var name: String!
    dynamic var instructor: String!
    dynamic var units: Int = 0
    dynamic var quarter: String!
    let logs = List<Log>()
    let studyEvents = List<StudyEvent>()
    let deadlines = List<Deadline>()
    dynamic var numberOfHoursLogged : Float = 0
    dynamic var numberOfHoursAllocated : Float = 0
    
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
    
//    init(name: String, instructor: String, units: Int, quarter: String) {
//        super.init()
//        self.name = name
//        self.instructor = instructor
//        self.units = units
//        self.quarter = quarter
//        self.id = Helpers.generateRandomNumber(min: 0, max: 10000000)
//    }
    
    
    
    
    // Specify properties to ignore (Realm won't persist these)
    override static func ignoredProperties() -> [String] {
        return []
    }
}
