//
//  EventAddViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 2/10/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class PlannerAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let realm = try! Realm()
    
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    @IBOutlet weak var courseTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    
    var operation: String = ""
    var event: Event?
    var courses: Results<Course>!
    var coursePicker = UIPickerView()
    var datePicker = UIDatePicker()
    var pickedDate = NSDate()

    @IBAction func done(_ sender: Any) {
        //get the course
        let course = self.courses.filter("name = '\(courses[coursePicker.selectedRow(inComponent: 0)].name!)'")[0]
        
        if((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)!) {
            return;
        }
        
        if(self.operation == "add") {
            let event = Event()
            
            event.title = titleTextField.text
            event.duration = Float(durationTextField.text!)!
            event.date = datePicker.date as NSDate!
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
                event!.date = datePicker.date as NSDate!
                course.numberOfHoursAllocated += event!.duration
                
                
            }
        }
        
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        //dateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        self.courses = self.realm.objects(Course.self)
        var courseNames = [String]()
        for course in self.courses {
            courseNames.append(course.name)
        }
        
        
        //course picker setup
        self.coursePicker.showsSelectionIndicator = true
        self.coursePicker.delegate = self
        self.coursePicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(courseDonePressed))
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.courseTextField.inputView = coursePicker
        self.courseTextField.inputAccessoryView = toolBar
        
        //date picker setup
        createDatePicker()
        
        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.pageTitleTextField.title = "Add Event"
        }
        else if (self.operation == "edit" || self.operation == "show") {
            self.pageTitleTextField.title = "Edit Event"
            self.titleTextField.text = self.event!.title
            self.durationTextField.text = "\(self.event!.duration)"
            self.dateTextField.text = dateFormatter.string(from: pickedDate as Date)
            self.courseTextField.text = self.event!.course.name
        }    }

    override func viewWillAppear(_ animated: Bool) {
        // NoteContent.text = course.name
        self.courses = self.realm.objects(Course.self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.courses.count
    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        
        
        return self.courses[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.courseTextField.text = self.courses[row].name
    }
    
    
    func createDatePicker() {
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button item
        let pickerDoneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(dateDonePressed))
        toolbar.setItems([pickerDoneButton], animated: false)
        dateTextField.inputAccessoryView = toolbar
        
        //assign date picker to text field
        dateTextField.inputView = datePicker
    }
    
    func dateDonePressed() {
        pickedDate = datePicker.date as NSDate
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        self.dateTextField.text = dateFormatter.string(from: pickedDate as Date)
        
        self.view.endEditing(true)
    }
    
    func courseDonePressed() {
        
        courseTextField.resignFirstResponder()
        
    }
}
