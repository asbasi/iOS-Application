//
//  ThemeTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 4/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit

class ThemeTableViewController: UITableViewController {

    private var lastSelection: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let theme = ThemeManager.currentTheme()
        
        lastSelection = IndexPath(row: theme.rawValue, section: 0)
        self.tableView.cellForRow(at: lastSelection)?.accessoryType = UITableViewCellAccessoryType.checkmark
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
   
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.lastSelection != nil {
            self.tableView.cellForRow(at: self.lastSelection)?.accessoryType = UITableViewCellAccessoryType.none
        }
        
        self.tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
        
        // Change Theme and store for next time.
        if let selectedTheme = Theme(rawValue: indexPath.row) {
            ThemeManager.applyTheme(theme: selectedTheme)
            
            // The Theme isn't automatically applied to the current page so we need to explicity set it.
            self.setTheme(theme: selectedTheme)
        }
        
        self.lastSelection = indexPath
        
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
}
