//
//  QuarterStatsViewController.swift
//  TMA
//
//  Created by Minjie Tan on 5/3/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class QuarterStatsViewController: UIViewController {
    
    
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var lineChart: LineChartView!

    let realm = try! Realm()
    var quarter: Quarter!
    
    func populateGraphs() {
        pieChart.descriptionText = ""
        pieChart.noDataText = "No Data."
        pieChart.legend.enabled = false
        
        let courses = self.realm.objects(Course.self).filter("quarter.title = '\(self.quarter.title!)'")
        var courseTitles = [String]()
        var sumOfLogHours = [Double]()
        for course in courses {
            courseTitles.append(course.identifier)
            
            let logs = self.realm.objects(Log.self).filter("course.identifier = '\(course.identifier!)'")
            var sum = 0.0
            for log in logs {
                sum += Double(log.duration)
            }
            sumOfLogHours.append(sum)
        }
        
        var filteredCourseTitles = [String]()
        var filteredSumOfLogHours = [Double]()
        for i in 0...courseTitles.count-1 {
            if sumOfLogHours[i] != 0 {
                filteredCourseTitles.append(courseTitles[i])
                filteredSumOfLogHours.append(sumOfLogHours[i])
            }
        }
        
        setPieChart(dataPoints: filteredCourseTitles, values: filteredSumOfLogHours)
        
    }
    func setPieChart(dataPoints: [String], values: [Double]) {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateGraphs()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
