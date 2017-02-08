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


class CourseTableViewController: UITableViewController {

    let realm = try! Realm()
    var courseToEdit: Course!
    var courses: Results<Course>!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.courses = self.realm.objects(Course.self)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint("Path to realm file: " + self.realm.configuration.fileURL!.absoluteString)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
//        print(courses.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.courses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath) as! CourseTableViewCell
        
        cell.course!.text = self.courses[indexPath.row].name
        cell.percentage!.text = "\(self.courses[indexPath.row].numberOfHoursLogged)" // / numberOfHoursAllocated
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let optionMenu = UIAlertController(title: nil, message: "Course will be deleted forever.", preferredStyle: .actionSheet)
            
            let deleteAction = UIAlertAction(title: "Delete Course", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                let course = self.courses[index.row]
                try! self.realm.write {
                    let logsToDelete = self.realm.objects(Log.self).filter("course.name = '\(course.name!)'")
                    self.realm.delete(logsToDelete)
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
            tableView.reloadData()
            
        }//end delete
        delete.backgroundColor = .red

        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in

            let courses = self.realm.objects(Course.self)
            self.courseToEdit = courses[index.row]
            
            
            self.performSegue(withIdentifier: "editCourse", sender: nil)
        }
        edit.backgroundColor = .blue

//        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
//            print("share button tapped")
//        }
//        share.backgroundColor = .blue
        
        return [delete, edit]
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
