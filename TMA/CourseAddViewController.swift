//
//  CourseAddViewController.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class CourseAddViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    let pickerData = [
        ["Fall 2016","Winter 2017","Spring 2017"]
    ]
    
    let realm = try! Realm()
    
    var course: Course?
    var editOrAdd: String = "" // "edit" or "add"
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var instructorTextField: UITextField!
    @IBOutlet weak var unitTextField: UITextField!
    @IBOutlet weak var quarterPicker: UIPickerView!
    
    
    @IBAction func done(_ sender: Any) {
        let courses = self.realm.objects(Course.self)
        
        
        let results = realm.objects(Course.self).filter("name = '\(nameTextField.text!)'")
        if results.count != 0 {
            return
        }
        
        if((nameTextField.text?.isEmpty)! || (instructorTextField.text?.isEmpty)! || (unitTextField.text?.isEmpty)!) {
            return
        }

        

        self.course = Course()
        course!.name = nameTextField.text!
        
        course!.instructor = instructorTextField.text!
        course!.units = Int(unitTextField.text!)!
        course!.quarter = pickerData[0][quarterPicker.selectedRow(inComponent: 0)]
        
        if(editOrAdd == "add") {
            Helpers.DB_insert(obj: course!)
        }
        
        self.navigationController?.popViewController(animated: true)

    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.quarterPicker.dataSource = self
        self.quarterPicker.delegate = self
        
        
        // Do any additional setup after loading the view.
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
        return pickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        return pickerData[component][row]
    }
    
    
    
    
    
}
