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

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate{

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    
    let realm = try! Realm()
    
    fileprivate var events: Results<Event>!
    fileprivate var eventToEdit: Event!
    fileprivate var logToEdit: Log!
    fileprivate var selectedDate: Date = Date()
    
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    private func verify() {
        let currentQuarters = self.realm.objects(Quarter.self).filter("current = true")
        if currentQuarters.count != 1 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            let alert = UIAlertController(title: "Current Quarter Error", message: "You must have one current quarter before you can create events.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let currentQuarter = currentQuarters[0]
            let courses = self.realm.objects(Course.self).filter("quarter.title = '\(currentQuarter.title!)'")
            
            if courses.count == 0 {
                self.navigationItem.rightBarButtonItem?.isEnabled = false
                let alert = UIAlertController(title: "No Courses Error", message: "You must have at least one course in the current quarter before you can create events.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.navigationItem.rightBarButtonItem?.isEnabled = true
            }
        }
    }
    
    @IBAction func addingEvent(_ sender: Any) {
        if self.realm.objects(Course.self).filter("quarter.current = true").count == 0 {
            let alert = UIAlertController(title: "No Courses", message: "You must add a course to the current quarter before you can create events.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            self.performSegue(withIdentifier: "addEvent", sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup the calendar.
        self.calendar.appearance.borderRadius = 0 // Square Boxes for selected dates.
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0; // Hide the extra subheadings.
        //self.calendar.today = nil // Get rid of the today circle.
        self.calendar.swipeToChooseGesture.isEnabled = true // Swipe-To-Choose
        
        /*let scopeGesture = UIPanGestureRecognizer(target: calendar, action: #selector(calendar.handleScopeGesture(_:)));
        self.calendar.addGestureRecognizer(scopeGesture) */
        
        let currentDate: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        self.events = getEventsForDate(dateFormatter.date(from: dateFormatter.string(from: currentDate))!)
        selectedDate = currentDate
        
        self.myTableView.frame.origin.y = self.calendar.frame.maxY
        //self.myTableView.tableFooterView = UIView()
        
        // setGradientBackground(view: self.view, colorTop: UIColor.blue, colorBottom: UIColor.lightGray)
    }

    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        verify()
        checkCalendarAuthorizationStatus()
        
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

        return self.realm.objects(Event.self).filter("course.quarter.current = true AND date BETWEEN %@",[dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)
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

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        self.events = getEventsForDate(date)
        selectedDate = date
        
        self.myTableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendar.frame.size.height = bounds.height
        self.myTableView.frame.origin.y = calendar.frame.maxY
        
        self.myTableView.frame = CGRect(x: self.myTableView.frame.origin.x, y: self.myTableView.frame.origin.y, width: self.view.frame.width, height: self.view.frame.maxY - calendar.frame.maxY)
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition)   -> Bool {
        return true
    }
    
    func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return true
    }
    
    /***************************** Table View Functions *****************************/
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont(name: "Futura", size: 11)
        header.textLabel?.textColor = UIColor.lightGray
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "EEEE, MMMM d"
        let date = selectedDate
        
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
        if self.events.count > 0 {
            self.myTableView.backgroundView = nil
            self.myTableView.separatorStyle = .singleLine
            return 1
        }

        
        let image = UIImage(named: "like")!
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "EEEE, MMMM d"
        let topMessage = formatter.string(from: selectedDate)
        let bottomMessage = "No items for this date"
        
        self.myTableView.backgroundView = EmptyBackgroundView(image: image, top: topMessage, bottom: bottomMessage)
        self.myTableView.separatorStyle = .none
        
        /*
        let rect = CGRect(x: 0, y: 0, width: self.myTableView.bounds.size.width, height: self.myTableView.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)
        
        noDataLabel.text = "No events on selected day"
        noDataLabel.textColor = UIColor.gray
        noDataLabel.textAlignment = NSTextAlignment.center
        self.myTableView.backgroundView = noDataLabel
        //self.myTableView.separatorStyle = .none
        */
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }

    /*
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        footerView.backgroundColor = UIColor.clear
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    */
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.myTableView.dequeueReusableCell(withIdentifier: "PlannerCell", for: indexPath) as! PlannerViewCell

        let event = self.events[indexPath.row]
        
        cell.title?.text = event.title
        cell.checkbox.on = event.checked
        cell.course?.text = event.course.identifier
        
        cell.color.backgroundColor = colorMappings[event.course.color]
        cell.color.layer.cornerRadius = 4.0
        cell.color.clipsToBounds = true
        
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let date = self.events[indexPath.row].date as Date
        cell.time?.text = formatter.string(from: date)
        
        cell.checkbox.boxType = BEMBoxType.square
        cell.checkbox.onAnimationType = BEMAnimationType.fill
        cell.buttonAction = { (_ sender: PlannerViewCell) -> Void in
            
            var path: IndexPath = self.myTableView.indexPath(for: sender)!
            
            let event = self.events[path.row]
            
            if(event.checked) { // About to be unchecked.
                if let log = event.log {
                    try! self.realm.write {
                        self.realm.delete(log)
                        event.log = nil
                    }
                }
            }
            else { // About to be checked.
                
                let alert = UIAlertController(title: "Enter Time", message: "How much time (as a decimal number) did you spend studying?", preferredStyle: .alert)
                
                alert.addTextField { (textField) in
                    textField.keyboardType = .decimalPad
                }
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { [weak alert] (_) in
                    let textField = alert!.textFields![0] // Force unwrapping because we know it exists.
                    
                    if textField.text != "" {
                        let log = Log()
                        
                        log.title = event.title
                        log.duration = Float(textField.text!)!
                        log.date = event.date
                        log.course = event.course
                        log.type = event.type
                        
                        Helpers.DB_insert(obj: log)
                        
                        try! self.realm.write {
                            event.log = log
                        }
                    }
                }))
                
                alert.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: nil))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            try! self.realm.write {
                self.events[path.row].checked = !self.events[path.row].checked
            }
        }
        
        if Calendar.current.isDateInToday(date) // Today.
        {
            cell.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.1)
        }
        else if NSDate().compare(date) == .orderedDescending // Before Today.
        {
            cell.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.1)
        }
        else // After Today.
        {
            cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.1)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let event = self.events[index.row]

            let optionMenu = UIAlertController(title: nil, message: "\"\(event.title!)\" will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Event", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                deleteEventFromCalendar(withID: event.calEventID!)
                
                try! self.realm.write {
                    let event: Event = self.events[index.row]
                    
                    if let log = event.log {
                        self.realm.delete(log)
                    }
                    
                    self.realm.delete(event)
                }
                
                self.calendar.reloadData()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.eventToEdit = self.events[indexPath.row]
        self.performSegue(withIdentifier: "showEvent", sender: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "toggle" {
            return
        }
        
        let navigation: UINavigationController = segue.destination as! UINavigationController
        
        var eventAddViewController = PlannerAddTableViewController.init()
        eventAddViewController = navigation.viewControllers[0] as! PlannerAddTableViewController
        
        if segue.identifier! == "addEvent" {
            eventAddViewController.operation = "add"
        }
        else if segue.identifier! == "editEvent" {
            eventAddViewController.operation = "edit"
            eventAddViewController.event = eventToEdit!
        }
        else if segue.identifier! == "showEvent" {
            eventAddViewController.operation = "show"
            eventAddViewController.event = eventToEdit!
        }
    }
}
