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

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    
    let realm = try! Realm()
    
    var events: Results<Event>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentDate: Date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        
        getEventsForDate(dateFormatter.date(from: dateFormatter.string(from: currentDate))!)
    }

    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        self.myTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /******************************* Calendar Functions *******************************/
    
    // How many events are scheduled for that day?
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
    
    func getEventsForDate(_ date: Date) -> Void
    {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let dateBegin = date
        let dateEnd = Calendar.current.date(byAdding: components, to: dateBegin)
    
    
        self.events = self.realm.objects(Event.self).filter("date BETWEEN %@",[dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: true)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        debugPrint("\(date)")
        getEventsForDate(date)
        
        self.myTableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date) {
        
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
    
}
