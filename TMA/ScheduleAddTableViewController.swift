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
    
    var dateFormatter: DateFormatter = DateFormatter()
    
    // Paths to each of the cells.
    let titlePath = IndexPath(row: 0, section: 0)
    
    let startTimeTextPath = IndexPath(row: 0, section: 1)
    let startTimePickerPath = IndexPath(row: 1, section: 1)
    let endTimeTextPath = IndexPath(row: 2, section: 1)
    let endTimePickerPath = IndexPath(row: 3, section: 1)
    
    let oneDayTogglePath = IndexPath(row: 0, section: 2)
    let startDayTextPath = IndexPath(row: 1, section: 2)
    let startDayPickerPath = IndexPath(row: 2, section: 2)
    let endDayTextPath = IndexPath(row: 3, section: 2)
    let endDayPickerPath = IndexPath(row: 4, section: 2)
    
    let weekdaysTextPath = IndexPath(row: 0, section: 3)
    
    /************************************** Outlets **************************************/
    
    @IBOutlet weak var _titleTextField: UITextField!
    
    @IBOutlet weak var _startTimeTextField: UITextField!
    @IBOutlet weak var _startTimePicker: UIDatePicker!
    
    @IBOutlet weak var _endTimeTextField: UITextField!
    @IBOutlet weak var _endTimePicker: UIDatePicker!
    
    @IBOutlet weak var _oneDayToggle: UISwitch!
    
    @IBOutlet weak var _startDateTextField: UILabel!
    @IBOutlet weak var _startDateCalendar: FSCalendar!
    
    @IBOutlet weak var _endDateTextField: UILabel!
    @IBOutlet weak var _endDateCalendar: FSCalendar!
    
    @IBOutlet weak var _weekdaysTextField: UILabel!

    /************************************** Helpers **************************************/
    
    
    /************************************** Actions **************************************/
    
    @IBAction func titleChanged(_ sender: Any) {
        if (_titleTextField.text?.isEmpty)! == false {
            changeTextFieldToWhite(indexPath: titlePath)
        }
    }
    
    
    /************************************** Main Functions **************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Date Formatter Setup.
        dateFormatter.locale = Locale(identifier: "US_en")
        dateFormatter.dateFormat = "M/d/yy"
        
        // oneDayToggle Setup.
        _oneDayToggle.isOn = false
        
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
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        if calendar == _startDateCalendar {
            _startDateTextField.text = dateFormatter.string(from: date)
        }
        else if calendar == _endDateCalendar {
            _endDateTextField.text = dateFormatter.string(from: date)
        }
    }
}
