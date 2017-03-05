//
//  LogAddViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//
//
//import UIKit
//import RealmSwift
//

import UIKit
import RealmSwift

class LogAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //test for coursePickerData
    
    let realm = try! Realm()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    @IBOutlet weak var courseTextField: UITextField!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    var log: Log?
    var operation: String = "" // "edit", "add", or "show"
    var courses: Results<Course>!
    var coursePicker = UIPickerView()
    var datePicker = UIDatePicker()
    var pickedDate = Date()
    @IBAction func done(_ sender: Any) {
        
        if((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)! || (courseTextField.text?.isEmpty)!) {
            return;
        }
        
        //get the course
        let course = self.courses.filter("name = '\(courseTextField.text!)'")[0]
        
        if(self.operation == "add") {
            let log = Log()
            
            log.title = titleTextField.text
            log.duration = Float(durationTextField.text!)!
            log.date = pickedDate
            log.course = course
            
            try! self.realm.write {
                course.numberOfHoursLogged += log.duration
            }
            
            Helpers.DB_insert(obj: log)
            
        }
        else if(self.operation == "edit" || self.operation == "show") {
            try! self.realm.write {
                course.numberOfHoursLogged -= log!.duration
                log!.title = titleTextField.text
                log!.duration = Float(durationTextField.text!)!
                log!.course = course
                log!.date = pickedDate
                course.numberOfHoursLogged += log!.duration
                
                
            }
        }
        
        let _ = self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        
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
            self.pageTitleTextField.title = "Add Log"
        }
        else if (self.operation == "edit" || self.operation == "show") {
            self.pageTitleTextField.title = "Edit Log"
            self.titleTextField.text = self.log!.title
            self.durationTextField.text = "\(self.log!.duration)"
            self.dateTextField.text = dateFormatter.string(from: pickedDate as Date)
            //let courseRow = courseNames.index(of: self.log!.course.name)
            self.courseTextField.text = self.log!.course.name
            //self.coursePicker.selectRow(courseRow!, inComponent: 0, animated: true)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //        NoteContent.text = course.name
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
    
    //MARK: - Picker View Data Sources and Delegates
    
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
        pickedDate = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        self.dateTextField.text = dateFormatter.string(from: pickedDate as Date)
        
        self.view.endEditing(true)
    }
    
    func courseDonePressed() {
        courseTextField.text = courses[coursePicker.selectedRow(inComponent: 0)].name
        courseTextField.resignFirstResponder()
    }
}
