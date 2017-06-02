//
//  ScheduleAddTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 5/31/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift

class ScheduleAddTableViewController: UITableViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    /************************************** Global Variables **************************************/

    var course: Course!
    let realm = try! Realm()
    var mode: String!
    var schedule: Schedule!
    var datesDictionary: [String : NSObject]!
    
    var timeFormatter: DateFormatter = DateFormatter()
    var dateFormatter: DateFormatter = DateFormatter()
    
    // Paths to each of the cells.
    let titlePath = IndexPath(row: 0, section: 0)
    
    let startTimeTextPath = IndexPath(row: 0, section: 1)
    let startTimePickerPath = IndexPath(row: 1, section: 1)
    let endTimeTextPath = IndexPath(row: 2, section: 1)
    let endTimePickerPath = IndexPath(row: 3, section: 1)
    
    let startDayTextPath = IndexPath(row: 0, section: 2)
    let startDayPickerPath = IndexPath(row: 1, section: 2)
    let endDayTextPath = IndexPath(row: 2, section: 2)
    let endDayPickerPath = IndexPath(row: 3, section: 2)
    
    let weekdaysTextPath = IndexPath(row: 0, section: 3)
    
    /************************************** Outlets **************************************/
    
    @IBOutlet weak var _titleTextField: UITextField!
    
    @IBOutlet weak var _startTimeTextField: UITextField!
    @IBOutlet weak var _startTimePicker: UIDatePicker!
    
    @IBOutlet weak var _endTimeTextField: UITextField!
    @IBOutlet weak var _endTimePicker: UIDatePicker!
    
    @IBOutlet weak var _startDateTextField: UITextField!
    @IBOutlet weak var _startDateCalendar: FSCalendar!
    
    @IBOutlet weak var _endDateTextField: UITextField!
    @IBOutlet weak var _endDateCalendar: FSCalendar!
    
    @IBOutlet weak var _weekdaysTextField: UITextField!

    /************************************** Helpers **************************************/
    
    
    /************************************** Actions **************************************/
    

    @IBAction func titleChanged(_ sender: Any) {
        if (_titleTextField.text?.isEmpty)! == false {
            changeTextFieldToWhite(indexPath: titlePath)
        }
    }
    
    @IBAction func startTimeChanged(_ sender: Any) {
        _startTimeTextField.text = timeFormatter.string(from: _startTimePicker.date)
        
        if (_startTimeTextField.text?.isEmpty)! == false {
            changeTextFieldToWhite(indexPath: startTimeTextPath)
        }
    }
    
    @IBAction func endTimeChanged(_ sender: Any) {
        _endTimeTextField.text = timeFormatter.string(from: _endTimePicker.date)
    
        if (_endTimeTextField.text?.isEmpty)! == false {
            changeTextFieldToWhite(indexPath: endTimeTextPath)
        }
    }
    
    @IBAction func weekdaysChanged(_ sender: Any) {
        if (_weekdaysTextField.text?.isEmpty)! == false {
            _weekdaysTextField.textColor = UIColor.black
            changeTextFieldToWhite(indexPath: weekdaysTextPath)
        }
        else {
            _weekdaysTextField.placeholder = "None"
            _weekdaysTextField.textColor = UIColor.lightGray
        }
    }
    
    @IBAction func save(_ sender: Any) {
        
        let textFields: [UITextField] = [_titleTextField, _startTimeTextField, _endTimeTextField, _startDateTextField, _endDateTextField, _weekdaysTextField]
        let paths: [IndexPath] = [titlePath, startTimeTextPath, endTimeTextPath, startDayTextPath, endDayTextPath, weekdaysTextPath]
        
        var index = 0
        var invalid = false
        for textField in textFields {
            if (textField.text?.isEmpty)! {
                invalid = true
                changeTextFieldToRed(indexPath: paths[index])
            }
            
            index += 1
        }
        if invalid {
            let alert = UIAlertController(title: "Alert", message: "Missing Required Information.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            if mode == "add" {
                
            }
            else if mode == "edit" {
                
            }
        }
    }
    
    /************************************** Main Functions **************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // TimeFormatter Setup.
        timeFormatter.locale = Locale(identifier: "US_en")
        timeFormatter.dateFormat = "h:mm a"
        
        // Date Formatter Setup.
        dateFormatter.locale = Locale(identifier: "US_en")
        dateFormatter.dateFormat = "M/d/yy"
        
        // Picker Setup.
        _startTimePicker.isHidden = true
        _endTimePicker.isHidden = true
        
        // Start Date Calendar Setup.
        _startDateCalendar.delegate = self
        _startDateCalendar.dataSource = self
        _startDateCalendar.isHidden = true
        
        // End Date Calendar Setup.
        _endDateCalendar.delegate = self
        _endDateCalendar.dataSource = self
        _endDateCalendar.isHidden = true
        
        if mode == "add" {
            
        }
        else if mode == "edit" {
            
            _titleTextField.text = schedule!.title
            
            do {
                let decoded = try JSONSerialization.jsonObject(with: schedule!.dates, options: [])
                
                self.datesDictionary = decoded as? [String: NSObject]
                print("Dates dictionary")
                print("self.datesDictionary")
            }
            catch {
                print(error.localizedDescription)
                
                let scheduleAddPage: ScheduleAddTableViewController = self

                let alert = UIAlertController(title: "Error", message: "Unable to Parse Schedule", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                    scheduleAddPage.dismiss(animated: true, completion: nil)
                }))
                
                present(alert, animated: true, completion: nil)
            }
        }
    }


    /************************************** Calendar Functions **************************************/
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        if calendar == _startDateCalendar {
            _startDateTextField.textColor = UIColor.black
            _startDateTextField.text = dateFormatter.string(from: date)
            changeTextFieldToWhite(indexPath: startDayTextPath)
        }
        else if calendar == _endDateCalendar {
            _endDateTextField.textColor = UIColor.black
            _endDateTextField.text = dateFormatter.string(from: date)
            changeTextFieldToWhite(indexPath: endDayTextPath)
        }
    }
    
    /************************************** Table View Functions **************************************/
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == startTimePickerPath {
            let height: CGFloat = _startTimePicker.isHidden ? 0.0 : 216
            return height
        }
        else if indexPath == endTimePickerPath {
            let height: CGFloat = _endTimePicker.isHidden ? 0.0 : 216
            return height
        }
        else if indexPath == startDayPickerPath {
            let height: CGFloat =  _startDateCalendar.isHidden ? 0.0 : 216
            return height
        }
        else if indexPath == endDayPickerPath {
            let height: CGFloat = _endDateCalendar.isHidden ? 0.0 : 216
            return height
        }
        return super.tableView(self.tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == startTimeTextPath {
            _startTimePicker.isHidden = !_startTimePicker.isHidden
            
            if (_startTimeTextField.text?.isEmpty)! {
                _startTimeTextField.text = timeFormatter.string(from: _startTimePicker.date)
                _startTimeTextField.textColor = UIColor.black
                changeTextFieldToWhite(indexPath: indexPath)
            }
            
            if !_startTimePicker.isHidden {
                _endTimePicker.isHidden = true
                _startDateCalendar.isHidden = true
                _endDateCalendar.isHidden = true
            }
        }
        else if indexPath == endTimeTextPath {
            _endTimePicker.isHidden = !_endTimePicker.isHidden
            
            if (_endTimeTextField.text?.isEmpty)! {
                _endTimePicker.date = _startTimePicker.date.addingTimeInterval(900)
                _endTimeTextField.text = timeFormatter.string(from: _endTimePicker.date)
                _endTimeTextField.textColor = UIColor.black
                changeTextFieldToWhite(indexPath: indexPath)
            }
            
            if !_endTimePicker.isHidden {
                _startTimePicker.isHidden = true
                _startDateCalendar.isHidden = true
                _endDateCalendar.isHidden = true
            }
        }
        else if indexPath == startDayTextPath {
            _startDateCalendar.isHidden = !_startDateCalendar.isHidden
            
            if !_startDateCalendar.isHidden {
                _startTimePicker.isHidden = true
                _endTimePicker.isHidden = true
                _endDateCalendar.isHidden = true
            }
        }
        else if indexPath == endDayTextPath {
            _endDateCalendar.isHidden = !_endDateCalendar.isHidden
            
            if !_endDateCalendar.isHidden {
                _startTimePicker.isHidden = true
                _endTimePicker.isHidden = true
                _startDateCalendar.isHidden = true
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.endUpdates()
        })
    }
}
