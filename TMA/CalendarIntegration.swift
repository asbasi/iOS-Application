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
    
    // TODO: If the user initially denies access and then later authorizes make sure the calendar gets created.
    
    switch(status) {
    case EKAuthorizationStatus.notDetermined:
        requestAccessToCalendar()
    case EKAuthorizationStatus.authorized:
        print("Access Granted")
    case EKAuthorizationStatus.denied:
        print("Access Denied")
    default:
        print("Case Default")
    }
}

func requestAccessToCalendar() {
    eventStore.requestAccess(to: .event, completion:
        { (granted, error) in
            if granted {
                print("Access to calendar store granted")

                let _ = createCalendar(withTitle: "Back On Track Application")
            }
            else {
                print("Access to calendar store not granted")
            }
    })
}

func createCalendar(withTitle title: String) -> String? {
    var identifier: String?
    
    eventStore.requestAccess(to: .event, completion:
        { (granted, error) in
            if granted {
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
            }
    })
    
    return identifier
}

func addEventToCalendar(event: Event, toCalendar calendarIdentifier: String) -> String? {
    
    var identifier: String?
    
    eventStore.requestAccess(to: .event, completion:
        { (granted, error) in
            if granted {
                if let calendarForEvent = eventStore.calendar(withIdentifier: calendarIdentifier) {
                    
                    // Create the calendar event.
                    let newEvent = EKEvent(eventStore: eventStore)
                    
                    newEvent.calendar = calendarForEvent
                    newEvent.title = "\(event.title!) (\(event.course.name!))"
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
            }
    })
    
    return identifier
}

func editEventInCalendar(event: Event, toCalendar calendarIdentifier: String) {
    eventStore.requestAccess(to: .event, completion:
        { (granted, error) in
            if granted {
                
                if let calEvent = eventStore.event(withIdentifier: event.calEventID) {
                    calEvent.title = "\(event.title!) (\(event.course.name!))"
                    calEvent.startDate = event.date
                    
                    var components = DateComponents()
                    components.setValue(Int(event.duration), for: .hour)
                    components.setValue(Int(round(60 * (event.duration - floor(event.duration)))), for: .minute)
                    calEvent.endDate = Calendar.current.date(byAdding: components, to: event.date)!
                    
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
    })
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
