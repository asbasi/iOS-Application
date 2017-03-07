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
            self.realm.add(obj)
        }
    }
    
    static func add_duration(events: Results<Event>) -> Float{
        var sum: Float = 0
        for x in events {
            sum += x.duration
        }
        return sum
    }
    
    static func add_duration(events: Results<Log>) -> Float{
        var sum: Float = 0
        for x in events {
            sum += x.duration
        }
        return sum
    }
}


extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    func dayOfTheWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self)
    }
}

func setGradientBackground(view: UIView, colorTop: UIColor, colorBottom: UIColor) {
    
    let gradientLayer = CAGradientLayer()
    gradientLayer.colors = [ colorTop.cgColor, colorBottom.cgColor]
    gradientLayer.locations = [ 0.0, 1.0]
    gradientLayer.frame = view.bounds
    
    view.layer.insertSublayer(gradientLayer, at: 0)
}

extension UIViewController {
    // Makes it so any keyboard/numpad currently active disappears when user clicks away.
    func hideKeyboardWhenTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
