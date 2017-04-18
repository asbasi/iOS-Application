//
//  TimeBlock.swift
//  TMA
//
//  Created by Arvinder Basi on 4/17/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation

struct TimeBlock {
    let start: Date
    let end: Date
    var allocated: Bool
    
    init(start: Date, end: Date, allocated: Bool) {
        self.start = start
        self.end = end
        self.allocated = allocated
    }
}

extension TimeBlock: Equatable {}

func ==(lhs: TimeBlock, rhs: TimeBlock) -> Bool {
    let areEqual = (lhs.start == rhs.start && lhs.end == rhs.end && lhs.allocated == rhs.allocated)
    
    return areEqual
}
