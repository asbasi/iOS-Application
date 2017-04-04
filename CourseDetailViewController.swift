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
import KDCircularProgress

@objc(BarChartFormatter)


class Ring:UIButton
{
    let realm = try! Realm()
    var percentage: Float!
    override func draw(_ rect: CGRect)
    {
        let all_logs = self.realm.objects(Log.self)
        let all_planner = self.realm.objects(Event.self)
        
        percentage = 100 * Helpers.add_duration(events: all_logs)/Helpers.add_duration(events: all_planner)
        
        
        drawRingFittingInsideView()
        
        let path = UIBezierPath(ovalIn: rect)
        UIColor.green.setFill()
        path.fill()
        self.setTitle("\(percentage!)%", for: .normal)
    }
    
    internal func drawRingFittingInsideView()->()
    {
        let halfSize:CGFloat = min( bounds.size.width/2, bounds.size.height/2)
        let desiredLineWidth:CGFloat = 3    // your desired value
        
        let angle = (Double(percentage) / 100) * .pi * 2
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x:halfSize,y:halfSize),
            radius: CGFloat( halfSize - (desiredLineWidth/2) ),
            startAngle: CGFloat(0),
            endAngle:CGFloat(angle),
            clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = desiredLineWidth
        
        layer.addSublayer(shapeLayer)
    }
}

class CourseDetailViewController: UIViewController {
    
    
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var segmentController: UISegmentedControl!
    @IBOutlet weak var barChartView: BarChartView!
    
    @IBOutlet weak var circularProgressView: KDCircularProgress!
    
    @IBOutlet weak var precentageText: UILabel!
    
    let maxCount = 100
    let realm = try! Realm()
    
    var allTypesOfCharts = [([String],[Double],[Double])]() //[([names],[log],[goals])]
    
    @IBAction func segmentChanged(_ sender: Any) {
        let (names,logHours,goalHours) =  allTypesOfCharts[segmentController.selectedSegmentIndex]
        
        setChar(data: names, values: logHours, golValues: goalHours)
    }
    
    var course: Course!
    
    // Setting the Chart Data here
    func setChar(data: [String], values: [Double], golValues: [Double]){
        barChartView.noDataText = "data needs to be provided for the chart."
        print("we are in setChar")
        print(data)
        
        var golaDataEntries: [BarChartDataEntry] = []
        var studyHoursDataEntries: [BarChartDataEntry] = []
        
        
        // Setting the X-Axis of the weekly Chart to String
        if data.count == 7{
            
            for i in 0..<data.count{
                print(data[i])
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i], data: data[i] as AnyObject?)
                studyHoursDataEntries.append(dataEntry)
                
                
                let dataEntry1 = BarChartDataEntry(x: Double(i), y: golValues[i], data: data[i] as AnyObject?)
                golaDataEntries.append(dataEntry1)
                
            }
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: data)
            
        }
        else{
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: data)
            for i in 0..<data.count{
                
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i], data: data[i] as AnyObject?)
                studyHoursDataEntries.append(dataEntry)
                
                let dataEntry1 = BarChartDataEntry(x: Double(i), y: golValues[i], data: data[i] as AnyObject?)
                golaDataEntries.append(dataEntry1)
                
            }
        }
        
        barChartView.chartDescription?.text = ""
        barChartView.animate(xAxisDuration: 0.1, yAxisDuration: 0.1)
        
        //        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        //        chartDataSet.colors = ChartColorTemplates.colorful()
        
        // let ll = ChartLimitLine(limit: 10.0, label: "Target")
        // barChartView.rightAxis.addLimitLine(ll)
        
        let chartDataSet = BarChartDataSet(values: studyHoursDataEntries, label: "Study Hours")
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        
        let chartDataSet1 = BarChartDataSet(values: golaDataEntries, label: "Planned Hours")
        chartDataSet1.colors = [UIColor(red: 30/255, green: 126/255, blue: 220/255, alpha: 1)]
        
        barChartView.xAxis.labelPosition = .bottom
        
        let dataSets: [BarChartDataSet] = [chartDataSet,chartDataSet1]
        
        let chartData = BarChartData(dataSets: dataSets)
        
        let groupSpace = 0.3        // space between each days data
        let barSpace = 0.05             // space between goals and logs
        let barWidth = 0.3
        
        let groupCount = data.count
        let startWeek = -0.5
        
        chartData.barWidth = barWidth
        
        barChartView.xAxis.axisMinimum = Double(startWeek)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        barChartView.xAxis.axisMaximum = Double(startWeek) + gg * Double(groupCount)
        
        chartData.groupBars(fromX: Double(startWeek), groupSpace: groupSpace, barSpace: barSpace)
        
        chartData.setDrawValues(false)
        barChartView.notifyDataSetChanged()
        
        //        chartData.addDataSet(chartDataSet)
        barChartView.data = chartData
        
        //background color
        //        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        
        //chart animation
        //        barChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)
        
    }
    
    func setAngle() -> Void {
        
        let nominator = Float(Helpers.add_duration(events: self.realm.objects(Log.self).filter("course.quarter.title = '\(course.quarter.title!)' AND course.identifier = '\(course.identifier!)'")))
        let denominator = Float(Helpers.add_duration(events: self.realm.objects(Event.self).filter("course.quarter.title = '\(course.quarter.title!)' AND course.identifier = '\(course.identifier!)'")))
        var percentage = 100.0
        
        percentage = (denominator != 0.0) ? Double(nominator / denominator) : Double(nominator)
        
        let angle = percentage > 1 ? 360 : 360 * percentage
        
        circularProgressView.animate(toAngle: Double(angle), duration: 0.5, completion: nil)
        percentageLabel.text = "\(Int(round(percentage*100)))%"
    }
    
    func populateGraphs()
    {
        allTypesOfCharts = [([String],[Double],[Double])]()
        
        var logHours = [Double]()
        var studyHours = [Double]()
        
        circularProgressView.angle = 0
        setAngle()
        
        var components = DateComponents()
        components.second = -1
        var weekDays = [String]()
        var monthDays = [String]()
        

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //weekly
        for offsetDay in [6,5,4,3,2,1,0]{
            let calendar = Calendar.current
            let nDaysAgo = calendar.date(byAdding: .day, value: offsetDay * -1, to: Date())!
            
            let x = self.realm.objects(Log.self).filter("course.quarter.title = '\(course.quarter.title!)' AND course.identifier = '\(course.identifier!)' AND date BETWEEN %@", [nDaysAgo.startOfDay,nDaysAgo.endOfDay])
            let x1 = self.realm.objects(Event.self).filter("course.quarter.title = '\(course.quarter.title!)' AND course.identifier = '\(course.identifier!)' AND date BETWEEN %@", [nDaysAgo.startOfDay,nDaysAgo.endOfDay])
            
            logHours.append(0)
            for element in x {
                logHours[logHours.endIndex-1] += Double(element.duration)
            }
            weekDays.append(nDaysAgo.dayOfTheWeek()!)
            
            studyHours.append(0)
            for element in x1 {
                studyHours[studyHours.endIndex-1] += Double(element.duration)
            }
            
        }
        setChar(data: weekDays, values: logHours, golValues: studyHours)
        allTypesOfCharts.append((weekDays,logHours, studyHours))
        
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //monthly
        
        logHours = [Double]()
        studyHours = [Double]()
        for offsetDay in [30,29,28,27,26,25,24,23,22,21,20,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0] {
            let calendar = Calendar.current
            let nDaysAgo = calendar.date(byAdding: .day, value: offsetDay * -1, to: Date())!
            
            let hoursLogged = self.realm.objects(Log.self).filter("course.quarter.title = '\(course.quarter.title!)' AND course.identifier = '\(course.identifier!)' AND date BETWEEN %@", [nDaysAgo.startOfDay,nDaysAgo.endOfDay])
            let setGoals = self.realm.objects(Event.self).filter("course.quarter.title = '\(course.quarter.title!)'  AND course.identifier = '\(course.identifier!)' AND date BETWEEN %@", [nDaysAgo.startOfDay,nDaysAgo.endOfDay])
            
            logHours.append(0)
            for element in hoursLogged {
                logHours[logHours.endIndex-1] += Double(element.duration)
            }
            
            studyHours.append(0)
            for element in setGoals {
                studyHours[studyHours.endIndex-1] += Double(element.duration)
            }
            
            monthDays.append(nDaysAgo.dayOfTheMonth()!) // want a number
        }
        
        allTypesOfCharts.append((monthDays,logHours, studyHours))
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        populateGraphs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        populateGraphs()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
