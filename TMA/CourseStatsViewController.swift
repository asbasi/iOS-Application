//
//  CourseGraphViewController.swift
//  TMA
//
//  Created by Minjie Tan on 4/26/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class CourseStatsViewController: UIViewController {
    
    @IBOutlet weak var pieChart: PieChartView!
    let realm = try! Realm()
    var course: Course!
    
    
    // ****************************************************************
    // **                 populateGraphs from the database           **
    // ****************************************************************
    func populateGraphs(){
        
        var studyHours = [Double]()
        pieChart.descriptionText = ""
        pieChart.legend.enabled = false
        let types = ["Study", "Homework", "Project", "Lab", "Other"]
        
        // Get a list of all the log for the course from the database
        var sumOfLogHours = [Double]()
        for i in 0...types.count-1 {
            let logs = self.realm.objects(Log.self).filter("type = \(i) AND course.identifier = '\(self.course.identifier!)'")
            var sum = 0.0
            for log in logs {
                sum += Double(log.duration)
            }
            sumOfLogHours.append(sum)
        }
        
        
        //filter types and sumOfLogHours so we don't have 0's
        var filteredTypes = [String]()
        var filteredSumOfLogHours = [Double]()
        for i in 0...types.count-1 {
            if sumOfLogHours[i] != 0 {
                filteredTypes.append(types[i])
                filteredSumOfLogHours.append(sumOfLogHours[i])
            }
        }
        
        
        // dummy values will be deleted
//        let unitSold = [20.0, 4.0, 6.0, 3.0, 12.0]
        
        setChart(dataPoints: filteredTypes, values: filteredSumOfLogHours)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateGraphs()
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        pieChart.entryLabelColor = UIColor.black
        
        
        var dataEntries: [PieChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: values[i], label: dataPoints[i])
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChart.data = pieChartData
        
        
        pieChartDataSet.colors = ChartColorTemplates.joyful()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
