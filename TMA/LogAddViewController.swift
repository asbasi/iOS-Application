////
////  LogAddViewController.swift
////  TMA
////
////  Created by Arvinder Basi on 2/5/17.
////  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//

import UIKit
import RealmSwift

class LogAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //test for coursePickerData
    
    let realm = try! Realm()
    
    @IBOutlet weak var coursePicker: UIPickerView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    
    var log: Log?
    var operation: String = "" // "edit", "add", or "show"
    var courses: Results<Course>!
    
    @IBAction func done(_ sender: Any) {
        //get the course
        let course = self.courses.filter("name = '\(courses[coursePicker.selectedRow(inComponent: 0)].name!)'")[0]
        
        if((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)!) {
            return;
        }
        
        if(self.operation == "add") {
            let log = Log()
            
            log.title = titleTextField.text
            log.duration = Float(durationTextField.text!)!
            log.date = datePicker.date as NSDate!
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
                log!.date = datePicker.date as NSDate!
                course.numberOfHoursLogged += log!.duration
                
                
            }
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())

        self.courses = self.realm.objects(Course.self)
        var courseNames = [String]()
        for course in self.courses {
            courseNames.append(course.name)
        }
        
        //course picker setup
        self.coursePicker.dataSource = self
        self.coursePicker.delegate = self
        
        
        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.pageTitleTextField.title = "Add Log"
        }
        else if (self.operation == "edit" || self.operation == "show") {
            self.pageTitleTextField.title = "Edit Log"
            self.titleTextField.text = self.log!.title
            self.durationTextField.text = "\(self.log!.duration)"
            self.datePicker!.date = self.log!.date as Date
            var courseRow = courseNames.index(of: self.log!.course.name)
            
            self.coursePicker.selectRow(courseRow!, inComponent: 0, animated: true)
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

}
