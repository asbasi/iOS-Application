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

class Helpers {
    static let realm = try! Realm()
    
    static func DB_insert(obj: Object){
        try! self.realm.write {
            self.realm.add(obj)
        }
    }
    
    static func add_duration(events: Results<Event>) -> Float{
        var sum: Float = 0.0
        for x in events {
            sum += x.duration
        }
        return sum
    }
    
    static func add_duration_studied(events: Results<Event>) -> Float{
        var sum: Float = 0.0
        for x in events {
            sum += x.durationStudied
        }
        return sum
    }
    
    static func get_date_from_string(strDate: String) -> Date {
        let formatter = DateFormatter()
        
        let a = strDate.components(separatedBy: " ")
        let b = a[0]+" "+a[1]+" "+a[2]
        
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "MMM, dd yyyy"
        
        let x = formatter.date(from: b)
        return x!
    }
    
    static func set_time(mydate: Date, h: Int, m: Int) -> Date{
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: mydate)
        components.hour = h
        components.minute = m
        components.second = 0
        
        return gregorian.date(from: components)!
    }
    
    static func getLogAlert(event: Event, realm: Realm) -> UIAlertController {
        let alert = UIAlertController(title: "Enter Time", message: "How much time (as a decimal number) did you spend studying?", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
            textField.text = "\(event.duration * 60)"
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
            
            if textField.text != "" {
                try! self.realm.write {
                    event.durationStudied = (Float(textField.text!)!) / 60
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: nil))
        return alert
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

extension Object {
    func toDictionary() -> NSDictionary {
        let properties = self.objectSchema.properties.map { $0.name }
        let dictionary = self.dictionaryWithValues(forKeys: properties)
        let mutabledic = NSMutableDictionary()
        mutabledic.setValuesForKeys(dictionary)
        
        for prop in self.objectSchema.properties as [Property]! {
            // find lists
            if let nestedObject = self[prop.name] as? Object {
                mutabledic.setValue(nestedObject.toDictionary(), forKey: prop.name)
            } else if let nestedListObject = self[prop.name] as? ListBase {
                var objects = [AnyObject]()
                for index in 0..<nestedListObject._rlmArray.count  {
                    let object = nestedListObject._rlmArray[index] as AnyObject
                    objects.append(object.toDictionary())
                }
                mutabledic.setObject(objects, forKey: prop.name as NSCopying)
            }
        }
        return mutabledic
    }
}
