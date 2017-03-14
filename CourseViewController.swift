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
    @IBOutlet weak var course: UILabel!
    @IBOutlet weak var percentage: UILabel!
}


class CourseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    
    var courseToEdit: Course!
    var courses: Results<Course>!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.courses = self.realm.objects(Course.self)
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint("Path to realm file: " + self.realm.configuration.fileURL!.absoluteString)
        
        self.courses = self.realm.objects(Course.self)
        self.tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.course!.text = self.courses[indexPath.row].name
        
        var percentage: Float = 0.0
        if self.courses[indexPath.row].numberOfHoursAllocated > 0 {
            percentage = self.courses[indexPath.row].numberOfHoursLogged / self.courses[indexPath.row].numberOfHoursAllocated * 100.0
        }
        else {
            percentage = 100.0
        }
        
        cell.percentage!.text = "\(Int(round(percentage)))%"
        
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
                    let logsToDelete = self.realm.objects(Log.self).filter("course.name = '\(course.name!)'")
                    self.realm.delete(logsToDelete)
                    
                    let eventsToDelete = self.realm.objects(Event.self).filter("course.name = '\(course.name!)'")
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
        let courses = self.realm.objects(Course.self)
        if segue.identifier! == "addCourse" {
            let courseAddViewController = segue.destination as! CourseAddViewController
            
            courseAddViewController.editOrAdd = "add"
        }
        else if segue.identifier! == "editCourse" {
            let courseAddViewController = segue.destination as! CourseAddViewController
            
            courseAddViewController.editOrAdd = "edit"
            courseAddViewController.course = courseToEdit!
        }
        else if segue.identifier! == "showCourse" {
            let courseDetailViewController = segue.destination as! CourseDetailViewController
            var selectedIndexPath = tableView.indexPathForSelectedRow

            courseDetailViewController.course = courses[selectedIndexPath!.row]
        }
    }


}
