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
}

