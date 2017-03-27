//
//  Event.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

let STUDY_EVENT = 0
let HOMEWORK_EVENT = 1
let PROJECT_EVENT = 2
let LAB_EVENT = 3
let OTHER_EVENT = 4

class Event: Item {
    dynamic var checked: Bool = false
    dynamic var id: String!
    dynamic var type: Int = OTHER_EVENT 
    dynamic var reminderDate: Date? = nil
}
