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
//class LogAddViewController: UIViewController {
//

import UIKit
import RealmSwift

class LogAddViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    //test for coursePickerData
    
    let realm = try! Realm()
    
    @IBOutlet weak var coursePicker: UIPickerView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    
    var log: Log?
    var operation: String = "" // "edit", "add", or "show"
    
    @IBAction func done(_ sender: Any) {
        //get the course
        let courses = self.realm.objects(Course.self)
        var course = realm.objects(Course.self).filter("name = '\(courses[coursePicker.selectedRow(inComponent: 0)].name!)'")
        
        if((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)!) {
            return;
        }
        
        if(self.operation == "add") {
            self.log = Log()
            
            log!.title = titleTextField.text
            log!.duration = Int(durationTextField.text!)!
            log!.date = NSDate();
            //find the related course and append to the end
            try! self.realm.write{

                //should have only one course in variable course
                course[0].logs.append(log!)
            }
            
        }
        else if(self.operation == "edit" || self.operation == "show") {
            try! self.realm.write {
                log!.title = titleTextField.text
                log!.duration = Int(durationTextField.text!)!
                
            }
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let courses = self.realm.objects(Course.self)
        //course picker setup
        self.coursePicker.dataSource = self
        self.coursePicker.delegate = self
        
        
        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.pageTitleTextField.title = "Add Log"
        }
        else if (self.operation == "edit") {
            self.pageTitleTextField.title = "Edit Log"
            self.titleTextField.text = self.log!.title
            self.durationTextField.text = "\(self.log!.duration)"
            //var row = courses.index(of: self.course!.name)
            
            
            self.coursePicker.selectRow(0, inComponent: 0, animated: true)
        }
        else if (self.operation == "show")
        {
            self.pageTitleTextField.title = self.log!.title
            self.titleTextField.text = self.log!.title
            self.durationTextField.text = "\(self.log!.duration)"
            
            self.coursePicker.selectRow(0, inComponent: 0, animated: true)

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        //        NoteContent.text = course.name
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
        let courses = self.realm.objects(Course.self)
        
        return courses.count
    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        
        let courses = self.realm.objects(Course.self)
        return courses[row].name
    }

}
