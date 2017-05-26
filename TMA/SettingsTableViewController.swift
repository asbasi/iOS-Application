//
//  SettingsTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 5/25/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBAction func autoPopulate(_ sender: Any) {
        Helpers.populateData()
        
        let alert = UIAlertController(title: "Success", message: "Courses populated correctly", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
