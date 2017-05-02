//
//  Helpers.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift


let colorMappings: [String: UIColor] = ["None": UIColor.clear, "Red": UIColor.red, "Green": UIColor.green, "Blue": UIColor.blue]

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
        dateFormatter.dateFormat = "E"
        return dateFormatter.string(from: self)
    }
    
    func dayOfTheMonth() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }
    
    static func getEndDate(fromStart start: Date, withDuration duration: Float) -> Date{
        var components = DateComponents()
        components.setValue(Int(duration), for: .hour)
        components.setValue(Int(round(60 * (duration - floor(duration)))), for: .minute)
        return Calendar.current.date(byAdding: components, to: start)!
    }
    
    static func getDifference(initial start: Date, final end: Date) -> Float {
        let interval = end.timeIntervalSince(start) // In seconds. Note: TimeInterval = double
        
        // Convert seconds to hours.
        return (Float(interval / (60.0 * 60.0)))
    }
    
    func daysBetween(date: Date) -> Int {
        return Date.daysBetween(start: self, end: date)
    }
    
    static func daysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        
        // Replace the hour (time) of both dates with 00:00
        let date1 = calendar.startOfDay(for: start)
        let date2 = calendar.startOfDay(for: end)
        
        let a = calendar.dateComponents([.day], from: date1, to: date2)
        return a.value(for: .day)!
    }
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
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setTheme(theme: Theme) {
        self.navigationController!.navigationBar.barTintColor = theme.barColor
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: theme.tintColor]
        self.navigationController!.navigationBar.tintColor = theme.tintColor
        
        self.tabBarController!.tabBar.barTintColor = theme.barColor
        self.tabBarController!.tabBar.tintColor = theme.tintColor
    }
}

