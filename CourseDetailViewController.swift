//
//  NoteDetailViewController.swift
//  TMA
//
//  Created by Abdulrahman Sahmoud on 2/1/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import Charts

class CourseDetailViewController: UIViewController {

    @IBOutlet weak var NoteContent: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    
    var course: Course!
    var weekDays: [String]!
    
    // Setting the Chart Data here
    func setChar(data: [String], values: [Double]){
        

        
        barChartView.noDataText = "data needs to be provided for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<data.count{
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i], data: data[i] as AnyObject?)
            //x: Double(i), yValues: values, label: data[i])
            
            dataEntries.append(dataEntry)
            
        }
        
        barChartView.descriptionText = ""
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
        
        weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday","Sunday"]
        //hardcoding the hours for now
        let studyHours = [5.0, 10.0, 6.0, 8.0, 3.0, 12.0, 7.0]
        
        setChar(data: weekDays, values: studyHours)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        NoteContent.text = course.name
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
