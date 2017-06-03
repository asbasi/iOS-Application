//
//  WeekdayPickerTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 6/2/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit

class WeekdayPickerTableViewController: UITableViewController {

    var weekdays: String?
    var delegate: writeValueBackDelegate?
    
    // delegate?.writeValueBack("That is a value")
    // (dictFromJSON["week_days"] as! String).components(separatedBy: ",")
    
    var selected = [Bool](repeating: false, count: 7)
    let mappings: [String : Int] = ["M" : 0, "T" : 1, "W" : 2, "R": 3, "F" : 4, "S" : 5, "Su" : 6]
    
    private func setSelected() {
        let week_days = (weekdays)?.components(separatedBy: ",")
        
        if let parsed_days = week_days {
            for day in parsed_days {
                if day == "" {
                    continue
                }
                selected[mappings[day]!] = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSelected()
        setCells()
    }
    
    private func getWeekdays() {
        weekdays = ""
        
        for i in 0...6 {
            if selected[i] {
                let code = mappings.key(forValue: i)
                
                if weekdays == "" {
                    weekdays = weekdays! + code!
                }
                else {
                    weekdays = weekdays! + ",\(code!)"
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        getWeekdays()
        
        delegate?.writeValueBack(value: weekdays)
        
        super.viewWillDisappear(animated)
    }
    
    private func setCells() {
        for i in 0...6 {
            let path = IndexPath(row: i, section: 0)
            if selected[i] {
                print("Set \(mappings.key(forValue: i)!)")
                self.tableView.cellForRow(at: path)?.accessoryType = UITableViewCellAccessoryType.checkmark
            }
            else {
                self.tableView.cellForRow(at: path)?.accessoryType = UITableViewCellAccessoryType.none
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selected[indexPath.row] = !selected[indexPath.row]
        
        if selected[indexPath.row] {
            self.tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        }
        else {
            self.tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
