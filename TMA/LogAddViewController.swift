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

class LogAddViewController: UIViewController {

    let realm = try! Realm()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var pageTitleTextField: UINavigationItem!
    
    var log: Log?
    var operation: String = "" // "edit", "add", or "show"
    
    @IBAction func done(_ sender: Any) {
        if((titleTextField.text?.isEmpty)! || (durationTextField.text?.isEmpty)!) {
            return;
        }
        
        if(self.operation == "add") {
            self.log = Log()
            
            log!.title = titleTextField.text
            log!.duration = Int(durationTextField.text!)!
            
            Helpers.DB_insert(obj: log!)
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

        // Do any additional setup after loading the view.
        if(self.operation == "add") {
            self.pageTitleTextField.title = "Add Log"
        }
        else if (self.operation == "edit") {
            self.pageTitleTextField.title = "Edit Log"
            self.titleTextField.text = self.log!.title
            self.durationTextField.text = "\(self.log!.duration)"
        }
        else if (self.operation == "show")
        {
            self.pageTitleTextField.title = self.log!.title
            self.titleTextField.text = self.log!.title
            self.durationTextField.text = "\(self.log!.duration)"
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

}
