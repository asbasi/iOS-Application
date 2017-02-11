//
//  Item.swift
//  TMA
//
//  Created by Arvinder Basi on 2/10/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    dynamic var title: String!
    dynamic var date: NSDate!
    dynamic var course: Course!
    dynamic var duration: Float = 0 //hours
}
