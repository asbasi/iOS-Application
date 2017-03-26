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

class LogViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let realm = try! Realm()
    
    var logToEdit: Log!
    var logs = [[Log]]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func addingLog(_ sender: Any) {
        if self.realm.objects(Course.self).count == 0 {
            let alert = UIAlertController(title: "No Courses", message: "You must add a course before you can create logs.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else
        {
            self.performSegue(withIdentifier: "addLog", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
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
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.logs.count > 0 {
            self.tableView.backgroundView = nil
            self.tableView.separatorStyle = .singleLine
            return self.logs.count
        }
        
        let image = UIImage(named: "woodlog")!
        let topMessage = "Log"
        let bottomMessage = "You haven't logged any events. All your logged events will show up here."
        
        self.tableView.backgroundView = EmptyBackgroundView(image: image, top: topMessage, bottom: bottomMessage)
        self.tableView.separatorStyle = .none
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 20))
        footerView.backgroundColor = UIColor.clear
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "EEEE, MMMM d"
        let date = self.logs[section][0].date! as Date
        let strDate = formatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            return "Today (\(strDate))"
        }
        else {
            return strDate
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.logs[section].count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogsCell", for: indexPath) as! LogTableViewCell
        
        let log = self.logs[indexPath.section][indexPath.row]
        
        cell.title?.text = log.title
        cell.duration?.text = "\(log.duration) hours"
        cell.course?.text = log.course.name
        if Calendar.current.isDateInToday(log.date as Date) {
            cell.backgroundColor = UIColor(red: 0, green: 128, blue: 0, alpha: 0.1)
        }
        else {
            cell.backgroundColor = UIColor(red: 0, green: 0, blue: 128, alpha: 0.1)
        }
 
        return cell
    }
    
    // MARK: - Navigation
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.logToEdit = self.logs[indexPath.section][indexPath.row]
        self.performSegue(withIdentifier: "showLog", sender: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let navigation: UINavigationController = segue.destination as! UINavigationController
        
        var logAddViewController = LogAddTableViewController.init()
        logAddViewController = navigation.viewControllers[0] as! LogAddTableViewController
        
        if segue.identifier! == "addLog" {
            logAddViewController.operation = "add"
        }
        else if segue.identifier! == "editLog" {
            logAddViewController.operation = "edit"
            logAddViewController.log = logToEdit!
        }
        else if segue.identifier! == "showLog" {
            logAddViewController.operation = "show"
            logAddViewController.log = logToEdit!
        }
    }
}
