//
//  GoalTableViewController.swift
//  TMA
//
//  Created by Milad Ghoreishi on 4/10/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class GoalViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var deadline: UILabel!
    @IBOutlet weak var remaining: UILabel!
}

class GoalTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
        let realm = try! Realm()
    
        @IBOutlet weak var tableView: UITableView!
    
        var goalToEdit: Goal!
        var goals: Results<Goal>!
        var course: Course!
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            print("course.quarter.title = '\(self.course.quarter.title!)' AND course.identifier = '\(self.course.identifier!)'")
            
            self.goals = self.realm.objects(Goal.self).filter("course.quarter.title = '\(self.course.quarter.title!)' AND course.identifier = '\(self.course.identifier!)'")
            
            self.tableView.reloadData()
            
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        
        // MARK: - Table view data source
        
        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
        {
            let header = view as! UITableViewHeaderFooterView
            header.textLabel?.font = UIFont(name: "Futura", size: 11)
                header.textLabel?.textColor = UIColor.lightGray
        }
    
        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            
            return ""
        }
        
        func numberOfSections(in tableView: UITableView) -> Int {
            
            if self.goals.count > 0 {
                self.tableView.backgroundView = nil
                self.tableView.separatorStyle = .singleLine
                
                return 1
            }
            
            let image = UIImage(named: "bar-chart")!
            let topMessage = "Goals"
            let bottomMessage = "You haven't created any goals. All your goals will show up here."
                
            self.tableView.backgroundView = EmptyBackgroundView(image: image, top: topMessage, bottom: bottomMessage)
            self.tableView.separatorStyle = .none
            
            return 0
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.goals.count
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath) as! GoalViewCell
            
            let goal = self.goals[indexPath.row]
            
            cell.title?.text = goal.title
            cell.type?.text = "\(eventType[goal.type]) Goal"
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "US_en")
            formatter.dateFormat = "M/d/yy"
            
            cell.deadline?.text = formatter.string(from: goal.deadline)
            
            cell.remaining?.text = "\(goal.duration) Hours Remaining"
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
            
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
                
                let goal = self.goals[index.row]
                
                let optionMenu = UIAlertController(title: nil, message: "\"\(goal.title!)\" and all associated events will be deleted forever.", preferredStyle: .actionSheet)
                //delete goals, events, logs
                
                let deleteAction = UIAlertAction(title: "Delete Goal", style: .destructive, handler: {
                    (alert: UIAlertAction!) -> Void in
                    
                    try! self.realm.write {
                        let logsToDelete = self.realm.objects(Log.self).filter("goal.title = '\(goal.title!)'")
                        self.realm.delete(logsToDelete)
                        
                        let eventsToDelete = self.realm.objects(Event.self).filter("goal.title = '\(goal.title!)'")
                        self.realm.delete(eventsToDelete)
                        
                        self.realm.delete(goal)
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
                let goal = self.goals[index.row]
                
                self.goalToEdit = goal
                
                self.performSegue(withIdentifier: "editGoal", sender: nil)
            }
            edit.backgroundColor = .blue
            
            return [delete, edit]
        }
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let goal = self.goals[indexPath.row]
        
            self.goalToEdit = goal
        
            self.performSegue(withIdentifier: "showGoal", sender: nil)
        }
    
    
        // MARK: - Navigation
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
            if segue.identifier! == "showGoal" {
                let goalTrackerTableViewController = segue.destination as! GoalTrackerTableViewController
                
                goalTrackerTableViewController.goal = goalToEdit!
                goalTrackerTableViewController.pageTitle = goalToEdit!.title
            }
            else {

                let navigation: UINavigationController = segue.destination as! UINavigationController
                
               var goalAddViewController = GoalAddTableViewController.init()
                
                goalAddViewController = navigation.viewControllers[0] as! GoalAddTableViewController
                
                if segue.identifier! == "addGoal" {
                    goalAddViewController.operation = "add"
                    goalAddViewController.course = self.course
                }
                else if segue.identifier! == "editGoal" {
                    goalAddViewController.operation = "edit"
                    goalAddViewController.goal = goalToEdit!
                }
            }
        }
}
