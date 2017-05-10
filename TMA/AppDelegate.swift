//
//  AppDelegate.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/1/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import UserNotifications
import Alamofire
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        var formatter = DateFormatter()
//        formatter.dateFormat = "MM-dd-yyyy"
//        
//        let realm = try! Realm()
//        
//        let allQuarters = realm.objects(Quarter.self)
//        var quartersJSON = [Dictionary<String, Any>]()
//        for quarter in allQuarters {
//            var quarterJSON = quarter.toDictionary() as! Dictionary<String, Any>
//            quarterJSON["startDate"] = formatter.string(from: quarterJSON["startDate"] as! Date)
//            quarterJSON["endDate"] = formatter.string(from: quarterJSON["endDate"] as! Date)
//            var coursesJSON = [[String: Any]]()
//            
//            let courses = realm.objects(Course.self).filter("quarter.title = '\(quarter.title!)'")
//            for course in courses {
//                var courseJSON = course.toDictionary() as! Dictionary<String, Any>
//                courseJSON.removeValue(forKey: "quarter")
//                var eventsJSON = [[String: Any]]()
//                
//                let events = realm.objects(Event.self).filter("course.title = '\(course.title!)'")
//                for event in events {
//                    var eventJSON = event.toDictionary() as! Dictionary<String, Any>
//                    eventJSON["date"] = formatter.string(from: eventJSON["date"] as! Date)
//                    eventJSON["endDate"] = formatter.string(from: eventJSON["endDate"] as! Date)
//                    eventJSON.removeValue(forKey: "course")
//                    eventJSON.removeValue(forKey: "calEventID")
//                    eventJSON.removeValue(forKey: "reminderDate")
//                    eventJSON.removeValue(forKey: "reminderID")
//                    eventsJSON.append(eventJSON)
//                }
//                
//                courseJSON["events"] = eventsJSON
//                coursesJSON.append(courseJSON)
//            }
//            
//            quarterJSON["courses"] = coursesJSON
//            quartersJSON.append(quarterJSON)
//        }
//
//        
//        let parameters: Parameters = ["quarters": quartersJSON]
//        print(parameters)
//        Alamofire.request("http://192.241.206.161/chart", method: .post, parameters: parameters, encoding: JSONEncoding.default)
//            .responseJSON { response in
//                if let status = response.response?.statusCode {
//                    print("status=\(status)")
//                    switch(status){
//                        case 200:
//                            let chart_url = response.result.value as! String
//                            print(chart_url)
//                            break
//                        default:
//                            
//                            break
//                    }
//                }
//        }

    
        
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: UserDefaults.standard.bool(forKey: "showed") ? "tabBarID" : "firstRootID")
        
        window?.rootViewController = rootViewController
        
        UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            if granted {
                UIApplication.shared.registerForRemoteNotifications()
            }
            else
            {
                print("User denied notifications")
            }
            requestAccessToCalendar()
        }
        
        
        
        // Sets up the theme of the app.
        let theme = ThemeManager.currentTheme()
        ThemeManager.applyTheme(theme: theme)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //checkCalendarAuthorizationStatus()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func scheduleNotifcation(at date: Date, title: String, body: String, identifier: String)
    {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents(in: .current, from: date)
        let newComponents = DateComponents(calendar: calendar, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: newComponents, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()

        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().add(request) {(error) in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }

}

