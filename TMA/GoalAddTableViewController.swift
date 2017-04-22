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

class GoalAddTableViewController: UITableViewController, UITextFieldDelegate {

    
    let realm = try! Realm()
    var goal: Goal!
    var course: Course!
    
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var durationTextField: UITextField!
    
    @IBOutlet weak var deadlineDateLabel: UITextField!
    @IBOutlet weak var deadlineDatePicker: UIDatePicker!
    
    private func checkAllTextFields() {
        if ((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)! || (deadlineDateLabel.text?.isEmpty)!) {
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
        if(self.operation == "add") {
            let goal = Goal()
            
            goal.type = segmentController.selectedSegmentIndex
            goal.title = titleTextField.text
            goal.duration = Float(durationTextField.text!)!
            goal.deadline = deadlineDatePicker.date
            goal.course = self.course
            
            Helpers.DB_insert(obj: goal)
        }
            
        else if(self.operation == "edit" || self.operation == "show") {
            try! self.realm.write {

                goal.type = segmentController.selectedSegmentIndex
                goal.title = titleTextField.text
                goal.duration = Float(durationTextField.text!)!
                goal.deadline = deadlineDatePicker.date
                goal.course = self.course
            }
            
        }
        
        self.dismissKeyboard()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        self.tableView.tableFooterView = UIView()
        
        // Text field setup
        self.titleTextField.delegate = self
        self.durationTextField.delegate = self
        
        // Date picker setup
        self.deadlineDatePicker.isHidden = true
        
        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.title = "Add Goal"
        }
            
        else if (self.operation == "edit" || self.operation == "show") {
            self.segmentController.selectedSegmentIndex = self.goal.type
            
            
            self.title = self.goal!.title
            self.titleTextField.text = self.goal!.title
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
        
        let dateIndexPath = IndexPath(row: 0, section: 1)

        if dateIndexPath == indexPath {
            deadlineDatePicker.isHidden = !deadlineDatePicker.isHidden
            
            if (deadlineDateLabel.text?.isEmpty)! {
                deadlineDateLabel.text = dateFormatter.string(from: Date())
            }
        }
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.tableView.beginUpdates()
            self.tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.endUpdates()
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
