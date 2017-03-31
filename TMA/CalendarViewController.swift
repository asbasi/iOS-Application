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

class CalendarViewPlannerCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var course: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var checkbox: BEMCheckBox!
    
    var buttonAction: ((_ sender: AnyObject) -> Void)?
    
    @IBAction func checkboxToggled(_ sender: AnyObject) {
        self.buttonAction?(sender)
    }
}

class CalendarViewLogCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var course: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var checkbox: BEMCheckBox!
}

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate{

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    
    let realm = try! Realm()
    
    var EVENTS = 0
    var LOGS = 1
    
    fileprivate var events: Results<Event>!
    fileprivate var logs: Results<Log>!
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
    
    @IBAction func addingEvent(_ sender: Any) {
        if self.realm.objects(Course.self).count == 0 {
            let alert = UIAlertController(title: "No Courses", message: "You must add a course before you can create events.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(title: "Adding Item", message: "What would you like to add?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Add Event", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.performSegue(withIdentifier: "addEvent", sender: nil)}))
            alert.addAction(UIAlertAction(title: "Add Log", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.performSegue(withIdentifier: "addLog", sender: nil)}))
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.destructive, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
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
        self.logs = getLogsForDate(dateFormatter.date(from: dateFormatter.string(from: currentDate))!)
        selectedDate = currentDate
        
        self.myTableView.frame.origin.y = self.calendar.frame.maxY
        self.myTableView.tableFooterView = UIView()
        
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
    
    func getLogsForDate(_ date: Date) -> Results<Log>
    {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let dateBegin = date
        let dateEnd = Calendar.current.date(byAdding: components, to: dateBegin)
        
        
        return self.realm.objects(Log.self).filter("date BETWEEN %@",[dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)
    }
    
    // How many events are scheduled for that day?
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let numEvents = getEventsForDate(date).count + getLogsForDate(date).count
        
        if numEvents >= 1
        {
            // Put two dots if there's 3 or more events on that day
            return numEvents >= 3 ? 2 : 1
        }
        return 0
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        self.events = getEventsForDate(date)
        self.logs = getLogsForDate(date)
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == self.EVENTS) {
            return "Events"
        }
        else if(section == self.LOGS) {
            return "Logs"
        }
        
        return ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numSections: Int = 0
        if self.events.count > 0 {
            numSections = 1
            EVENTS = 0
        }
        else {
            EVENTS = -1
        }
        
        if self.logs.count > 0 {
            numSections = 2
            
            if(EVENTS == -1) {
                LOGS = 0
            }
            else
            {
                LOGS = 1
            }
        }
        
        if numSections > 0 {
            self.myTableView.backgroundView = nil
            self.myTableView.separatorStyle = .singleLine
            return numSections
        }

        let image = UIImage(named: "happy")!
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "EEEE, MMMM d"
        let topMessage = formatter.string(from: selectedDate)
        let bottomMessage = "No items for this date"
        
        self.myTableView.backgroundView = EmptyBackgroundView(image: image, top: topMessage, bottom: bottomMessage)
        self.myTableView.separatorStyle = .none
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == self.EVENTS) {
            return self.events.count
        }
        else if(section == self.LOGS) {
            return self.logs.count
        }
        return 0
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
        
        if(indexPath.section == self.EVENTS) {
            let cell = self.myTableView.dequeueReusableCell(withIdentifier: "CalendarPlannerCell", for: indexPath) as! CalendarViewPlannerCell

            cell.title?.text = self.events[indexPath.row].title
            cell.checkbox.on = self.events[indexPath.row].checked
            cell.course?.text = self.events[indexPath.row].course.name
        
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let date = self.events[indexPath.row].date as Date
            cell.time?.text = formatter.string(from: date)
        
            cell.checkbox.boxType = BEMBoxType.square
            cell.checkbox.onAnimationType = BEMAnimationType.fill
            cell.buttonAction = { (_ sender: AnyObject) -> Void in
                try! self.realm.write {
                    self.events[indexPath.row].checked = !self.events[indexPath.row].checked
                }
            }
            return cell
        }
        else if(indexPath.section == self.LOGS)
        {
            let cell = self.myTableView.dequeueReusableCell(withIdentifier: "CalendarLogCell", for: indexPath) as! CalendarViewLogCell
            
            cell.title?.text = self.logs[indexPath.row].title
            cell.course?.text = self.logs[indexPath.row].course.name
            
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            let date = self.logs[indexPath.row].date as Date
            cell.time?.text = formatter.string(from: date)
            
            cell.checkbox.boxType = BEMBoxType.square
            cell.checkbox.on = true
            cell.checkbox.onFillColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.1)
            cell.checkbox.onTintColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.1)
            cell.checkbox.onCheckColor = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.1)
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            var item: Item
            
            if(index.section == self.EVENTS){
                item = self.events[index.row]
            }
            else {
                item = self.logs[index.row]
            }
            
            let optionMenu = UIAlertController(title: nil, message: "\"\(item.title!)\" will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Event", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                try! self.realm.write {
                    if(index.section == self.EVENTS) {
                        let event: Event = self.events[index.row]
                        self.realm.delete(event)
                    }
                    else
                    {
                        let log: Log = self.logs[index.row]
                        self.realm.delete(log)
                    }
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
            
            if(index.section == self.EVENTS)
            {
                self.eventToEdit = self.events[index.row]
                self.performSegue(withIdentifier: "editEvent", sender: nil)
            }
            else if(index.section == self.LOGS)
            {
                self.logToEdit = self.logs[index.row]
                self.performSegue(withIdentifier: "editLog", sender: nil)
            }
        }
        edit.backgroundColor = .blue
        
        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(indexPath.section == EVENTS) { // Events
            self.eventToEdit = self.events[indexPath.row]
            self.performSegue(withIdentifier: "showEvent", sender: nil)
        }
        else if(indexPath.section == LOGS) { // Logs
            self.logToEdit = self.logs[indexPath.row]
            self.performSegue(withIdentifier: "editLog", sender: nil)
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let navigation: UINavigationController = segue.destination as! UINavigationController
        
        if(segue.identifier! == "addEvent" || segue.identifier! == "editEvent" || segue.identifier == "showEvent") {
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
        else if (segue.identifier! == "addLog" || segue.identifier! == "editLog" || segue.identifier! == "showLog") {
            
            var logAddViewController = LogAddTableViewController.init()
            logAddViewController = navigation.viewControllers[0] as! LogAddTableViewController
            
            if segue.identifier! == "addLog" {
                logAddViewController.operation = "add"
            }
            else if segue.identifier! == "editLog" {
                logAddViewController.operation = "edit"
                logAddViewController.log = logToEdit!
            }
            else if segue.identifier! == "showLog" {
                logAddViewController.operation = "show"
                logAddViewController.log = logToEdit
            }
        }
    }
}
