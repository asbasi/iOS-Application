//
//  PlannerAddTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 3/4/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class PlannerAddTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let realm = try! Realm()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var courseLabel: UILabel!
    @IBOutlet weak var coursePicker: UIPickerView!
    
    @IBOutlet weak var dateLabel: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func setDate(_ sender: UIDatePicker) {
        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    var dateFormatter = DateFormatter()
    
    var operation: String = ""
    var event: Event?
    var courses: Results<Course>!
    
    
    @IBAction func save(_ sender: Any) {
        //get the course
        let course = self.courses.filter("name = '\(courses[coursePicker.selectedRow(inComponent: 0)].name!)'")[0]
        
        if((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)!) {
            return;
        }
        
        if(self.operation == "add") {
            let event = Event()
            
            event.title = titleTextField.text
            event.duration = Float(durationTextField.text!)!
            event.date = datePicker.date
            event.course = course
            
            try! self.realm.write {
                course.numberOfHoursAllocated += event.duration
            }
            
            Helpers.DB_insert(obj: event)
            
        }
        else if(self.operation == "edit" || self.operation == "show") {
            try! self.realm.write {
                course.numberOfHoursAllocated -= event!.duration
                event!.title = titleTextField.text
                event!.duration = Float(durationTextField.text!)!
                event!.course = course
                event!.date = dateFormatter.date(from: dateLabel.text!)
                
                course.numberOfHoursAllocated += event!.duration
            }
        }
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        self.courseLabel.isEnabled = false
        self.dateLabel.isEnabled = false
        
        self.courses = self.realm.objects(Course.self)
        
        self.tableView.tableFooterView = UIView()
        
        // Course picker setup
        self.coursePicker.showsSelectionIndicator = true
        self.coursePicker.delegate = self
        self.coursePicker.dataSource = self
        self.coursePicker.isHidden = true
        
        // Date picker setup
        self.datePicker.isHidden = true

        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.pageTitleTextField.title = "Add Event"
        }
        else if (self.operation == "edit" || self.operation == "show") {
            self.pageTitleTextField.title = self.event!.title
            self.titleTextField.text = self.event!.title
            self.durationTextField.text = "\(self.event!.duration)"
            self.dateLabel.text = dateFormatter.string(from: self.event!.date)
            self.courseLabel.text = self.event!.course.name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0 && indexPath.row == 2)
        {
            let height: CGFloat = coursePicker.isHidden ? 0.0 : 217
            return height
        }
        
        if(indexPath.section == 1 && indexPath.row == 1)
        {
            let height: CGFloat = datePicker.isHidden ? 0.0 : 216
            return height
        }
        
        return super.tableView(self.tableView, heightForRowAt: indexPath)
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let courseIndexPath = IndexPath(row: 1, section: 0)
        let dateIndexPath = IndexPath(row: 0, section: 1)
        
        if courseIndexPath == indexPath {
            
            coursePicker.isHidden = !coursePicker.isHidden
            
            if (courseLabel.text?.isEmpty)! {
                if courses.count != 0 {
                    self.coursePicker.selectRow(0, inComponent: 0, animated: false)
                    courseLabel.text = courses[0].name
                }
            }
            
            datePicker.isHidden = true
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tableView.beginUpdates()
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.endUpdates()
            })
        }
        else if dateIndexPath == indexPath {
            
            datePicker.isHidden = !datePicker.isHidden
            
            if (dateLabel.text?.isEmpty)! {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .short
                
                dateLabel.text = dateFormatter.string(from: Date())
            }
            
            coursePicker.isHidden = true
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tableView.beginUpdates()
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.tableView.endUpdates()
            })
        }
        else
        {
            coursePicker.isHidden = true
            datePicker.isHidden = true
            
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            })
        }
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.courses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component:Int ) -> String? {
        return self.courses[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        courseLabel.text = courses[row].name
    }
}
