//
//  PlannerTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 2/10/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift
import BEMCheckBox

class PlannerViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var course: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var checkbox: BEMCheckBox!

    var buttonAction: ((_ sender: AnyObject) -> Void)?
    
    @IBAction func checkboxToggled(_ sender: AnyObject) {
        self.buttonAction?(sender)
    }
}

class PlannerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var myTableView: UITableView!

    let realm = try! Realm()
    
    var eventToEdit: Event!
    var events = [[Event]]()

    var allTypesOfEvents = [[[Event]](), [[Event]](), [[Event]]()] //0: Active, 1: Finished, 2: All
    
    @IBAction func segmentChanged(_ sender: Any) {
        self.events = allTypesOfEvents[segmentController.selectedSegmentIndex]
        
        self.myTableView.reloadData()
    }
    
    func populateSegments()
    {
        let cal = Calendar(identifier: .gregorian)
        
        let activeEvents = self.realm.objects(Event.self).filter("checked = false").sorted(byKeyPath: "date", ascending: true)
        let finishedEvents = self.realm.objects(Event.self).filter("checked = true").sorted(byKeyPath: "date", ascending: true)
        let allEvents = self.realm.objects(Event.self).sorted(byKeyPath: "date", ascending: true)
        let rawEvents = [activeEvents, finishedEvents, allEvents]
        
        self.segmentController.setTitle("Active (\(activeEvents.count))", forSegmentAt: 0)
        self.segmentController.setTitle("Finished (\(finishedEvents.count))", forSegmentAt: 1)
        self.segmentController.setTitle("All (\(allEvents.count))", forSegmentAt: 2)
        
        for segment in 0...2
        {
            var events = [[Event]]()
            var allDates = [Date]()
            for event in rawEvents[segment]
            {
                let date = cal.startOfDay(for: event.date as Date)
                if !allDates.contains(date)  {
                    allDates.append(date)
                }
            }
            
            for dateBegin in allDates
            {
                var components = DateComponents()
                components.day = 1
                components.second = -1
                let dateEnd = Calendar.current.date(byAdding: components, to: dateBegin)
                
                if(segment == 0) // Active
                {
                    events.append(Array(self.realm.objects(Event.self).filter("checked = false AND date BETWEEN %@", [dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)))
                }
                else if(segment == 1) // Finished
                {
                    events.append(Array(self.realm.objects(Event.self).filter("checked = true AND date BETWEEN %@", [dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)))
                }
                else if(segment == 2) // All
                {
                    events.append(Array(self.realm.objects(Event.self).filter("date BETWEEN %@", [dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)))
                }
            }
            
            self.allTypesOfEvents[segment] = events
        }
        
        self.events = self.allTypesOfEvents[segmentController.selectedSegmentIndex]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        populateSegments()
        
        self.myTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        //        "Today (Monday, January 23rd)"
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "EEEE, MMMM d"
        let date = self.events[section][0].date! as Date
        let strDate = formatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            return "Today (\(strDate))"
        }
        else if Calendar.current.isDateInTomorrow(date) {
            return "Tommorow (\(strDate))"
        }
        else {
            return strDate
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.events.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.myTableView.dequeueReusableCell(withIdentifier: "PlannerCell", for: indexPath) as! PlannerViewCell

        let date = self.events[indexPath.section][indexPath.row].date as Date
        
        cell.title?.text = self.events[indexPath.section][indexPath.row].title
        cell.checkbox.on = self.events[indexPath.section][indexPath.row].checked
        cell.course?.text = self.events[indexPath.section][indexPath.row].course.name
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        cell.time?.text = formatter.string(from: date)
        
        cell.buttonAction = { (_ sender: AnyObject) -> Void in
            try! self.realm.write {
                self.events[indexPath.section][indexPath.row].checked = !self.events[indexPath.section][indexPath.row].checked
                
                self.populateSegments()
            }
            self.myTableView.reloadData()
        }
        
        if Calendar.current.isDateInToday(date) // Today.
        {
            cell.backgroundColor = UIColor(red: 239/255, green: 248/255, blue: 205/255, alpha: 1.0)
        }
        else if NSDate().compare(date) == .orderedDescending // Before Today.
        {
            cell.backgroundColor = UIColor(red: 255/255, green: 166/255, blue: 166/255, alpha: 1.0)
        }
        else // After Today.
        {
            cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 0.91, alpha: 1.0)
        }
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let event = self.events[index.section][index.row]
            
            let optionMenu = UIAlertController(title: nil, message: "\"\(event.title!)\" will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Event", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                try! self.realm.write {
                    self.events[index.section].remove(at: index.row)
                    if self.events[index.section].count == 0
                    {
                        self.events.remove(at: index.section)
                    }
                    
                    event.course.numberOfHoursAllocated -= event.duration
                    self.realm.delete(event)
                }
                self.myTableView.reloadData()
            })
            optionMenu.addAction(deleteAction);
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                
            })
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        }//end delete
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
            self.eventToEdit = self.events[index.section][index.row]
            
            self.performSegue(withIdentifier: "editEvent", sender: nil)
        }
        edit.backgroundColor = .blue
        
        return [delete, edit]
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let events = self.realm.objects(Event.self)
        let eventAddViewController = segue.destination as! PlannerAddViewController
        
        if segue.identifier! == "addEvent" {
            eventAddViewController.operation = "add"
        }
        else if segue.identifier! == "editEvent" {
            eventAddViewController.operation = "edit"
            eventAddViewController.event = eventToEdit!
        }
        else if segue.identifier! == "showEvent" {
            var selectedIndexPath = self.myTableView.indexPathForSelectedRow

            eventAddViewController.operation = "show"
            eventAddViewController.event = events[selectedIndexPath!.row]
        }
    }
}
