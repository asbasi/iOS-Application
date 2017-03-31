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
}


class CourseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    
    var courseToEdit: Course!
    var courses: Results<Course>!

    @IBAction func add(_ sender: Any) {
        self.performSegue(withIdentifier: "addCourse", sender: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.courses = self.realm.objects(Course.self)
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint("Path to realm file: " + self.realm.configuration.fileURL!.absoluteString)
        
        self.courses = self.realm.objects(Course.self)
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
        
        
        cell.courseTitle!.text = course.name
        cell.courseIdentifer!.text = course.identifier
        cell.instructor!.text = course.instructor
        cell.units!.text = "\(course.units) units"
        
        let all_logs = self.realm.objects(Log.self).filter("course.identifier = '\(course.identifier!)'")
        let all_planner = self.realm.objects(Event.self).filter("course.identifier = '\(course.identifier!)'")
        
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
            cell.percentage!.textColor = UIColor.yellow
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
            
            let optionMenu = UIAlertController(title: nil, message: "\"\(course.name!)\" and all associated items will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Course", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in

                try! self.realm.write {
                    let logsToDelete = self.realm.objects(Log.self).filter("course.identifier = '\(course.identifier!)'")
                    self.realm.delete(logsToDelete)
                    
                    let eventsToDelete = self.realm.objects(Event.self).filter("course.identifier = '\(course.identifier!)'")
                    self.realm.delete(eventsToDelete)
                    
                    self.realm.delete(course)
                }
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

            let courses = self.realm.objects(Course.self)
            self.courseToEdit = courses[index.row]
            
            
            self.performSegue(withIdentifier: "editCourse", sender: nil)
        }
        edit.backgroundColor = .blue

        return [delete, edit]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
   // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier! == "showCourse" {
            
            let courseDetailViewController = segue.destination as! CourseDetailViewController
            
            var selectedIndexPath = tableView.indexPathForSelectedRow
            
            let courses = self.realm.objects(Course.self)
            courseDetailViewController.course = courses[selectedIndexPath!.row]
        }
        else {
            let navigation: UINavigationController = segue.destination as! UINavigationController
            var courseAddViewController = CourseAddViewController.init()
            courseAddViewController = navigation.viewControllers[0] as! CourseAddViewController

            
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
