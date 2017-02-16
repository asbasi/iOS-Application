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
    var events: Results<Event>!

    var allTypesOfEvents = [Results<Event>!]() //0: Active, 1: Finished, 2: All
    
    @IBAction func segmentChanged(_ sender: Any) {
        debugPrint("segmentChanged \(segmentController.selectedSegmentIndex)")
        self.events = allTypesOfEvents[segmentController.selectedSegmentIndex]
        
        self.myTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let activeEvents = self.realm.objects(Event.self).filter("checked = false").sorted(byKeyPath: "date", ascending: true)
        
        let finishedEvents = self.realm.objects(Event.self).filter("checked = true").sorted(byKeyPath: "date", ascending: true)
        
        let allEvents = self.realm.objects(Event.self).sorted(byKeyPath: "date", ascending: true)
        
        self.allTypesOfEvents = [activeEvents, finishedEvents, allEvents]
        
        self.events = self.allTypesOfEvents[segmentController.selectedSegmentIndex]
//        self.events = self.allTypesOfEvents[0]
        
        debugPrint("im done with viewwillappear")
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

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.myTableView.dequeueReusableCell(withIdentifier: "PlannerCell", for: indexPath) as! PlannerViewCell

        cell.title?.text = self.events[indexPath.row].title
        cell.checkbox.on = self.events[indexPath.row].checked
        
        cell.buttonAction = { (_ sender: AnyObject) -> Void in
            try! self.realm.write {
                self.events[indexPath.row].checked = !self.events[indexPath.row].checked
            }
            self.myTableView.reloadData()
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
            
            let event = self.events[index.row]
            
            let optionMenu = UIAlertController(title: nil, message: "\"\(event.title!)\" will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Event", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                try! self.realm.write {
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
            
            let events = self.realm.objects(Event.self)
            self.eventToEdit = events[index.row]
            
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
