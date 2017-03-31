//
//  QuartersViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 3/29/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import RealmSwift

class QuarterTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var dates: UILabel!
    @IBOutlet weak var numCourses: UILabel!
    @IBOutlet weak var current: UIImageView!
}

class QuartersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let realm = try! Realm()
    
    var quarterToEdit: Quarter!
    var quarters: Results<Quarter>!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func add(_ sender: Any) {
        self.performSegue(withIdentifier: "addQuarter", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.quarters = self.realm.objects(Quarter.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.quarters = self.realm.objects(Quarter.self)
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "listCourses" {
            
        }
        else {
            if segue.identifier == "addQuarter" {
                
            }
            else if segue.identifier == "editQuarter" {
                
            }
        }
    }
 
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.quarters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuarterCell", for: indexPath) as! QuarterTableViewCell
        
        let quarter = quarters[indexPath.row]
        
        cell.title!.text = quarter.title
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "d/M/yy"
        cell.dates!.text = "\(formatter.string(from: quarter.startDate)) to \(formatter.string(from: quarter.endDate))"
        
        
        let count = self.realm.objects(Course.self).filter("quarter = '\(quarter.title)'").count
        cell.numCourses!.text = "\(count) courses"
        
        
        cell.current.backgroundColor = quarter.current ? UIColor.green : UIColor.clear
        cell.current.layer.cornerRadius = cell.current.frame.size.width / 2
        cell.current.clipsToBounds = true
        
        return cell
    }
}
