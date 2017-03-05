//
//  CalendarViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 2/27/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift
import FSCalendar
import BEMCheckBox

class CalendarViewCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var course: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var checkbox: BEMCheckBox!
    
    var buttonAction: ((_ sender: AnyObject) -> Void)?
    
    @IBAction func checkboxToggled(_ sender: AnyObject) {
        self.buttonAction?(sender)
    }
}

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate{

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    
    let realm = try! Realm()
    
    var events: Results<Event>!
    var eventToEdit: Event!
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the calendar.
        self.calendar.appearance.borderRadius = 0 // Square Boxes for selected dates.
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0; // Hide the extra subheadings.
        //self.calendar.today = nil // Get rid of the today circle.
        self.calendar.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose
        let scopeGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)));
        self.calendar.addGestureRecognizer(scopeGesture)
        
        let currentDate: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        self.events = getEventsForDate(dateFormatter.date(from: dateFormatter.string(from: currentDate))!)
        
        self.myTableView.frame.origin.y = self.calendar.frame.maxY + 6
        
        // setGradientBackground(view: self.view, colorTop: UIColor.blue, colorBottom: UIColor.lightGray)
    }

    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        self.calendar.reloadData()
        self.myTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /******************************* Calendar Functions *******************************/
    
    func getEventsForDate(_ date: Date) -> Results<Event>
    {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let dateBegin = date
        let dateEnd = Calendar.current.date(byAdding: components, to: dateBegin)
        
        
        return self.realm.objects(Event.self).filter("date BETWEEN %@",[dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)
    }
    
    // How many events are scheduled for that day?
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let numEvents = getEventsForDate(date).count
        
        if numEvents >= 1
        {
            // Put two dots if there's 3 or more events on that day
            return numEvents >= 3 ? 2 : 1
        }
        return 0
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.events = getEventsForDate(date)
        
        self.myTableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.frame.size.height = bounds.height
        self.myTableView.frame.origin.y = calendar.frame.maxY + 6
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
        //return monthPosition == .current
        return true
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        //return monthPosition == .current
        return true
    }
    
    /***************************** Table View Functions *****************************/
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.myTableView.dequeueReusableCell(withIdentifier: "CalendarCell", for: indexPath) as! CalendarViewCell

        cell.title?.text = self.events[indexPath.row].title
        cell.checkbox.on = self.events[indexPath.row].checked
        cell.course?.text = self.events[indexPath.row].course.name
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = self.events[indexPath.row].date as Date
        cell.time?.text = formatter.string(from: date)
        
        cell.buttonAction = { (_ sender: AnyObject) -> Void in
            try! self.realm.write {
                self.events[indexPath.row].checked = !self.events[indexPath.row].checked
            }
        }
        
        return cell
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
            
            self.eventToEdit = self.events[index.row]
            
            self.performSegue(withIdentifier: "editEvent", sender: nil)
        }
        edit.backgroundColor = .blue
        
        return [delete, edit]
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let eventAddViewController = segue.destination as! PlannerAddTableViewController
        
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
