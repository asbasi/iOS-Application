//
//  CourseGraphViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 5/6/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import PieCharts
import Charts
import RealmSwift

class CourseStatsViewController: UIViewController, PieChartDelegate {
    let realm = try! Realm()
    var course: Course!
    var courseIdentifier: String!
    
    @IBOutlet weak var pieChart: PieChart!

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.populateCharts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func populateCharts()
    {
     
        /*
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
        
        
        let allLogs = self.realm.objects(Event.self).filter("course.identifier = '\(self.course.identifier!)'")
        let allEvents = self.realm.objects(Event.self).filter("course.identifier = '\(self.course.identifier!)' AND isSchedule = false")
        
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
        
        setLineChart(dataPoints: dayString, values1: logHours, values2: eventHours)*/
        
        
        setPieChart();
        
    }
    
    func onSelected(slice: PieSlice, selected: Bool) {
        print("Selected: \(selected), slice: \(slice)")
    }
    
    func setPieChart() {
        
        let alpha: CGFloat = 0.1

        var labels: [String] = []
        
        let allEvents = self.realm.objects(Event.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true")
        let total = Helpers.add_duration_studied(events: allEvents)
        
        if total != 0.0 {
            var models: [PieSliceModel] = [PieSliceModel]()
            
            let colors: [UIColor] = [UIColor.red.withAlphaComponent(alpha), UIColor.blue.withAlphaComponent(alpha), UIColor.green.withAlphaComponent(alpha), UIColor.purple.withAlphaComponent(alpha), UIColor.lightGray.withAlphaComponent(alpha)]
            
            let tags: [String] = ["Studying", "Homework", "Projects", "Labs", "Other"]
            
            for type in 0...4 {
                let events = self.realm.objects(Event.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true AND type == \(type)")
                let mins = Helpers.add_duration_studied(events: events)
                if mins > 0.0 {
                    models.append(PieSliceModel(value: Double((mins / total) * 100), color: colors[type]))
                    labels.append(tags[type])
                }
            }
            pieChart.models = models
        }
        else {
            pieChart.models = [PieSliceModel(value: 100, color: UIColor.cyan.withAlphaComponent(alpha))]
            labels = ["Free!"]
        }
        pieChart.layers = [createTextLayer(), createTextWithLinesLayer(labels)]
    }
    
    fileprivate func createTextLayer() -> PiePlainTextLayer {
        let textLayerSettings = PiePlainTextLayerSettings()
        textLayerSettings.viewRadius = 60
        textLayerSettings.hideOnOverflow = true
        textLayerSettings.label.font = UIFont.systemFont(ofSize: 12)
        
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        textLayerSettings.label.textGenerator = {slice in
            let string = formatter.string(from: slice.data.percentage * 100 as NSNumber).map{"\($0)%"} ?? ""
            return string == "0%" ? "" : string
        }
        
        let textLayer = PiePlainTextLayer()
        textLayer.settings = textLayerSettings
        return textLayer
    }
    
    fileprivate func createTextWithLinesLayer(_ labels: [String]) -> PieLineTextLayer {
        let lineTextLayer = PieLineTextLayer()
        var lineTextLayerSettings = PieLineTextLayerSettings()
        lineTextLayerSettings.lineColor = UIColor.lightGray
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 1
        lineTextLayerSettings.label.font = UIFont.systemFont(ofSize: 14)
        
        lineTextLayerSettings.label.textGenerator = {slice in

            return labels[slice.hashValue]
        }
        
        lineTextLayer.settings = lineTextLayerSettings
        return lineTextLayer
    }
    
    /*
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
        let dataSets: [LineChartDataSet] = [eventDataSet, logDataSet]
        let lineData: LineChartData = LineChartData(dataSets: dataSets)
        self.lineChart.data = lineData
        self.lineChart.doubleTapToZoomEnabled = false
        self.lineChart.drawGridBackgroundEnabled = false
        self.lineChart.drawBordersEnabled = true
        
    }
    */
}
