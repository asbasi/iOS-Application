//
//  CourseTableViewController.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/1/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class CourseTableViewController: UITableViewController {

    let realm = try! Realm()
    var courseToEdit: Course!
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint("Path to realm file: " + self.realm.configuration.fileURL!.absoluteString)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

//        let courses = self.realm.objects(Course.self)
        
        
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
        let courses = self.realm.objects(Course.self)
        return courses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CourseCell", for: indexPath)
        let courses = self.realm.objects(Course.self)
        
        cell.textLabel!.text = courses[indexPath.row].name
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let courses = self.realm.objects(Course.self)
            try! self.realm.write {
                self.realm.delete(courses[index.row])
            }
            tableView.reloadData()
        }
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
