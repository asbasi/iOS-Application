//
//  Quarter.swift
//  TMA
//
//  Created by Arvinder Basi on 3/28/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

/* Class contain all the variables related to a quarter.*/
class Quarter: Object {
    dynamic var title: String!
    dynamic var startDate: Date!
    dynamic var endDate: Date!
    dynamic var current: Bool = false
    
    func delete(from realm: Realm) {
        let courses = realm.objects(Course.self).filter("quarter.title = '\(self.title!)'")
        
        for course in courses {
            course.delete(from: realm)
        }
        
        try! realm.write {
            realm.delete(self)
        }
    }
}

