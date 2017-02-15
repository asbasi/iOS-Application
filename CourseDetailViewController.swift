//
//  CourseDetailViewController.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/1/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class CourseDetailViewController: UIViewController {

    @IBOutlet weak var NoteContent: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    
    let realm = try! Realm()
    
    var course: Course!
    var weekDays = [String]()
    
    // Setting the Chart Data here
    func setChar(data: [String], values: [Double]){
        barChartView.noDataText = "data needs to be provided for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<data.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i], data: data[i] as AnyObject?)
            //x: Double(i), yValues: values, label: data[i])
            
            dataEntries.append(dataEntry)
            
        }
        
        barChartView.chartDescription?.text = ""
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
//        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
//        chartDataSet.colors = ChartColorTemplates.colorful()
        
        let ll = ChartLimitLine(limit: 10.0, label: "Target")
        barChartView.rightAxis.addLimitLine(ll)
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Studyhours")
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        
        barChartView.xAxis.labelPosition = .bottom
        let chartData = BarChartData()
        chartData.addDataSet(chartDataSet)
        barChartView.data = chartData
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO DO THESE TOO
        
        //hardcoding the hours for now
        var studyHours = [Double]()
        
        var components = DateComponents()
        components.second = -1
        
        
        
        for offsetDay in [6,5,4,3,2,1,0]{
            let calendar = Calendar.current
            let nDaysAgo = calendar.date(byAdding: .day, value: offsetDay * -1, to: Date())!
            
            let x = self.realm.objects(Log.self).filter("date BETWEEN %@", [nDaysAgo.startOfDay,nDaysAgo.endOfDay])
            
            studyHours.append(0)
            for element in x {
                studyHours[studyHours.endIndex-1] += Double(element.duration)
            }
            
            weekDays.append(nDaysAgo.dayOfTheWeek()!)
        }
        
        setChar(data: weekDays, values: studyHours )
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        NoteContent.text = course.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
