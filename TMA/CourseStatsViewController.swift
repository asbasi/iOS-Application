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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        //pieChart.delegate = self as! ChartViewDelegate
        pieChart.descriptionText = ""
        pieChart.legend.enabled = false
        
        let types = ["Study", "Homework", "Project", "Lab", "Other"]

        let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0]
        
        setChart(dataPoints: types, values: unitsSold)
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        
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
