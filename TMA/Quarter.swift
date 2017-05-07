//
//  Quarter.swift
//  TMA
//
//  Created by Arvinder Basi on 3/28/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

class Quarter: Object {
    dynamic var title: String!
    dynamic var startDate: Date!
    dynamic var endDate: Date!
    dynamic var current: Bool = false
    
    func delete(realm: Realm) {
        let courses = realm.objects(Course.self).filter("quarter.title = '\(self.title!)'")
        
        for course in courses {
            course.delete(realm: realm)
        }
        
        try! realm.write {
            realm.delete(self)
        }
    }
}

