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
            let dataEntry = BarChartDataEntry(x: Double(i), yValues: values)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Studyhours")
//        let charData = BarChartData(xVals: weekDays, dataSets: chartDataSet)
//        barChartView.data = charData
        
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
