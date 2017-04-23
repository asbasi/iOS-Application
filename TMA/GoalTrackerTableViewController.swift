//
//  GoalTrackerTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 4/13/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import EventKit
import RealmSwift

class GoalTrackerViewCell: UITableViewCell {
    @IBOutlet weak var day: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
}

class GoalTrackerTableViewController: UITableViewController {

    let realm = try! Realm()
    let eventStore = EKEventStore()
    
    var allocatedTimes = [[Event]]()
    var freeTimes = [[Event]]()
    
    private let ALLOCATED_TIMES = 0
    private let FREE_TIMES = 1
    
    var goal: Goal!
    
    @IBOutlet weak var navBar: UINavigationItem!
    
    var pageTitle: String?
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBAction func segmentToggled(_ sender: Any) {
        self.populateFreeTimes()
        self.populateAllocatedTimes()
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navBar.title = pageTitle
    }
    
    private func populateFreeTimes() {
        freeTimes = [[Event]]()
        
        if let identifier = UserDefaults.standard.value(forKey: calendarKey) {
            if let calendar = getCalendar(withIdentifier: identifier as! String) {
                //let calendars = eventStore.calendars(for: .event)
            
                for offset in 0...6 {
                    
                    var components = DateComponents()
                    components.day = offset
                    let date = Calendar.current.date(byAdding: components, to: Date())!
                    
                    //let calEvents = getCalendarEvents(forDate: date, fromCalendars: calendars)
                    let calEvents = getCalendarEvents(forDate: date, fromCalendars: [calendar])
                    
                    let events = findFreeTimes(onDate: date, withEvents: calEvents)
                    
                    freeTimes.append(events)
                }
            }
        }
    }
    
    private func populateAllocatedTimes() {
        allocatedTimes = [[Event]]()
        
        // Get all events related to the course.
        let events = self.realm.objects(Event.self).filter("course.identifier = '\(self.goal.course.identifier!)'").sorted(byKeyPath: "date", ascending: true)
        
        var allDates = [Date]()
        
        for event in events {
            let date = Calendar.current.startOfDay(for: event.date)
            
            if !allDates.contains(date) && date >= Calendar.current.startOfDay(for: Date()) {
                allDates.append(date)
            }
        }
        
        for dateBegin in allDates {
            var components = DateComponents()
            components.day = 1
            let dateEnd = Calendar.current.date(byAdding: components, to: dateBegin)
            
            allocatedTimes.append(Array(events.filter("date BETWEEN %@", [dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkCalendarAuthorizationStatus()
        
        self.populateFreeTimes()
        self.populateAllocatedTimes()
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 11)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "EEEE, MMMM d"

        var date: Date!
        if segmentController.selectedSegmentIndex == ALLOCATED_TIMES {
            if allocatedTimes[section].count != 0 {
                date = self.allocatedTimes[section][0].date
            }
        }
        else {
            if freeTimes[section].count != 0 {
                date = self.freeTimes[section][0].date
            }
        }
        
        let strDate = formatter.string(from: date!)
        if Calendar.current.isDateInToday(date) {
            return "Today (\(strDate))"
        }
        else if Calendar.current.isDateInTomorrow(date) {
            return "Tommorow (\(strDate))"
        }

        return strDate
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if segmentController.selectedSegmentIndex == ALLOCATED_TIMES {
            return allocatedTimes.count
        }
        else {
            return freeTimes.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentController.selectedSegmentIndex == ALLOCATED_TIMES {
            return allocatedTimes[section].count
        }
        else {
            return freeTimes[section].count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackerCell", for: indexPath) as! GoalTrackerViewCell

        var event: Event
        
        if segmentController.selectedSegmentIndex == ALLOCATED_TIMES {
            event = allocatedTimes[indexPath.section][indexPath.row]
            cell.title?.text = event.title
        }
        else {
            event = freeTimes[indexPath.section][indexPath.row]
            cell.title?.text = "Free"
        }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE"
        cell.day?.text = dayFormatter.string(from: event.date )
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.timeZone = TimeZone.current
        
        if(event.duration == 24.0) {
            cell.time?.text = "All Day"
        }
        else {
            cell.time?.text = timeFormatter.string(from: event.date ) + " - " + timeFormatter.string(from: Date.getEndDate(fromStart: event.date, withDuration: event.duration))
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
