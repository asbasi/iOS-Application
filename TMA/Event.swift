//
//  Event.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation

class Event {
    var checked: Bool!
    var title: String!
    
    init(title: String) {
        self.checked=false
        self.title=title
    }
}
