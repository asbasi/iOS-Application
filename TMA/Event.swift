//
//  Event.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift


class Event: Item {
    dynamic var checked: Bool = false
    dynamic var id: String!
    dynamic var reminderDate: Date? = nil
}
