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

let colorMappings: [String: UIColor] = ["None": UIColor.clear, "Yellow": UIColor.yellow, "Red": UIColor.red, "Green": UIColor.green, "Blue": UIColor.blue, "Purple": UIColor.purple, "Cyan": UIColor.cyan, "Brown": UIColor.brown, "Black": UIColor.black]

class Helpers {
    static let realm = try! Realm()
    
    static func DB_insert(obj: Object){
        try! self.realm.write {
            self.realm.add(obj)
        }
    }
    
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
                    var eventJSON = event.toDictionary() as! Dictionary<String, Any>
                    eventJSON["date"] = formatter.string(from: eventJSON["date"] as! Date)
                    eventJSON["endDate"] = formatter.string(from: eventJSON["endDate"] as! Date)
                    eventJSON.removeValue(forKey: "course")
                    eventJSON.removeValue(forKey: "calEventID")
                    eventJSON.removeValue(forKey: "reminderDate")
                    eventJSON.removeValue(forKey: "reminderID")
                    eventsJSON.append(eventJSON)
                }
                
                courseJSON["events"] = eventsJSON
                coursesJSON.append(courseJSON)
            }
            
            quarterJSON["courses"] = coursesJSON
            quartersJSON.append(quarterJSON)
        }
        
        let parameters: Parameters = ["quarters": quartersJSON]
        
        Alamofire.request("http://192.241.206.161/\(action)?UID=\(UIDevice.init().identifierForVendor!)", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseJSON (completionHandler: responseHandler)
    }
    
    
    /********************************* Populate the Class Schedule into the Application and Calendar. ******************/
    private static func getWeekDaysInEnglish() -> [String] {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        return calendar.weekdaySymbols
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarOptions: NSCalendar.Options {
            switch self {
            case .Next:
                return .matchNextTime
            case .Previous:
                return [.searchBackwards, .matchNextTime]
            }
        }
    }
    
    private static func getDay(direction: SearchDirection, dayName: String, fromDate: Date) -> NSDate {
        let weekdaysName = Helpers.getWeekDaysInEnglish()
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let nextWeekDayIndex = weekdaysName.index(of: dayName)! + 1 // weekday is in form 1 ... 7 where as index is 0 ... 6
        
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        
        
        let date = calendar.nextDate(after: fromDate, matching: nextDateComponent as DateComponents, options: direction.calendarOptions)
        return date! as NSDate
    }
    
    static func exportSchedule(schedule: Schedule) {
        do {
            let decoded = try JSONSerialization.jsonObject(with: schedule.dates, options: [])
            
            if let dictFromJSON = decoded as? [String: NSObject] {
                
                if (dictFromJSON["week_days"] as! String) == "" {
                    return
                }
                
                let week_days = (dictFromJSON["week_days"] as! String).components(separatedBy: ",")

                let week_days_translation = ["M": "Monday", "T": "Tuesday", "W": "Wednesday", "R": "Thursday", "F": "Friday", "S": "Saturday"]
                for week_day in week_days {
                    
                    ////////////////////////////////////////////////////////////////////////
                    ///////////////////just parsing the begin_time and end_time/////////////
                    ///////////////////into 2 ints each hrs & min///////////////////////////
                    ////////////////////////////////////////////////////////////////////////
                    
                    
                    let s_t = (dictFromJSON["begin_time"] as! String).characters
                    let e_t = (dictFromJSON["end_time"] as! String).characters
                    let sh = String(Array(s_t)[0])+String(Array(s_t)[1])
                    let sm = String(Array(s_t)[2])+String(Array(s_t)[3])
                    let eh = String(Array(e_t)[0])+String(Array(e_t)[1])
                    let em = String(Array(e_t)[2])+String(Array(e_t)[3])
                    
                    let ish = Int(sh)! //integer start hour
                    let ism = Int(sm)! //integer start minute
                    let ieh = Int(eh)! //integer end hour
                    let iem = Int(em)! //integer end minute
                    ///////////////////////////////////////////////////
                    
                    let currentClassStartDate = Helpers.get_date_from_string(strDate: dictFromJSON["start_date"]! as! String)
                    let currentClassEndDate = Helpers.get_date_from_string(strDate: dictFromJSON["end_date"]! as! String)
                    
                    var the_date = currentClassStartDate
                    the_date = Calendar.current.date(byAdding: .day, value: -1, to: the_date)!
                    //subtract 1 day because self.get() starts from the day after
                    while the_date <= currentClassEndDate {
                        the_date = Helpers.getDay(direction: .Next, dayName: week_days_translation[week_day]!, fromDate: the_date) as Date
                        
                        if(the_date > currentClassEndDate){
                            break;
                        }
                        
                        the_date = Helpers.set_time(mydate: the_date as Date, h: ish, m: ism)
                        
                        // add to realm
                        let ev = Event()
                        ev.title = schedule.title
                        ev.date = the_date
                        ev.endDate = Helpers.set_time(mydate: the_date as Date, h: ieh, m: iem)
                        ev.course = schedule.course
                        ev.duration = Date.getDifference(initial: ev.date, final: ev.endDate)
                        ev.type = SCHEDULE_EVENT
                        ev.reminderID = UUID().uuidString
                        
                        Helpers.DB_insert(obj: ev)
                        
                        //increment 1 day so we dont get the same date next time
                        the_date = Calendar.current.date(byAdding: .day, value: 1, to: the_date)!
                    }
                    
                    checkCalendarAuthorizationStatus()
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    

    /********************************* Populate the Application for Testing and Demo ******************/
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
        quarter!.title = "Winter 2017"
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
                
                event!.reminderID = UUID().uuidString
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
            
            event!.reminderID = UUID().uuidString
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
                
                event!.reminderID = UUID().uuidString
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
                
                event!.reminderID = UUID().uuidString
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
                
                event!.reminderID = UUID().uuidString
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
        quarter!.title = "Spring 2017"
        quarter!.startDate = start
        quarter!.endDate = end
        quarter!.current = true
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
                
                event!.reminderID = UUID().uuidString
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
                
                event!.reminderID = UUID().uuidString
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
                
                event!.reminderID = UUID().uuidString
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
                
                event!.reminderID = UUID().uuidString
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
