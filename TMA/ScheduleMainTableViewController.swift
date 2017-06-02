//
//  ScheduleMainTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 5/30/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var days: UILabel!
    @IBOutlet weak var times: UILabel!
    @IBOutlet weak var dates: UILabel!
}

class ScheduleMainTableViewController: UITableViewController {

    var course: Course!
    var schedules: Results<Schedule>!
    var mode: String! // "add" or "edit"
    var scheduleToEdit: Schedule?
    
    let realm = try! Realm()
    
    func refresh() {
        schedules = self.realm.objects(Schedule.self).filter("course.identifier = '\(course.identifier!)' AND course.quarter.title = '\(course.quarter.title!)'")
        checkCalendarAuthorizationStatus()
        
        if mode == "edit" {
            
        }
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    
        // set observer for UIApplicationWillEnterForeground to refresh the app when app wakes up.
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .UIApplicationWillEnterForeground, object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        refresh()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if self.schedules.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        }

        let rect = CGRect(x: 0,
        y: 0,
        width: self.tableView.bounds.size.width,
        height: self.tableView.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)

        noDataLabel.text = "No Schedules currently created for this course"
        noDataLabel.textColor = UIColor.gray
        noDataLabel.textAlignment = NSTextAlignment.center
        self.tableView.backgroundView = noDataLabel
        self.tableView.separatorStyle = .none

        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schedules.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleMainCell", for: indexPath) as! ScheduleViewCell

        let schedule = schedules[indexPath.row]
        
        cell.title.text = schedule.title
        cell.days.text = nil
        cell.times.text = nil
        cell.dates.text = nil
        
        do {
            let decoded = try JSONSerialization.jsonObject(with: schedule.dates, options: [])
            
            if let dictFromJSON = decoded as? [String: NSObject] {
                cell.days.text = dictFromJSON["week_days"] as? String
                
                let start_time_raw = Helpers.parseTime(from: dictFromJSON["begin_time"] as! String)
                let end_time_raw = Helpers.parseTime(from: dictFromJSON["end_time"] as! String)
                
                let start = Helpers.set_time(mydate: Date(), h: start_time_raw.hour, m: start_time_raw.min)
                let end = Helpers.set_time(mydate: Date(), h: end_time_raw.hour, m: end_time_raw.min)
                
                let formatter = DateFormatter()
                formatter.dateFormat = "h:mm a"
                
                cell.times.text = formatter.string(from: start) + " - " + formatter.string(from: end)
                
                let start_date = Helpers.get_date_from_string(strDate: dictFromJSON["start_date"]! as! String)
                let end_date = Helpers.get_date_from_string(strDate: dictFromJSON["end_date"]! as! String)
                
                formatter.dateFormat = "M/d/yy"
                cell.dates.text = "\(formatter.string(from: start_date)) to \(formatter.string(from: end_date))"
            }
        }
        catch {
            print(error.localizedDescription)
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        scheduleToEdit = schedules[indexPath.row]
        
        performSegue(withIdentifier: "editSchedule", sender: nil)
    }
    
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let scheduleAddTableViewController = segue.destination as! ScheduleAddTableViewController
        scheduleAddTableViewController.course = self.course
        
        if segue.identifier! == "addSchedule" {
            scheduleAddTableViewController.mode = "add"
        }
        else if segue.identifier! == "editSchedule" {
            scheduleAddTableViewController.mode = "edit"
            scheduleAddTableViewController.schedule = scheduleToEdit
        }
    }

}
