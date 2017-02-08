//
//  LogTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 2/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class LogTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var course: UILabel!
}

class LogTableViewController: UITableViewController {

    let realm = try! Realm()
    var logToEdit: Log!
    var logs: Results<Log>!
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.logs = self.realm.objects(Log.self).sorted(byKeyPath: "date", ascending: true)
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        
        return self.logs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogsCell", for: indexPath) as! LogTableViewCell
        
        let log = logs[indexPath.row]
        
        cell.title?.text = log.title
        cell.duration?.text = "\(log.duration) hours"
        cell.course?.text = log.course.name
 
        return cell
    }
    
    
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let logs = self.realm.objects(Log.self)
            try! self.realm.write {
                logs[index.row].course.numberOfHoursLogged -= logs[index.row].duration
                self.realm.delete(logs[index.row])
            }
            tableView.reloadData()
        }
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
            let logs = self.realm.objects(Log.self)
            self.logToEdit = logs[index.row]
            
            
            self.performSegue(withIdentifier: "editLog", sender: nil)
        }
        edit.backgroundColor = .blue
        
        return [delete, edit]
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let logs = self.realm.objects(Log.self)
        if segue.identifier! == "addLog" {
            let logAddViewController = segue.destination as! LogAddViewController
            logAddViewController.operation = "add"
        }
        else if segue.identifier! == "editLog" {
            let logAddViewController = segue.destination as! LogAddViewController
            
            logAddViewController.operation = "edit"
            logAddViewController.log = logToEdit!
        }
        else if segue.identifier! == "showLog" {
            let logAddViewController = segue.destination as! LogAddViewController
            
            logAddViewController.operation = "show"
            logAddViewController.log = logs[tableView.indexPathForSelectedRow!.row]
        }
    }
}
