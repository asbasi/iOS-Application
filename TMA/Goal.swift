//
//  Goal.swift
//  TMA
//
//  Created by Milad Ghoreishi on 4/10/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

class Goal: Object {
    dynamic var title: String!
    dynamic var type: Int = OTHER_EVENT
    dynamic var deadline: Date!
    dynamic var course: Course!
    dynamic var duration: Float = 0.0
}
