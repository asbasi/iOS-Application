//
//  Log.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation

class Log: Event{
    var duration: Int!
    
    init(title: String, duration: Int) {
        super.init(title: title)
        self.duration=duration
    }
}
