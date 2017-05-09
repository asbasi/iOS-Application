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
    dynamic var title: String!
    dynamic var identifier: String!
    dynamic var instructor: String!
    dynamic var units: Float = 0
    dynamic var quarter: Quarter!
    dynamic var color: String!
    
    // Specify properties to ignore (Realm won't persist these)
    override static func ignoredProperties() -> [String] {
        return []
    }
    
    func delete(realm: Realm) {
        try! realm.write {
            let eventsToDelete = realm.objects(Event.self).filter("course.identifier = '\(self.identifier!)'")
            realm.delete(eventsToDelete)
            
            let goalsToDelete = realm.objects(Goal.self).filter("course.identifier = '\(self.identifier!)'")
            realm.delete(goalsToDelete)
            
            realm.delete(self)
        }
    }
}
