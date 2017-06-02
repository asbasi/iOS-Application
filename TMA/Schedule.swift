//
//  Schedule.swift
//  TMA
//
//  Created by Arvinder Basi on 5/26/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import RealmSwift

class Schedule: Object{
    dynamic var title: String!
    dynamic var dates: Data! // Json encoded string representing the [String: NSObject] dictionary of dates.
    dynamic var course: Course!
    dynamic var scheduleID: String = UUID().uuidString
    
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
        let weekdaysName = getWeekDaysInEnglish()
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let nextWeekDayIndex = weekdaysName.index(of: dayName)! + 1 // weekday is in form 1 ... 7 where as index is 0 ... 6
        
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        
        
        let date = calendar.nextDate(after: fromDate, matching: nextDateComponent as DateComponents, options: direction.calendarOptions)
        return date! as NSDate
    }
    
    static func parseTime(from string: String) -> (hour: Int, min: Int) {
        
        ////////////////////////////////////////////////////////////////////////
        ///////////////////just parsing the begin_time and end_time/////////////
        ///////////////////into 2 ints each hrs & min///////////////////////////
        ////////////////////////////////////////////////////////////////////////
        
        let s_date = string.characters
        let sh = String(Array(s_date)[0])+String(Array(s_date)[1])
        let sm = String(Array(s_date)[2])+String(Array(s_date)[3])
        
        return (Int(sh)!, Int(sm)!)
    }
    
    func export() {
        do {
            let decoded = try JSONSerialization.jsonObject(with: self.dates, options: [])
            
            if let dictFromJSON = decoded as? [String: NSObject] {
                
                if (dictFromJSON["week_days"] as! String) == "" {
                    return
                }
                
                let week_days = (dictFromJSON["week_days"] as! String).components(separatedBy: ",")
                
                let week_days_translation = ["M": "Monday", "T": "Tuesday", "W": "Wednesday", "R": "Thursday", "F": "Friday", "S": "Saturday"]
                for week_day in week_days {
                    
                    let start_time = Schedule.parseTime(from: dictFromJSON["begin_time"] as! String)
                    let end_time = Schedule.parseTime(from: dictFromJSON["end_time"] as! String)
                    
                    let currentClassStartDate = Helpers.get_date_from_string(strDate: dictFromJSON["start_date"]! as! String)
                    let currentClassEndDate = Helpers.get_date_from_string(strDate: dictFromJSON["end_date"]! as! String)
                    
                    var the_date = currentClassStartDate
                    the_date = Calendar.current.date(byAdding: .day, value: -1, to: the_date)!
                    //subtract 1 day because self.get() starts from the day after
                    while the_date <= currentClassEndDate {
                        the_date = Schedule.getDay(direction: .Next, dayName: week_days_translation[week_day]!, fromDate: the_date) as Date
                        
                        if(the_date > currentClassEndDate){
                            break;
                        }
                        
                        the_date = Helpers.set_time(mydate: the_date as Date, h: start_time.hour, m: start_time.min)
                        
                        // add to realm
                        let ev = Event()
                        ev.title = self.title
                        ev.date = the_date
                        ev.endDate = Helpers.set_time(mydate: the_date as Date, h: end_time.hour, m: end_time.min)
                        ev.course = self.course
                        ev.duration = Date.getDifference(initial: ev.date, final: ev.endDate)
                        ev.type = SCHEDULE_EVENT
                        ev.reminderID = UUID().uuidString
                        ev.schedule = self
                        
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
    
    private func deleteEvents(from realm: Realm) {
        // Get all schedule related events for the course.
        let allEventsForCourse = realm.objects(Event.self).filter("type = \(SCHEDULE_EVENT) AND course.identifier = '\(self.course.identifier!)' AND course.quarter.title = '\(self.course.quarter.title!)'")
        
        // Parse out the events related to this particular schedule.
        for event in allEventsForCourse {
            if event.schedule!.scheduleID == self.scheduleID {
                event.delete(from: realm)
            }
        }
    }
    
    func delete(from realm: Realm) {
        self.deleteEvents(from: realm)
        
        try! realm.write {
            realm.delete(self)
        }
    }
    
    func refresh(in realm: Realm) {
        self.deleteEvents(from: realm)
        self.export()
    }
}
