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

    

    var noCurrentQuarter = false
    let realm = try! Realm()
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
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
        
        
        Alamofire.request("http://192.241.206.161/?username=\(usernameTextField.text!)&password=\(passwordTextField.text!)", method: .get, encoding: JSONEncoding.default)
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
                                course.color = Array(colorMappings.keys)[Int(arc4random_uniform(UInt32(colorMappings.count)))]
                                
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
                                        ///////////////////WTH is that?/////////////////////////////////////////
                                        ///////////////////just trying to parse the begin_time//////////////////
                                        ///////////////////and end_time into 2 ints each hrs & min//////////////
                                        ////////////////////////////////////////////////////////////////////////
                                        ///////////////////why?/////////////////////////////////////////////////
                                        ///////////////////because I don't know how swift strings work//////////
                                        ///////////////////if you do please fix it//////////////////////////////
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
                                        
                                        var the_date = currentQuarter!.startDate!
                                        while the_date < currentQuarter!.endDate {
                                            the_date = self.get(direction: .Next, week_days_translation[week_day]!, fromDate: the_date) as Date
                                            
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
                    
                            if Array(coursesDict.keys).count != 0 {
                                let alert = UIAlertController(title: "Success", message: "Courses imported correctly", preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                            }
                        } //end dispatch main queue
                        
                        print("-------------------------------------------")
                    default:
                        let alert = UIAlertController(title: "Internet Error", message: "Something is wrong with the server.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        
                        print("error with response status: \(status)")
                    }
                }
        } //end Alamofire.request
    } //end Done()
    
    
    @IBAction func usernameTextFieldChanged(_ sender: Any) {
        checkAllTextFields()
    }
    
    @IBAction func passwordTextFieldChanged(_ sender: Any) {
        checkAllTextFields()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false;
        
        
        let currentQuarters = self.realm.objects(Quarter.self).filter("current = true")
        if currentQuarters.count != 1 {
            noCurrentQuarter = true
        }
    }
    
    
    
    func checkAllTextFields() {
        if ((usernameTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)!) {
            self.navigationItem.rightBarButtonItem?.isEnabled = false;
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true;
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
