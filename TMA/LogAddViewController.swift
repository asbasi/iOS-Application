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
    let coursePickerData = [["ECS 154", "ECS 150", "AMS 10"]]
    
    let realm = try! Realm()
    
    @IBOutlet weak var courseTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    
    var log: Log?
    var operation: String = "" // "edit", "add", or "show"
    
    var coursePicker = UIPickerView()
    
    
    @IBAction func done(_ sender: Any) {
        if((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)!) {
            return;
        }
        
        if(self.operation == "add") {
            self.log = Log()
            
            log!.title = titleTextField.text
            log!.duration = Int(durationTextField.text!)!
            log!.courseName = courseTextField.text!
            Helpers.DB_insert(obj: log!)
        }
        else if(self.operation == "edit" || self.operation == "show") {
            try! self.realm.write {
                log!.title = titleTextField.text
                log!.duration = Int(durationTextField.text!)!
                log!.courseName = courseTextField.text!
            }
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //course picker setup
        coursePicker.dataSource = self
        coursePicker.delegate = self
        courseTextField.inputView = coursePicker
        
        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.pageTitleTextField.title = "Add Log"
        }
        else if (self.operation == "edit") {
            self.pageTitleTextField.title = "Edit Log"
            self.titleTextField.text = self.log!.title
            self.durationTextField.text = "\(self.log!.duration)"
            self.courseTextField.text = "\(self.log!.courseName)"
        }
        else if (self.operation == "show")
        {
            self.pageTitleTextField.title = self.log!.title
            self.titleTextField.text = self.log!.title
            self.durationTextField.text = "\(self.log!.duration)"
            self.courseTextField.text = "\(self.log!.courseName)"

        }
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
        return coursePickerData.count
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coursePickerData[component].count
    }
    
    func pickerView(_
        pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent component: Int
        ) -> String? {
        return coursePickerData[component][row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        courseTextField.text = coursePickerData[component][row]
    }

}
