//
//  LoginTableViewController.swift
//  
//
//  Created by Abdulrahman Sahmoud on 4/23/17.
//
//

import UIKit
import Alamofire
import RealmSwift

class LoginTableViewController: UITableViewController {

    let realm = try! Realm()
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func Done(_ sender: Any) {
        let currentQuarter = self.realm.objects(Quarter.self).filter("current = true").first
        
        Alamofire.request("http://sahmudi.com/?username=\(usernameTextField.text!)&password=\(passwordTextField.text!)", method: .get, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        let responseDict = response.result.value as! [String: NSObject]
                        print("-------------------------------------------")
                        print(responseDict)
                        print("-------------------------------------------")
                        DispatchQueue.main.async {
                            for crn in Array(responseDict.keys) {
                                let courseDict = responseDict[crn] as! [String: NSObject]
                            
                                let course = Course()
                                course.instructor = courseDict["instructor"] as! String
                                course.units = courseDict["units"] as! Float
                                course.identifier = courseDict["identifier"] as! String
                                course.title = courseDict["title"] as! String
                                course.quarter = currentQuarter
                                course.color = "None"
                                Helpers.DB_insert(obj: course)
                            } // end for crn
                            
                        } //end DispathQueue.main
                    
                        if Array(responseDict.keys).count == 0 {
                            let alert = UIAlertController(title: "Incorrect Credentials", message: "Incorrect username or password.", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        else {
                            DispatchQueue.main.async {
                                let storage = Storage()
                                storage.value = "imported_courses"
                                Helpers.DB_insert(obj: storage)
                            }
                            let alert = UIAlertController(title: "Success", message: "Courses imported correctly", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                                self.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                        print("-------------------------------------------")
                    default:
                        let alert = UIAlertController(title: "Internet Error", message: "Something is wrong with the server.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                        
                        print("error with response status: \(status)")
                    }
                }
        } //end Alamofire.request
    } //end Done()
    
    
    @IBAction func Cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentQuarters = self.realm.objects(Quarter.self).filter("current = true")
        if currentQuarters.count != 1 {
            let alert = UIAlertController(title: "Current Quarter Error", message: "You must have one current quarter before you can create events.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {action in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
        
        let imported_courses = self.realm.objects(Storage.self).filter("value = 'imported_courses'")
        if imported_courses.count == 1 {
            let alert = UIAlertController(title: "Courses Already Imported", message: "You can't reimport your courses.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: {action in
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
