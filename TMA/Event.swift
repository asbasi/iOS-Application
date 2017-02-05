//
//  Event.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

class Event: Object {
    dynamic var checked = false
    dynamic var title: String!
    dynamic var date: NSDate!
    
//    init(title: String, date: NSDate) {
//        super.init()
//        self.title=title
//        self.date=date
//    }
    
}
