//
//  Helpers.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import Foundation
import RealmSwift
import Alamofire

let colorMappings: [String: UIColor] = ["Red": UIColor.red, "Yellow": UIColor.yellow, "Green": UIColor.green, "Blue": UIColor.blue, "Purple": UIColor.purple, "Cyan": UIColor.cyan, "Brown": UIColor.brown, "Black": UIColor.black]

/* Class that contain all the helper functions that's been used through all application*/
class Helpers {
    static let realm = try! Realm()
    
    static func DB_insert(obj: Object){
        try! self.realm.write {
            self.realm.add(obj)
        }
    }
    /// Add the hour studied to the total hours
    static func add_duration_studied(for course: Course, in quarter: Quarter) -> Float {
        var sum: Float = 0.0
        let events = self.realm.objects(Event.self).filter("course.title = '\(course.title!)' AND course.quarter.title = '\(quarter.title!)'")
        for event in events {
            sum += event.durationStudied
        }
        return sum
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
    /// Convert a string to a date and return the date
    static func get_date_from_string(strDate: String) -> Date {
        let a = strDate.components(separatedBy: " ")
        let b = a[0]+" "+a[1]+" "+a[2]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "MMM, dd yyyy"
        
        let x = formatter.date(from: b)
        
        return x!
    }
    /// Convert a date to a string and return the string
    static func get_string_from_date(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "MMM, dd yyyy"
        
        let strDate = formatter.string(from: date) + " 00:00:00"
        
        return strDate
    }
    /// Set the time to the current time
    static func set_time(mydate: Date, h: Int, m: Int) -> Date{
        let gregorian = Calendar(identifier: .gregorian)
        var components = gregorian.dateComponents([.year, .month, .day, .hour, .minute, .second], from: mydate)
        components.hour = h
        components.minute = m
        components.second = 0
        
        return gregorian.date(from: components)!
    }
    /// Get the 24 hours representation and return in as a string
    static func get_24hr_representation(from strDate: String) -> String {
        // Convert to a date.
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        let date = dateFormatter.date(from: strDate)
        
        // Convert to 24 hour format.
        dateFormatter.dateFormat = "HH:mm"
        let date24_raw = dateFormatter.string(from: date!)
        
        // Remove the colon.
        let date24_usable = date24_raw.replacingOccurrences(of: ":", with: "")
        
        return date24_usable
    }
    /// Get the Log alert for a specific event 
    static func getLogAlert(event: Event, realm: Realm) -> UIAlertController {
        let alert = UIAlertController(title: "Enter Time", message: "How much time (in hours and minutes) did you spend studying?", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
            textField.placeholder = "Hours"
            //textField.text = "\(floor(event.duration))"
        }
        
        alert.addTextField { (textField) in
            textField.keyboardType = .decimalPad
            textField.placeholder = "Minutes"
            //textField.text = "\((event.duration - floor(event.duration)) * 60)"
        }
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
            let hoursField = alert!.textFields![0]
            let minsField = alert!.textFields![1]
            
            var durationStudied: Float = 0.0
            
            if hoursField.text != "" {
                durationStudied += (Float(hoursField.text!)!)
            }
            
            if minsField.text != "" {
                durationStudied += (Float(minsField.text!)!) / 60
            }
            
            try! self.realm.write {
                event.durationStudied = durationStudied
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: nil))
        return alert
    }
    
    /// Export the generated date to the server
    static func export_data_to_server(action: String, responseHandler: @escaping (DataResponse<Any>) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        
        
        let allQuarters = realm.objects(Quarter.self)
        var quartersJSON = [Dictionary<String, Any>]()
        
        for quarter in allQuarters {
            var quarterJSON = quarter.toDictionary() as! Dictionary<String, Any>
            quarterJSON["startDate"] = formatter.string(from: quarterJSON["startDate"] as! Date)
            quarterJSON["endDate"] = formatter.string(from: quarterJSON["endDate"] as! Date)
            var coursesJSON = [[String: Any]]()
            
            
            let courses = realm.objects(Course.self).filter("quarter.title = '\(quarter.title!)'")
            
            for course in courses {
                var courseJSON = course.toDictionary() as! Dictionary<String, Any>
                courseJSON.removeValue(forKey: "quarter")
                var eventsJSON = [[String: Any]]()
                
                let events = realm.objects(Event.self).filter("course.title = '\(course.title!)'")
                
                for event in events {
                    if event.type != SCHEDULE_EVENT {
                        var eventJSON = event.toDictionary() as! Dictionary<String, Any>
                        eventJSON["date"] = formatter.string(from: eventJSON["date"] as! Date)
                        eventJSON["endDate"] = formatter.string(from: eventJSON["endDate"] as! Date)
                        eventJSON.removeValue(forKey: "course")
                        eventJSON.removeValue(forKey: "calEventID")
                        eventJSON.removeValue(forKey: "reminderDate")
                        eventJSON.removeValue(forKey: "reminderID")
                        eventJSON.removeValue(forKey: "schedule")
                        eventsJSON.append(eventJSON)
                    }
                }
                
                courseJSON["events"] = eventsJSON
                coursesJSON.append(courseJSON)
            }
            
            quarterJSON["courses"] = coursesJSON
            quartersJSON.append(quarterJSON)
        }
        
        let parameters: Parameters = ["quarters": quartersJSON]
        
        Alamofire.request("https://ibackontrack.com/\(action)?UID=\(UIDevice.init().identifierForVendor!)", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON (completionHandler: responseHandler)
    }

    /********************************* Populate the Application for Testing and Demo ******************/
    /// Populates dummy date for deguging purposes
    static func populateData()
    {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "US_en")
        dateFormatter.dateFormat = "M/d/yyyy"
        
        let dateFormatter2: DateFormatter = DateFormatter()
        dateFormatter2.locale = Locale(identifier: "US_en")
        dateFormatter2.dateStyle = .short
        dateFormatter2.timeStyle = .short
        
        //create quarters
        var quarter: Quarter?
        var start: Date
        var end: Date
        var course: Course?
        var event: Event?
        
        //add winter 17 quarter
        start = dateFormatter.date(from: "1/6/2017")!
        end = dateFormatter.date(from: "3/24/2017")!
        quarter = Quarter()
        quarter!.title = UUID().uuidString
        quarter!.startDate = start
        quarter!.endDate = end
        quarter!.current = false
        Helpers.DB_insert(obj: quarter!)
        
        //add ECS 193A to quarter
        course = Course()
        course!.title = "Senior Project Design A"
        course!.identifier = "ECS 193A"
        course!.instructor = "Xin Liu"
        course!.units = 3
        course!.quarter = quarter
        course!.color = "Red"
        
        Helpers.DB_insert(obj: course!)
        
        //add homework events for course
        for i in 1...3 {
            for j in 0...3 {
                let n: Int = ((i-1)*4) + (j+1)
                let d: Int = j*7+6
                event = Event()
                event!.title = "Do homework \(n)"
                event!.course = course
                event!.date = dateFormatter2.date(from: "\(i)/\(d)/17, 9:00 AM")
                event!.endDate = dateFormatter2.date(from: "\(i)/\(d)/17, 11:00 AM")
                event!.type = 1
                event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
                event!.durationStudied = 2.0
                event!.checked = true
                
                if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                    
                    event!.calEventID = addEventToCalendar(event: event!, toCalendar: calendarIdentifier as! String)
                }
                
                Helpers.DB_insert(obj: event!)
            }
        }
        
        
        //add project events for course
        for i in 1...3 {
            event = Event()
            event!.title = "Do project \(i)"
            event!.course = course
            event!.date = dateFormatter2.date(from: "\(i)/17/17, 9:00 AM")
            event!.endDate = dateFormatter2.date(from: "\(i)/17/17, 2:00 PM")
            event!.type = 2
            event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
            event!.durationStudied = 4.5
            event!.checked = true
            
            if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                
                event!.calEventID = addEventToCalendar(event: event!, toCalendar: calendarIdentifier as! String)
            }
            
            Helpers.DB_insert(obj: event!)
        }
        
        //add study events for course
        for i in 1...3 {
            for j in 0...2 {
                
                let d: Int = j*7+8
                event = Event()
                event!.title = "Study"
                event!.course = course
                event!.date = dateFormatter2.date(from: "\(i)/\(d)/17, 8:00 PM")
                event!.endDate = dateFormatter2.date(from: "\(i)/\(d)/17, 10:00 PM")
                event!.type = 0
                event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
                event!.durationStudied = 3.0
                event!.checked = true
                
                if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                    
                    event!.calEventID = addEventToCalendar(event: event!, toCalendar: calendarIdentifier as! String)
                }
                
                Helpers.DB_insert(obj: event!)
            }
        }
        
        //add ECS 177 to quarter
        course = Course()
        course!.title = "Scientific Visualization"
        course!.identifier = "ECS 177"
        course!.instructor = "Nelson Max"
        course!.units = 4
        course!.quarter = quarter
        course!.color = "Blue"
        Helpers.DB_insert(obj: course!)
        
        //add projects for ECS 177
        for i in 1...3 {
            for j in 0...3 {
                let n: Int = ((i-1)*4) + (j+1)
                let d: Int = j*7+7
                event = Event()
                event!.title = "Do project \(n)"
                event!.course = course
                event!.date = dateFormatter2.date(from: "\(i)/\(d)/17, 1:00 PM")
                event!.endDate = dateFormatter2.date(from: "\(i)/\(d)/17, 4:00 PM")
                event!.type = 2
                event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
                event!.durationStudied = 3.0
                event!.checked = true
                
                if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                    
                    event!.calEventID = addEventToCalendar(event: event!, toCalendar: calendarIdentifier as! String)
                }
                
                Helpers.DB_insert(obj: event!)
            }
        }
        
        //add study event for ECS 177
        for i in 1...3 {
            for j in 0...2 {
                
                let d: Int = j*7+10
                event = Event()
                event!.title = "Study"
                event!.course = course
                event!.date = dateFormatter2.date(from: "\(i)/\(d)/17, 8:00 PM")
                event!.endDate = dateFormatter2.date(from: "\(i)/\(d)/17, 10:00 PM")
                event!.type = 0
                event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
                event!.durationStudied = 3.0
                event!.checked = true
                
                if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                    
                    event!.calEventID = addEventToCalendar(event: event!, toCalendar: calendarIdentifier as! String)
                }
                
                Helpers.DB_insert(obj: event!)
            }
        }
        
        //add spring 17 quarter
        start = dateFormatter.date(from: "3/30/2017")!
        end = dateFormatter.date(from: "6/15/2017")!
        quarter = Quarter()
        quarter!.title = UUID().uuidString
        quarter!.startDate = start
        quarter!.endDate = end
        quarter!.current = false
        Helpers.DB_insert(obj: quarter!)
        
        //add ECS 193B to quarter
        course = Course()
        course!.title = "Senior Project Design B"
        course!.identifier = "ECS 193B"
        course!.instructor = "Xin Liu"
        course!.quarter = quarter
        course!.units = 3
        course!.color = "Red"
        
        Helpers.DB_insert(obj: course!)
        
        //add Project events for ECS 193B
        for i in 4...6 {
            for j in 0...2 {
                let n: Int = ((i-4)*4) + (j+1)
                let d: Int = j*7+1
                event = Event()
                event!.title = "Do project \(n)"
                event!.course = course
                event!.date = dateFormatter2.date(from: "\(i)/\(d)/17, 1:00 PM")
                event!.endDate = dateFormatter2.date(from: "\(i)/\(d)/17, 6:00 PM")
                event!.type = 2
                event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
                event!.durationStudied = 4.5
                event!.checked = true
                
                if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                    
                    event!.calEventID = addEventToCalendar(event: event!, toCalendar: calendarIdentifier as! String)
                }
                
                Helpers.DB_insert(obj: event!)
            }
        }
        
        //add study events for ECS 193B
        for i in 4...5 {
            for j in 0...4 {
                
                let d: Int = j*7+1
                event = Event()
                event!.title = "Study"
                event!.course = course
                event!.date = dateFormatter2.date(from: "\(i)/\(d)/17, 8:00 PM")
                event!.endDate = dateFormatter2.date(from: "\(i)/\(d)/17, 10:00 PM")
                event!.type = 0
                event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
                event!.durationStudied = 3.0
                event!.checked = true
                
                if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                    
                    event!.calEventID = addEventToCalendar(event: event!, toCalendar: calendarIdentifier as! String)
                }
                
                Helpers.DB_insert(obj: event!)
            }
        }
        
        //add ECS 150 to quarter
        course = Course()
        course!.title = "Operating System"
        course!.identifier = "ECS 150"
        course!.instructor = "Chrisopher Nitta"
        course!.quarter = quarter
        course!.units = 4
        course!.color = "Blue"
        
        //add Project events for ECS 150
        for i in 4...6 {
            for j in 0...2 {
                let n: Int = ((i-4)*4) + (j+1)
                let d: Int = j*7+2
                event = Event()
                event!.title = "Do project \(n)"
                event!.course = course
                event!.date = dateFormatter2.date(from: "\(i)/\(d)/17, 2:00 PM")
                event!.endDate = dateFormatter2.date(from: "\(i)/\(d)/17, 6:00 PM")
                event!.type = 2
                event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
                event!.durationStudied = 4.0
                event!.checked = true
                
                if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                    
                    event!.calEventID = addEventToCalendar(event: event!, toCalendar: calendarIdentifier as! String)
                }
                
                Helpers.DB_insert(obj: event!)
            }
        }
        
        //add study events for ECS 193B
        for i in 4...5 {
            for j in 1...4 {
                
                let d: Int = j*7-1
                event = Event()
                event!.title = "Study"
                event!.course = course
                event!.date = dateFormatter2.date(from: "\(i)/\(d)/17, 8:00 PM")
                event!.endDate = dateFormatter2.date(from: "\(i)/\(d)/17, 10:00 PM")
                event!.type = 0
                event!.duration = Date.getDifference(initial: event!.date, final: event!.endDate)
                event!.durationStudied = 3.0
                event!.checked = true
                
                if let calendarIdentifier = UserDefaults.standard.value(forKey: calendarKey) {
                    
                    event!.calEventID = addEventToCalendar(event: event!, toCalendar: calendarIdentifier as! String)
                }
                
                Helpers.DB_insert(obj: event!)
            }
        }
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

extension UITableViewController {
    //change texfield to red to alert user with missing or incorrect information.
    func changeTextFieldToRed(indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)!.backgroundColor = UIColor.init(red: 0.94, green: 0.638, blue: 0.638, alpha: 1.0)
    }
    
    //change texfield to white to indicate correct input.
    func changeTextFieldToWhite(indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)!.backgroundColor = UIColor.white
    }
}

extension Dictionary where Value: Equatable {
    func key(forValue value: Value) -> Key? {
        return first { $0.1 == value }?.0
    }
}
