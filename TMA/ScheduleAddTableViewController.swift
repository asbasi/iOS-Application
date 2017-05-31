//
//  ScheduleAddTableViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 5/31/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class ScheduleAddTableViewController: UITableViewController {

    var course: Course!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

}
