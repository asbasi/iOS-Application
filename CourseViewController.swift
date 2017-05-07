//
//  CourseTableViewController.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/1/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class CourseTableViewCell: UITableViewCell {
    @IBOutlet weak var color: UIImageView!
    @IBOutlet weak var percentage: UILabel!
    
    @IBOutlet weak var courseIdentifer: UILabel!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var instructor: UILabel!
    @IBOutlet weak var units: UILabel!
    
    @IBOutlet weak var viewGoals: UIButton!
    @IBOutlet weak var viewStats: UIButton!
}


class CourseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    
    var quarter: Quarter?
    var courseToEdit: Course!
    var courses: Results<Course>!

    @IBAction func add(_ sender: Any) {
        self.performSegue(withIdentifier: "addCourse", sender: nil)
    }
    
    private func verify() {
        let currentQuarters = self.realm.objects(Quarter.self).filter("current = true")
        if currentQuarters.count != 1 {
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            let alert = UIAlertController(title: "Current Quarter Error", message: "You must have one current quarter before you can create events.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        verify()

        let currQuarter = self.realm.objects(Quarter.self).filter("current = true")
        
        if currQuarter.count == 1 {
            self.quarter = currQuarter[0]
        }
        else {
            self.quarter = nil
        }

        self.courses = self.realm.objects(Course.self).filter("quarter.title = '\(self.quarter?.title! ?? "1337")'")
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    /*
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        footerView.backgroundColor = UIColor.clear
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView,  heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }*/
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.courses.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return 1
        }
        
        /*
        let rect = CGRect(x: 0,
                          y: 0,
                          width: self.tableView.bounds.size.width,
                          height: self.tableView.bounds.size.height)
        let noDataLabel: UILabel = UILabel(frame: rect)
        
        noDataLabel.text = "No Courses"
        noDataLabel.textColor = UIColor.gray
        noDataLabel.textAlignment = NSTextAlignment.center
        self.tableView.backgroundView = noDataLabel
        self.tableView.separatorStyle = .none
        */
        
        let image = UIImage(named: "bar-chart")!
        let topMessage = "Courses"
        let bottomMessage = "You haven't created any courses. All your courses will show up here."
        
        self.tableView.backgroundView = EmptyBackgroundView(image: image, top: topMessage, bottom: bottomMessage)
        self.tableView.separatorStyle = .none
        
        return 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.courses.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseTableViewCell
        
        let course = self.courses[indexPath.row]
        cell.color.backgroundColor = colorMappings[course.color]
        cell.color.layer.cornerRadius = 4.0
        cell.color.clipsToBounds = true
        
        
        cell.courseTitle!.text = course.title
        cell.courseIdentifer!.text = course.identifier
        cell.instructor!.text = course.instructor
        cell.units!.text = "\(course.units) units"

        let all_logs = self.realm.objects(Log.self).filter("course.quarter.title = '\(self.quarter?.title! ?? "1337")' AND course.identifier = '\(course.identifier!)'")
        let all_planner = self.realm.objects(Event.self).filter("course.quarter.title = '\(self.quarter?.title! ?? "1337")' AND course.identifier = '\(course.identifier!)'")
        
        let numerator = Helpers.add_duration(events: all_logs)
        let denominator = Helpers.add_duration(events: all_planner)
        
        let overallPercentage: Int
        if denominator == 0 {
            overallPercentage = Int(round(100 * numerator))
        }
        else {
            overallPercentage = Int(round(100 * numerator / denominator))
        }
        
        cell.percentage!.text = "\(overallPercentage)%"
        
        if(overallPercentage <= 50) {
            cell.percentage!.textColor = UIColor.red
        }
        else if(overallPercentage <= 75) {
            cell.percentage!.textColor = UIColor.blue
        }
        else {
            cell.percentage!.textColor = UIColor.green
        }
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in

            let course = self.courses[index.row]
            
            let optionMenu = UIAlertController(title: nil, message: "\"\(course.title!)\" and all associated items will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Course", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in

                course.delete(realm: self.realm)
                self.tableView.reloadData()
            })
            optionMenu.addAction(deleteAction);
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                
            })
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        }//end delete
        delete.backgroundColor = .red

        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in

            let courses = self.realm.objects(Course.self).filter("quarter.title = '\(self.quarter?.title! ?? "1337")'")
            self.courseToEdit = courses[index.row]
            
            self.performSegue(withIdentifier: "editCourse", sender: nil)
        }
        edit.backgroundColor = .blue

        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let courses = self.realm.objects(Course.self).filter("quarter.title = '\(self.quarter?.title! ?? "1337")'")
        self.courseToEdit = courses[indexPath.row]
        
        self.performSegue(withIdentifier: "showStats", sender: nil)
    }
    
   // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "showStats" {
            let courseDetailViewController = segue.destination as! CourseStatsViewController
            courseDetailViewController.course = courseToEdit!
        }
        else {
            let navigation: UINavigationController = segue.destination as! UINavigationController
            var courseAddViewController = CourseAddViewController.init()
            courseAddViewController = navigation.viewControllers[0] as! CourseAddViewController

            courseAddViewController.quarter = self.quarter
            
            if segue.identifier! == "addCourse" {
                courseAddViewController.editOrAdd = "add"
            }
            else if segue.identifier! == "editCourse" {
                courseAddViewController.editOrAdd = "edit"
                courseAddViewController.course = courseToEdit!
            }
        }
    }
}
