//
//  Course.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift
import UserNotifications

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
    
    func delete(from realm: Realm) {
        // NOTE: We include the course.quarter.title = ... in order to handle duplicate courses in different quarters.
        let eventsToDelete = realm.objects(Event.self).filter(NSPredicate(format: "course.identifier == %@ AND course.quarter.title == %@", self.identifier!, self.quarter.title!))
        
        for event in eventsToDelete {
            event.delete(from: realm)
        }
        let schedulesToDelete = realm.objects(Schedule.self).filter(NSPredicate(format: "course.quarter.title == %@ AND course.identifier == %@", self.quarter.title!, self.identifier!))
        
        for schedule in schedulesToDelete {
            schedule.delete(from: realm)
        }

        try! realm.write {
            realm.delete(self)
        }
    }
}
