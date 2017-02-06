//
//  Helpers.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

class Helpers{
    static let realm = try! Realm()
    
    static func DB_insert(obj: Object){
        try! self.realm.write {
            
        }
    }
}
