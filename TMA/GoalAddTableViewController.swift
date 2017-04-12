//
//  GoalAddTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 3/4/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications
import EventKit

class GoalAddTableViewController: UITableViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    
    let realm = try! Realm()
    var goal: Goal!
    
    var courses: Results<Course>!
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var deadlineDateLabel: UITextField!
    @IBOutlet weak var deadlineDatePicker: UIDatePicker!
    
    @IBOutlet weak var courseLabel: UITextField!
    @IBOutlet weak var coursePicker: UIPickerView!
    
    
    
    
    private func checkAllTextFields() {
        if ((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)! || (deadlineDateLabel.text?.isEmpty)! || (courseLabel.text?.isEmpty)!) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
    }

    
    @IBAction func durationChanged(_ sender: Any) {
        checkAllTextFields()
    }
    @IBAction func GoalTitleChanged(_ sender: Any) {
        checkAllTextFields()
    }

    @IBAction func courseLabelChanged(_ sender: Any) {
        checkAllTextFields()
    }
    
    
    
    @IBAction func setDate(_ sender: Any) {
        deadlineDateLabel.text = dateFormatter.string(from: deadlineDatePicker.date)
        checkAllTextFields()
    }
    
    @IBAction func durationTitleChanged(_ sender: Any) {
        checkAllTextFields()
    }
    
    var operation: String = ""
    
    var dateFormatter = DateFormatter()
    
    @IBAction func cancel(_ sender: Any) {
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        //get the course
        
        let course = self.courses.filter("quarter.current = true AND identifier = '\(courses[coursePicker.selectedRow(inComponent: 0)].identifier!)'")[0]
        
        if(self.operation == "add") {
            let goal = Goal()
            
            //            goal.course = self.course
            goal.type = segmentController.selectedSegmentIndex
            
            goal.title = titleTextField.text
            goal.duration = Float(durationTextField.text!)!
            goal.deadline = deadlineDatePicker.date
            goal.course = course
            Helpers.DB_insert(obj: goal)
        }
            
        else if(self.operation == "edit" || self.operation == "show") {
            try! self.realm.write {
                //                goal.course = self.course
                goal.type = segmentController.selectedSegmentIndex
                
                goal.title = titleTextField.text
                goal.duration = Float(durationTextField.text!)!
                goal.deadline = deadlineDatePicker.date
                goal.course = course
            }
            
        }
        
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.courses = self.realm.objects(Course.self).filter("quarter.current = true")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        
        self.tableView.tableFooterView = UIView()
        
        self.courses = self.realm.objects(Course.self).filter("quarter.current = true")
        
        // Text field setup
        self.titleTextField.delegate = self
        self.durationTextField.delegate = self
        
        // Date picker setup
        self.deadlineDatePicker.isHidden = true
        
        // Course picker setup
        self.coursePicker.delegate = self
        self.coursePicker.dataSource = self
        self.courseLabel.delegate = self
        self.coursePicker.showsSelectionIndicator = true
        self.coursePicker.isHidden = true
        
        
        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.title = "Add Goal"
        }
            
        else if (self.operation == "edit" || self.operation == "show") {
//            self.goal = self.event!.goal
            self.segmentController.selectedSegmentIndex = self.goal.type
            
            
            self.title = self.goal!.title
            self.titleTextField.text = self.goal!.title
            self.courseLabel.text = self.goal!.course.name
            self.durationTextField.text = "\(self.goal!.duration)"
            self.deadlineDateLabel.text = dateFormatter.string(from: self.goal!.deadline)
            
            
        }
        
        // Ensure that the keyboard disappears when the user taps elsewhere.
        self.hideKeyboardWhenTapped()
        
        // Hide the save button.
        self.checkAllTextFields()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if(indexPath.section == 0 && indexPath.row == 3){
            let height: CGFloat = coursePicker.isHidden ? 0.0 : 216
            return height
        }
        
        if(indexPath.section == 1 && indexPath.row == 1)
        {
            let height: CGFloat = deadlineDatePicker.isHidden ? 0.0 : 216
            return height
        }
        
        return super.tableView(self.tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let courseIndexPath = IndexPath(row: 2, section: 0)
        let dateIndexPath = IndexPath(row: 0, section: 1)

        if dateIndexPath == indexPath {
            deadlineDatePicker.isHidden = !deadlineDatePicker.isHidden
            
            if (deadlineDateLabel.text?.isEmpty)! {
                deadlineDateLabel.text = dateFormatter.string(from: Date())
            }
            
//            if !deadlineDatePicker.isHidden {
//                deadlineDatePicker.isHidden = true
//            }
        }
        else if courseIndexPath == indexPath{
            coursePicker.isHidden = !coursePicker.isHidden
            
            if (courseLabel.text?.isEmpty)!{
                if courses.count != 0{
                    self.coursePicker.selectRow(0, inComponent: 0, animated: false)
                    courseLabel.text = courses[0].identifier
                }
                
            }
            if !coursePicker.isHidden{
                deadlineDatePicker.isHidden = true
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.endUpdates()
        })
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.courses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component:Int ) -> String? {
        return self.courses[row].identifier
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        courseLabel.text = courses[row].identifier
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
