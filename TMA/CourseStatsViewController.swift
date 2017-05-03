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
    @IBOutlet weak var lineChart: LineChartView!
    let realm = try! Realm()
    var course: Course!
    
    weak var axisFormatDelegate: IAxisValueFormatter?
    
    // ****************************************************************
    // **                 populateGraphs from the database           **
    // ****************************************************************
    func populateGraphs(){
        
        pieChart.descriptionText = ""
        pieChart.noDataText = "No Data."
        pieChart.legend.enabled = false
        let types = ["Study", "Homework", "Project", "Lab", "Other"]
        
        lineChart.descriptionText = ""
        lineChart.noDataText = "No Data."
        
        //get all the logs and events for the course
        
        let startDay = course.quarter.startDate
        var endDay = Date()
        if(Date.daysBetween(start: endDay, end: course.quarter.startDate) > 0)
        {
            endDay = course.quarter.endDate
        }
        let days = Date.daysBetween(start: startDay!, end: endDay)
        
        var dayString = [String]()
        var oneDay = startDay
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "US_en")
        formatter.dateFormat = "M/d"
        
        
        let allLogs = self.realm.objects(Log.self).filter("course.identifier = '\(self.course.identifier!)'")
        let allEvents = self.realm.objects(Event.self).filter("course.identifier = '\(self.course.identifier!)'")
        
        var logHours = [Double]()
        var eventHours = [Double]()
        
        
        for i in 0...days {
            var lhours = 0.0
            var ehours = 0.0
            dayString.append(formatter.string(from:oneDay!))
            oneDay = oneDay?.addingTimeInterval(86400)
            for log in allLogs {
                if(Date.daysBetween(start: startDay!, end: log.date) == i) {
                    lhours += Double(log.duration)
                }
            }
            for event in allEvents {
                if(Date.daysBetween(start: startDay!, end: event.date) == i) {
                    ehours += Double(event.duration)
                }
            }
            logHours.append(lhours)
            eventHours.append(ehours)
        }
        
        setLineChart(dataPoints: dayString, values1: logHours, values2: eventHours)
        
        // Get a list of all the log for the course from the database #pieChart
        var sumOfLogHours = [Double]()
        for i in 0...types.count-1 {
            let logs = self.realm.objects(Log.self).filter("type = \(i) AND course.identifier = '\(self.course.identifier!)'")
            var sum = 0.0
            for log in logs {
                sum += Double(log.duration)
            }
            
            sumOfLogHours.append(sum)
        }
        
        
        //filter types and sumOfLogHours so we don't have 0's #pieChart
        var filteredTypes = [String]()
        var filteredSumOfLogHours = [Double]()
        for i in 0...types.count-1 {
            if sumOfLogHours[i] != 0 {
                filteredTypes.append(types[i])
                filteredSumOfLogHours.append(sumOfLogHours[i])
            }
        }
        
        setPieChart(dataPoints: filteredTypes, values: filteredSumOfLogHours)
//        let unitSold = [20.0, 4.0, 6.0, 3.0, 12.0]
//        setPieChart(dataPoints: types, values: unitSold)
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
    
    func setLineChart(dataPoints: [String], values1: [Double], values2: [Double]) {
        var dataEntries1: [ChartDataEntry] = []
        var dataEntries2: [ChartDataEntry] = []
        for i in 0..<values1.count {
            let dataEntry1 = ChartDataEntry(x: Double(i), y: values1[i])
            dataEntries1.append(dataEntry1)
            let dataEntry2 = ChartDataEntry(x: Double(i), y: values2[i])
            dataEntries2.append(dataEntry2)
        }
        self.lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values:dataPoints)
        self.lineChart.xAxis.granularity = 1
        let logDataSet = LineChartDataSet(values: dataEntries1, label: "Studied Hours")
        logDataSet.axisDependency = .left
        logDataSet.setColor(UIColor.green)
        logDataSet.setCircleColor(UIColor.green)
        logDataSet.circleRadius = 0.5
        logDataSet.lineWidth = 2.3
        logDataSet.drawValuesEnabled = false
        let eventDataSet = LineChartDataSet(values: dataEntries2, label: "Allocated Hours")
        eventDataSet.axisDependency = .left
        eventDataSet.setColor(UIColor.red)
        eventDataSet.circleRadius = 0.5
        eventDataSet.lineWidth = 2.3
        eventDataSet.drawValuesEnabled = false
        eventDataSet.setCircleColor(UIColor.red)
        let dataSets: [LineChartDataSet] = [logDataSet, eventDataSet]
        let lineData: LineChartData = LineChartData(dataSets: dataSets)
        self.lineChart.data = lineData
        self.lineChart.doubleTapToZoomEnabled = false
        self.lineChart.drawGridBackgroundEnabled = false
        self.lineChart.drawBordersEnabled = true
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //axisFormatDelegate = self as! IAxisValueFormatter
        populateGraphs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}
