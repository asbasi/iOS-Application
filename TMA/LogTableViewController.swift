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
    var logs = [[Log]]()
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        debugPrint("view WILL load ------------")
        let cal = Calendar(identifier: .gregorian)
        var logs = [[Log]]()
        
        let rawLogs = self.realm.objects(Log.self).sorted(byKeyPath: "date", ascending: false)
        
        var allDates = [Date]()
        for log in rawLogs {
            let date = cal.startOfDay(for: log.date as Date)
            if !allDates.contains(date)  {
                allDates.append(date)
                debugPrint("\(log.date)")
            }
        }
        
        
        for dateBegin in allDates {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            let dateEnd = Calendar.current.date(byAdding: components, to: dateBegin)
            
            logs.append(Array(self.realm.objects(Log.self).filter("date BETWEEN %@", [dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: false)))
            
        }
        self.logs = logs
        debugPrint("DONE view WILL load ------------")
        
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint("view DID load ------------")
        let cal = Calendar(identifier: .gregorian)
        var logs = [[Log]]()
        
        let rawLogs = self.realm.objects(Log.self).sorted(byKeyPath: "date", ascending: false)
        
        var allDates = [Date]()
        for log in rawLogs {
            let date = cal.startOfDay(for: log.date as Date)
            if !allDates.contains(date)  {
                allDates.append(date)
                debugPrint("\(log.date)")
            }
        }
        
        
        for dateBegin in allDates {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            let dateEnd = Calendar.current.date(byAdding: components, to: dateBegin)
            
            logs.append(Array(self.realm.objects(Log.self).filter("date BETWEEN %@", [dateBegin,dateEnd]).sorted(byKeyPath: "date", ascending: false)))
            
        }
        self.logs = logs
        debugPrint("DONE view DID load ------------")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.logs.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        "Today (Monday, January 23rd)"
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "EEEE, MMMM dd"
        let date = self.logs[section][0].date! as! Date
        let strDate = formatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            return "Today (\(strDate))"
        }
        else {
            return strDate
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logs[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogsCell", for: indexPath) as! LogTableViewCell
        
        let log = self.logs[indexPath.section][indexPath.row]
        
        cell.title?.text = log.title
        cell.duration?.text = "\(log.duration) hours"
        cell.course?.text = log.course.name
        if Calendar.current.isDateInToday(log.date as Date) {
            cell.backgroundColor = UIColor(red: 239/255, green: 248/255, blue: 205/255, alpha: 1.0)
        }
        else {
            cell.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 0.91, alpha: 1.0)
        }
 
        return cell
    }
    
    
    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let log = self.logs[index.section][index.row]
            
            let optionMenu = UIAlertController(title: nil, message: "\"\(log.title!)\" will be deleted forever.", preferredStyle: .actionSheet)
        
            let deleteAction = UIAlertAction(title: "Delete Log", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                
                try! self.realm.write {
                    self.logs[index.section].remove(at: index.row)
                    if self.logs[index.section].count == 0 {
                        self.logs.remove(at: index.section)
                    }
                    log.course.numberOfHoursLogged -= log.duration
                    self.realm.delete(log)
                }
                
                self.tableView.reloadData()
            })
            optionMenu.addAction(deleteAction);
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                
            })
            optionMenu.addAction(cancelAction)
            
            self.present(optionMenu, animated: true, completion: nil)
        }
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            
            
            self.logToEdit = self.logs[index.section][index.row]
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
