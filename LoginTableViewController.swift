//
//  LoginTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 5/20/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class LoginTableViewController: UITableViewController, UITextFieldDelegate {
    
    var noCurrentQuarter = false
    let realm = try! Realm()
    var isTutorial: Bool = false
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var indicator = UIActivityIndicatorView()
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0,width: 40,height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    @IBAction func Done(_ sender: Any) {
        var currentQuarter = self.realm.objects(Quarter.self).filter("current = true").first
        
        self.dismissKeyboard()
        self.navigationItem.rightBarButtonItem?.isEnabled = false;
        
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.white
        
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let param: [String: AnyObject] = ["username": username as AnyObject, "password": password as AnyObject]
        let url = "https://ibackontrack.com/get_schedule"
        Alamofire.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
            .responseJSON { response in
                if let status = response.response?.statusCode {
                    switch(status){
                    case 200:
                        let responseDict = response.result.value as! [String: NSObject]
                        print("-------------------------------------------")
                        print(responseDict)
                        print("-------------------------------------------")
                        DispatchQueue.main.async {
                            
                            let coursesDict = responseDict["courses"] as! [String: NSObject]
                            
                            if Array(coursesDict.keys).count == 0 {
                                self.navigationItem.rightBarButtonItem?.isEnabled = true;
                                self.indicator.stopAnimating()
                                self.indicator.hidesWhenStopped = true
                                let alert = UIAlertController(title: "Incorrect Credentials", message: "Incorrect username or password.", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                return
                            }
                            
                            if self.noCurrentQuarter {
                                let quarter = Quarter()
                                let quarterDict = responseDict["quarter"] as! [String: String]
                                quarter.title = quarterDict["title"]
                                quarter.startDate = Helpers.get_date_from_string(strDate: quarterDict["start_date"]!)
                                quarter.endDate = Helpers.get_date_from_string(strDate: quarterDict["end_date"]!)
                                
                                quarter.current = true
                                Helpers.DB_insert(obj: quarter)
                                currentQuarter = quarter
                            }
                            
                            
                            
                            let courses_in_realm_for_current_quarter = self.realm.objects(Course.self).filter("quarter.title = '\(currentQuarter!.title!)'")
                            
                            
                            for crn in Array(coursesDict.keys) {
                                let courseDict = coursesDict[crn] as! [String: NSObject]
                                
                                let course = Course()
                                course.instructor = courseDict["instructor"] as! String
                                course.units = courseDict["units"] as! Float
                                course.identifier = courseDict["identifier"] as! String
                                course.title = courseDict["title"] as! String
                                course.quarter = currentQuarter
                                
                                var count: Int = 1
                                var color = Array(colorMappings.keys)[0]
                                
                                while(self.realm.objects(Course.self).filter("color = '\(color)' AND quarter.current = true").count != 0 && count <= colorMappings.count ) {
                                    
                                    color = Array(colorMappings.keys)[count]
                                    count += 1
                                }
                                
                                course.color = color
                                
                                /////// check if course already exists
                                var already_exists = false
                                for course_in_realm in courses_in_realm_for_current_quarter {
                                    if course_in_realm.identifier == course.identifier {
                                        already_exists = true
                                    }
                                }
                                if already_exists {
                                    continue
                                }
                                /////////////////////////////////////////////
                                
                                Helpers.DB_insert(obj: course)
                                
                                
                                let classes = courseDict["classes"] as! [String: NSObject]
                                //////////create events for course
                                for classs in Array(classes.keys) { //Lecture/Discussion/Tutorial..
                                    do {
                                        let jsonDataDates = try JSONSerialization.data(withJSONObject: classes[classs] as! [String: NSObject], options: .prettyPrinted)
                                        
                                        let schedule = Schedule()
                                        schedule.title = classs
                                        schedule.dates = jsonDataDates
                                        schedule.course = course
                                        
                                        Helpers.DB_insert(obj: schedule)
                                        
                                        Helpers.exportSchedule(schedule: schedule)
                                    }
                                    catch {
                                        print(error.localizedDescription)
                                        continue
                                    }
                                }
                            } // end for crn
                            
                            self.navigationItem.rightBarButtonItem?.isEnabled = true;
                            self.indicator.stopAnimating()
                            self.indicator.hidesWhenStopped = true
                            
                            if Array(responseDict.keys).count != 0 {
                                let alert = UIAlertController(title: "Success", message: "Courses imported correctly", preferredStyle: UIAlertControllerStyle.alert)
                                
                                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                                    self.dismiss(animated: true, completion: nil)
                                    UserDefaults.standard.set(true, forKey: "showed")
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let controller = storyboard.instantiateViewController(withIdentifier: "tabBarID")
                                    self.present(controller, animated: true, completion: nil)
                                }))
                                self.present(alert, animated: true, completion: nil)
                            }
                        } //end dispatch main queue
                        
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
    
    @IBAction func usernameTextFieldChanged(_ sender: Any) {
        checkAllTextFields()
    }
    
    @IBAction func Cancel(_ sender: Any) {
        
        UserDefaults.standard.set(true, forKey: "showed")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "tabBarID")
        self.present(controller, animated: true, completion: {
            ()-> Void in
        })
        
    }
    
    @IBAction func passwordTextFieldChanged(_ sender: Any) {
        checkAllTextFields()
    }
    
    func checkAllTextFields() {
        if ((usernameTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        self.passwordTextField.delegate = self
        self.usernameTextField.delegate = self
        
        if !isTutorial {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        let currentQuarters = self.realm.objects(Quarter.self).filter("current = true")
        if currentQuarters.count != 1 {
            noCurrentQuarter = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if(passwordTextField.text != "" && usernameTextField.text != "") {
            Done(self)
        }
        return true
    }
}
