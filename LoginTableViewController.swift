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
    
    func getWeekDaysInEnglish() -> [String] {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        calendar.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        return calendar.weekdaySymbols
    }
    
    enum SearchDirection {
        case Next
        case Previous
        
        var calendarOptions: NSCalendar.Options {
            switch self {
            case .Next:
                return .matchNextTime
            case .Previous:
                return [.searchBackwards, .matchNextTime]
            }
        }
    }
    
    func get(direction: SearchDirection, _ dayName: String, fromDate: Date) -> NSDate {
        let weekdaysName = getWeekDaysInEnglish()
        
        assert(weekdaysName.contains(dayName), "weekday symbol should be in form \(weekdaysName)")
        
        let nextWeekDayIndex = weekdaysName.index(of: dayName)! + 1 // weekday is in form 1 ... 7 where as index is 0 ... 6
        
        
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        let nextDateComponent = NSDateComponents()
        nextDateComponent.weekday = nextWeekDayIndex
        
        
        let date = calendar.nextDate(after: fromDate, matching: nextDateComponent as DateComponents, options: direction.calendarOptions)
        return date! as NSDate
    }
    
    @IBAction func Done(_ sender: Any) {
        var currentQuarter = self.realm.objects(Quarter.self).filter("current = true").first
        
        self.dismissKeyboard()
        self.navigationItem.rightBarButtonItem?.isEnabled = false;
        
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.white
        
        let encodedUsername = usernameTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        let encodedPassword = passwordTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        Alamofire.request("http://192.241.206.161/?username=\(encodedUsername)&password=\(encodedPassword)", method: .get, encoding: JSONEncoding.default)
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
                            
                            
                            let courses_in_realm = self.realm.objects(Course.self)
                            
                            
                            for crn in Array(coursesDict.keys) {
                                let courseDict = coursesDict[crn] as! [String: NSObject]
                                
                                let course = Course()
                                course.instructor = courseDict["instructor"] as! String
                                course.units = courseDict["units"] as! Float
                                course.identifier = courseDict["identifier"] as! String
                                course.title = courseDict["title"] as! String
                                course.quarter = currentQuarter
                                
                                var count: Int = 1
                                var color = Array(colorMappings.keys)[Int(arc4random_uniform(UInt32(colorMappings.count)))]
                                
                                while(self.realm.objects(Course.self).filter("color = '\(color)' AND quarter.current = true").count != 0 && count <= colorMappings.count ) {
                                    
                                    color = Array(colorMappings.keys)[Int(arc4random_uniform(UInt32(colorMappings.count)))]
                                    count += 1
                                }
                                
                                course.color = color
                                
                                /////// check if course already exists
                                var already_exists = false
                                for course_in_realm in courses_in_realm {
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
                                    print("classs=\(classs)")
                                    let currentClass = classes[classs] as! [String: NSObject]
                                    if (currentClass["week_days"] as! String) == "" {
                                        continue
                                    }
                                    let week_days = (currentClass["week_days"] as! String).components(separatedBy: ",")
                                    print("week_days=\(week_days)")
                                    print(currentClass)
                                    let week_days_translation = ["M": "Monday", "T": "Tuesday", "W": "Wednesday", "R": "Thursday", "F": "Friday", "S": "Saturday"]
                                    for week_day in week_days {
                                        
                                        ////////////////////////////////////////////////////////////////////////
                                        ///////////////////just parsing the begin_time and end_time/////////////
                                        ///////////////////into 2 ints each hrs & min///////////////////////////
                                        ////////////////////////////////////////////////////////////////////////
                                        
                                        
                                        let s_t = (currentClass["begin_time"] as! String).characters
                                        let e_t = (currentClass["end_time"] as! String).characters
                                        let sh = String(Array(s_t)[0])+String(Array(s_t)[1])
                                        let sm = String(Array(s_t)[2])+String(Array(s_t)[3])
                                        let eh = String(Array(e_t)[0])+String(Array(e_t)[1])
                                        let em = String(Array(e_t)[2])+String(Array(e_t)[3])
                                        
                                        let ish = Int(sh)! //integer start hour
                                        let ism = Int(sm)! //integer start minute
                                        let ieh = Int(eh)! //integer end hour
                                        let iem = Int(em)! //integer end minute
                                        ///////////////////////////////////////////////////
                                        
                                        let currentClassStartDate = Helpers.get_date_from_string(strDate: currentClass["start_date"]! as! String)
                                        let currentClassEndDate = Helpers.get_date_from_string(strDate: currentClass["end_date"]! as! String)
                                        
                                        var the_date = currentClassStartDate
                                        the_date = Calendar.current.date(byAdding: .day, value: -1, to: the_date)!
                                        //subtract 1 day because self.get() starts from the day after
                                        while the_date < currentClassEndDate {
                                            the_date = self.get(direction: .Next, week_days_translation[week_day]!, fromDate: the_date) as Date
                                            if(the_date >= currentClassEndDate){
                                                break;
                                            }
                                            
                                            the_date = Helpers.set_time(mydate: the_date as Date, h: ish, m: ism)
                                            
                                            // add to realm
                                            let ev = Event()
                                            ev.title = "\(classs)"
                                            ev.date = the_date
                                            ev.endDate = Helpers.set_time(mydate: the_date as Date, h: ieh, m: iem)
                                            ev.course = course
                                            ev.duration = Date.getDifference(initial: ev.date, final: ev.endDate)
                                            ev.type = SCHEDULE_EVENT
                                            Helpers.DB_insert(obj: ev)
                                            
                                            //increment 1 day so we dont get the same date next time
                                            the_date = Calendar.current.date(byAdding: .day, value: 1, to: the_date)!
                                        }
                                        
                                        checkCalendarAuthorizationStatus()
                                    }
                                    
                                }
                            } // end for crn
                            
                            self.navigationItem.rightBarButtonItem?.isEnabled = true;
                            self.indicator.stopAnimating()
                            self.indicator.hidesWhenStopped = true
                            
                            if Array(responseDict.keys).count != 0 {
                                let alert = UIAlertController(title: "Success", message: "Courses imported correctly", preferredStyle: UIAlertControllerStyle.alert)
                                
                                if self.isTutorial {
                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
                                        self.dismiss(animated: true, completion: nil)
                                        UserDefaults.standard.set(true, forKey: "showed")
                                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                        let controller = storyboard.instantiateViewController(withIdentifier: "tabBarID")
                                        self.present(controller, animated: true, completion: {
                                            ()-> Void in
                                        })
                                    }))
                                }
                                else {
                                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                }
                                self.present(alert, animated: true, completion: nil)
                                
                                //                                UserDefaults.standard.set(true, forKey: "showed")
                                //                                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                //                                let controller = storyboard.instantiateViewController(withIdentifier: "tabBarID") as! UIViewController
                                //                                self.present(controller, animated: false, completion: {
                                //                                    ()-> Void in
                                //                                })
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
