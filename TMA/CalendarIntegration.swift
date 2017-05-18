//
//  CalendarIntegration.swift
//  TMA
//
//  Created by Arvinder Basi on 4/11/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import EventKit
import RealmSwift
import UIKit

let realm = try! Realm()
let eventStore = EKEventStore()

func checkCalendarAuthorizationStatus() {
    let status = EKEventStore.authorizationStatus(for: .event)
    
    switch(status) {
    case EKAuthorizationStatus.notDetermined:
        verifyCalendar()
        exportEvents(toCalendar: (getMainCalendar()?.calendarIdentifier)!)
        sync()
    case EKAuthorizationStatus.authorized:
        print("Access Granted")
        verifyCalendar()
        exportEvents(toCalendar: getMainCalendar()!.calendarIdentifier)
        sync()
    case EKAuthorizationStatus.denied:
        print("Access Denied")
    default:
        print("Case Default")
    }
}

// Checks if the calendar exists and, if not, create one (if possible).
func verifyCalendar() {
    // Calendar identifier exists in user defaults.
    if let identifier = UserDefaults.standard.value(forKey: calendarKey)
    {
        // Calendar no longer exists in the iOS Calendar (i.e. user deleted it).
        if getCalendar(withIdentifier: identifier as! String) == nil
        {
            if let calendar = createCalendar(withTitle: "Back On Track Application") {
                exportEvents(toCalendar: calendar)
            }
        }
    }
    // Calendar was never created so create the calendar.
    else
    {
        if let calendar = createCalendar(withTitle: "Back On Track Application") {
            exportEvents(toCalendar: calendar)
        }
    }
}

// Removes any events that have exist in the BoT Calendar, but not in-app.
func sync() {
    if let calendar = getMainCalendar() {

        var components = DateComponents()
        components.year = -1
        let startDate = Calendar.current.date(byAdding: components, to: Date())
        
        components.year = 1
        let endDate = Calendar.current.date(byAdding: components, to: Date())
        
        let eventsPredicate = eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: [calendar])
        
        let events = eventStore.events(matching: eventsPredicate)
        
        for event in events {
            if(realm.objects(Event.self).filter("calEventID = '\(event.eventIdentifier)'").count == 0) { // Doesn't exist in-app.
                do {
                    try eventStore.remove(event, span: .thisEvent, commit: true)
                }
                catch {
                    let alert = UIAlertController(title: "Event could not be deleted from calendar", message: (error as Error).localizedDescription, preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alert.addAction(OKAction)
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

func exportEvents(toCalendar calendar: String)
{
    let events = realm.objects(Event.self)
    
    for event in events {
        if let identifier = event.calEventID { // Event was initially added to calendar.
            
            // Event exists.
            if let _ = eventStore.event(withIdentifier: identifier) {
                editEventInCalendar(event: event, toCalendar: calendar) // Restore the event to what it was in-app.
            }
            else { // Event was deleted from calendar.
                try! realm.write {
                    realm.delete(event)
                }
            }
        }
        else {
            let calEventID = addEventToCalendar(event: event, toCalendar: calendar)
            try! realm.write {
                event.calEventID = calEventID
            }
        }
    }
}


func importEvents(for date: Date) -> [Event] {
    var events: [Event] = []
    
    if EKEventStore.authorizationStatus(for: .event) == EKAuthorizationStatus.authorized {
        let calendars = eventStore.calendars(for: .event)
        let calEvents = getCalendarEvents(forDate: date, fromCalendars: calendars)
        
        // Filter out the events that are already stored in-app.
        for calEvent in calEvents {
            if(realm.objects(Event.self).filter("calEventID == '\(calEvent.eventIdentifier)'").count == 0) {
                
                let event: Event = Event()
                
                event.title = calEvent.title
                event.type = CALENDAR_EVENT
                event.date = calEvent.startDate
                event.endDate = calEvent.endDate
                event.duration = Date.getDifference(initial: calEvent.startDate, final: calEvent.endDate)
                
                events.append(event)
            }
        }
    }
    return events
}


func requestAccessToCalendar() {
    eventStore.requestAccess(to: .event, completion:
        { (granted, error) in
            if granted {
                print("Access to calendar store granted")
            }
            else {
                print("Access to calendar store not granted")
            }
    })
}

func getMainCalendar() -> EKCalendar? {
    if let identifier = UserDefaults.standard.value(forKey: calendarKey) {
        return eventStore.calendar(withIdentifier: identifier as! String)
    }
    return nil
}

func getCalendar(withIdentifier identifier: String) -> EKCalendar? {
    return eventStore.calendar(withIdentifier: identifier)
}

func createCalendar(withTitle title: String) -> String? {
    var identifier: String?
    
    // Create a local calendar.
    let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
    
    newCalendar.title = title
    
    let sourcesInEventStore = eventStore.sources
    
    var foundSource: Bool = false
    
    // If iCloud is configured use that as the source.
    for source in sourcesInEventStore {
        if(source.sourceType == EKSourceType.calDAV && source.title == "iCloud") {
            newCalendar.source = source
            foundSource = true
        }
    }
    
    if(!foundSource) {
        for source in sourcesInEventStore {
            if(source.sourceType == EKSourceType.subscribed) {
                newCalendar.source = source
                foundSource = true
            }
        }
    }
    
    // Otherwise use the local source.
    if(!foundSource) {
        for source in sourcesInEventStore {
            if(source.sourceType == EKSourceType.local) {
                newCalendar.source = source
            }
        }
    }
    
    do {
        try eventStore.saveCalendar(newCalendar, commit: true)
        UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: calendarKey);
        
        identifier = newCalendar.calendarIdentifier

    }
    catch {
        let alert = UIAlertController(title: "Calendar could not save", message: (error as Error).localizedDescription, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(OKAction)
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    return identifier
}

func addEventToCalendar(event: Event, toCalendar calendarIdentifier: String) -> String? {
    
    if EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized {
        return nil
    }
    
    var identifier: String?
    
    if let calendarForEvent = eventStore.calendar(withIdentifier: calendarIdentifier) {
        
        // Create the calendar event.
        let newEvent = EKEvent(eventStore: eventStore)
        
        newEvent.calendar = calendarForEvent
        
        newEvent.title = "\(event.title!) (\(event.course.title!))"
        
        newEvent.startDate = event.date
        
        var components = DateComponents()
        components.setValue(Int(event.duration), for: .hour)
        components.setValue(Int(round(60 * (event.duration - floor(event.duration)))), for: .minute)
        newEvent.endDate = Calendar.current.date(byAdding: components, to: event.date)!
        
        // Save the event in the calendar.
        do {
            try eventStore.save(newEvent, span: .thisEvent, commit: true)
            identifier = newEvent.eventIdentifier
        }
        catch {
            let alert = UIAlertController(title: "Event could not save", message: (error as Error).localizedDescription, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    return identifier
}

func editEventInCalendar(event: Event, toCalendar calendarIdentifier: String) {
    
    if let identifier = event.calEventID {
        if let calEvent = eventStore.event(withIdentifier: identifier) {
            calEvent.title = "\(event.title!) (\(event.course.title!))"
            calEvent.startDate = event.date
            
            calEvent.endDate = Date.getEndDate(fromStart: event.date, withDuration: event.duration)

            do {
                try eventStore.save(calEvent, span: .thisEvent, commit: true)
            }
            catch {
                let alert = UIAlertController(title: "Event could not edited", message: (error as Error).localizedDescription, preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alert.addAction(OKAction)
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            }
        }
        else {
            // Event with identifier doesn't exist so make it.
            try! realm.write {
                event.calEventID = addEventToCalendar(event: event, toCalendar: calendarIdentifier)
            }
        }
    }
}

func deleteEventFromCalendar(withID eventID: String) {
    
    eventStore.requestAccess(to: .event, completion:
        { (granted, error) in
            if granted {
                
                if let calEvent = eventStore.event(withIdentifier: eventID) {
                    do {
                        try eventStore.remove(calEvent, span: .thisEvent, commit: true)
                    }
                    catch {
                        let alert = UIAlertController(title: "Event could not be deleted from calendar", message: (error as Error).localizedDescription, preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(OKAction)
                        
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
    })
}


func getCalendarEvents(forDate date: Date, fromCalendars calendars: [EKCalendar]?) -> [EKEvent] {
    
    var events: [EKEvent] = []
    var flag: Bool = false
    
    eventStore.requestAccess(to: .event, completion:
        { (granted, error) in
            if granted {
                
                let startDate = Calendar.current.startOfDay(for: date)
                
                var dateComponents = DateComponents()
                dateComponents.day = 1
                let endDate = Calendar.current.date(byAdding: dateComponents, to: startDate)
                
                //let calendars = eventStore.calendars(for: .event)
                
                let eventsPredicate = eventStore.predicateForEvents(withStart: startDate, end: endDate!, calendars: calendars)
                
                events = eventStore.events(matching: eventsPredicate)
                
                flag = true
            }
    })
    
    while(!flag) {
    }
    
    return events
}

func findFreeTimes(onDate date: Date, withEvents events: [EKEvent]) -> [Event] {
    
    // NOTE: This function ignores free times for the date if it's before the current time.
    
    let startDate = Calendar.current.startOfDay(for: date)
    
    var dateComponents = DateComponents()
    dateComponents.day = 1
    let endDate = Calendar.current.date(byAdding: dateComponents, to: startDate)
    
    // Will hold the current set of free timnes.
    let freeTimes:LinkedList<TimeBlock> = LinkedList<TimeBlock>()
    
    // Initialize each of the 30-minute blocks to unallocated.
    var initial: Date = startDate
    while initial != endDate {
        
        var dateComponents = DateComponents()
        dateComponents.minute = 30
        let final = Calendar.current.date(byAdding: dateComponents, to: initial)!
        
        if initial < date
        {
            initial = final
            continue
        }
        
        freeTimes.append(value: TimeBlock(start: initial, end: final, allocated: false))
        
        initial = final
        
        if initial == endDate {
            freeTimes.append(value: TimeBlock(start: initial, end: Calendar.current.date(byAdding: dateComponents, to: initial)!, allocated: true))
        }
    }
    
    
    // For each event compare the start and end times to the start/end times of the
    for event in events {
        if !event.isAllDay { // Filter out all day events.
            for range in freeTimes {
                if !range.value.allocated && range.value.start >= event.startDate && range.value.start <= event.endDate  {
                    range.value.allocated = true
                }
            }
        }
    }
    
    var events = [Event]()
    
    // Combine the free times into the largest possible groupings and return.
    
    var start: Date = startDate
    var found: Bool = false
    
    for range in freeTimes {
        if !range.value.allocated && !found {
            found = true
            start = range.value.start
        }
        else if range.value.allocated && found {
            found = false
            
            let event: Event = Event()
            event.title = "Free Time"
            event.type = FREE_TIME_EVENT
            event.date = start
            event.endDate = range.value.start
            event.duration = Date.getDifference(initial: start, final: range.value.start)
            
            events.append(event)
        }
    }
    
    return events
}
