//
//  Schedule.swift
//  TMA
//
//  Created by Arvinder Basi on 5/26/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

class Schedule: Object{
    dynamic var title: String!
    dynamic var dates: Data! // Json encoded string representing the [String: NSObject] dictionary of dates.
    dynamic var course: Course!
}
