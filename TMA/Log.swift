//
//  Log.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

class Log: Item {
    static func add(event: Event, duration: Float, realm: Realm) {
        let log = Log()
        
        log.title = event.title
        log.duration = duration
        log.date = event.date
        log.endDate = event.endDate
        log.course = event.course
        log.type = event.type
        
        Helpers.DB_insert(obj: log)
        
        try! realm.write {
            event.log = log
        }
    }
}
