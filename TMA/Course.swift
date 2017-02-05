//
//  Course.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/1/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation

class Course {
    var id: Int! //TODO: manage that with the DB
    var name: String!
    var instructor: String!
    var units: Int!
    var quarter: String!
    
    
    
    init(name: String, instructor: String, units: Int, quarter: String) {
        self.name = name
        self.instructor = instructor
        self.units = units
        self.quarter = quarter
        self.id = Helpers.generateRandomNumber(min: 0, max: 10000000)
    }
}
