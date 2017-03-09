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
        
        let angle = (Double(percentage) / 100) * M_PI * 2
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
    let week = ["Sun", "Mon", "Tue", "Wed", "Thur", "Fri", "Sat"]

    @IBOutlet weak var circularProgressView: KDCircularProgress!
    
    @IBOutlet weak var precentageText: UILabel!
   
    let maxCount = 100
    let realm = try! Realm()
    
    var allTypesOfCharts = [([String],[Double])]() //names,values
    
    @IBAction func segmentChanged(_ sender: Any) {
        let (a,b) =  allTypesOfCharts[segmentController.selectedSegmentIndex]
        let c = 1.0
        setChar(data: a, values: b, values1: [c])
    }
    
    var course: Course!
    
    // Setting the Chart Data here
    func setChar(data: [String], values: [Double], values1: [Double]){
        barChartView.noDataText = "data needs to be provided for the chart."
        
        var dataEntries1: [BarChartDataEntry] = []

        var dataEntries: [BarChartDataEntry] = []
        
        
        // Setting the X-Axis of the weekly Chart to String
        if data.count == 7{
            let week = ["Sun", "Mon", "Tue", "Wed", "Thur", "Fri", "Sat"]
//            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: week)
            for i in 0..<data.count{
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i], data: data[i] as AnyObject?)
                dataEntries.append(dataEntry)
                
                /*let dataEntry1 = BarChartDataEntry(x: Double(i), y: values1[i], data: data[i] as AnyObject?)
                dataEntries1.append(dataEntry1)*/
                
            }
        }
        else{
            var months = [String](repeating: "", count: 30)
            for i in 1..<months.count{
                months[i-1] += String(i)
            }
            
            barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: months)
            for i in 0..<months.count{
                let dataEntry = BarChartDataEntry(x: Double(i), y: values[i], data: data[i] as AnyObject?)
                dataEntries.append(dataEntry)
                
            /*let dataEntry1 = BarChartDataEntry(x: Double(i), y: values1[i], data: data[i] as AnyObject?)
                dataEntries1.append(dataEntry1)*/
                
            }
        }

        barChartView.chartDescription?.text = ""
        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
//        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
//        chartDataSet.colors = ChartColorTemplates.colorful()
        
        let ll = ChartLimitLine(limit: 10.0, label: "Target")
        barChartView.rightAxis.addLimitLine(ll)
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Studyhours")
        chartDataSet.colors = [UIColor(red: 230/255, green: 126/255, blue: 34/255, alpha: 1)]
        
        let chartDataSet1 = BarChartDataSet(values: dataEntries1, label: "Goal")
        chartDataSet1.colors = [UIColor(red: 30/255, green: 126/255, blue: 220/255, alpha: 1)]
        
        barChartView.xAxis.labelPosition = .bottom
        
        let dataSets: [BarChartDataSet] = [chartDataSet,chartDataSet1]
        
        let chartData = BarChartData(dataSets: dataSets)
        
        
//        let chartData = BarChartData()
        let groupSpace = -0.05
        let barSpace = 0.05
        let barWidth = 0.10
        
        let groupCount = self.week.count
        let startWeek = 0
        
        chartData.barWidth = barWidth
        
        barChartView.xAxis.axisMinimum = Double(startWeek)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        barChartView.xAxis.axisMaximum = Double(startWeek) + gg * Double(groupCount)
        
        chartData.groupBars(fromX: Double(startWeek), groupSpace: groupSpace, barSpace: barSpace)
        
        //chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        barChartView.notifyDataSetChanged()

//        chartData.addDataSet(chartDataSet)
        barChartView.data = chartData
        
        //background color
//        barChartView.backgroundColor = UIColor(red: 189/255, green: 195/255, blue: 199/255, alpha: 1)
        
        //chart animation
        barChartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: .linear)

    }
    
    func setAngle() -> Void {

        let nominator = Float(Helpers.add_duration(events: self.realm.objects(Log.self)))
        let denominator  = Float(Helpers.add_duration(events: self.realm.objects(Event.self)))
        var percentage = 100.0
        
        if denominator != 0{
            percentage = Double(Int(nominator*10) / Int(denominator))
        }

        let angle = 360 * (percentage/10)
            
        circularProgressView.animate(toAngle: Double(angle), duration: 0.5, completion: nil)
        percentageLabel.text = "\(Int(percentage * 10))%"
    }
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        var studyHours = [Double]()
        var goals = [Double]()
        
        circularProgressView.angle = 0
        setAngle()
        
        var components = DateComponents()
        components.second = -1
//        var weekDays = [String]()
        var months = [String](repeating: "", count: 30)

        //weekly
        for offsetDay in [6,5,4,3,2,1,0]{
            let calendar = Calendar.current
            let nDaysAgo = calendar.date(byAdding: .day, value: offsetDay * -1, to: Date())!
            
            let x = self.realm.objects(Log.self).filter("date BETWEEN %@", [nDaysAgo.startOfDay,nDaysAgo.endOfDay])
            let x1 = self.realm.objects(Event.self).filter("date BETWEEN %@", [nDaysAgo.startOfDay,nDaysAgo.endOfDay])
            
            studyHours.append(0)
            for element in x {
                studyHours[studyHours.endIndex-1] += Double(element.duration)
            }
//            weekDays.append(nDaysAgo.dayOfTheWeek()!)
            
            goals.append(0)
            for element in x1 {
                goals[goals.endIndex-1] += Double(element.duration)
            }
            
//            goals.append(nDaysAgo.dayOfTheWeek()!)
        }
        setChar(data: week, values: studyHours, values1: goals)
        allTypesOfCharts.append((week,studyHours))
        
        
        //monthly

        studyHours = [Double]()
        for offsetDay in [ 8, 7, 6, 5, 4, 3, 2, 1]{//[28,21,14,7]{
            let calendar = Calendar.current
            let start = calendar.date(byAdding: .day, value: offsetDay * -1, to: Date())!
            let end = calendar.date(byAdding: .day, value: (offsetDay - 8 ) * -1, to: Date())!
            
            let hoursLogged = self.realm.objects(Log.self).filter("date BETWEEN %@", [start.startOfDay,end.startOfDay])
            let settedGoal = self.realm.objects(Event.self).filter("date BETWEEN %@", [start.startOfDay,end.startOfDay])
            
            for _ in 1..<31 {
                studyHours.append(0)
            }
            
            //studyHours.append(0)
            for element in hoursLogged {
                studyHours[studyHours.endIndex-1] += Double(element.duration)
            }
            
            for _ in 1..<31 {
                goals.append(0)
            }

            for element in settedGoal {
                goals[goals.endIndex-1] += Double(element.duration)
            }
        }

        
        // x index for month graph from 1..30
        for i in 1..<months.count+1{
            months[i-1] += String(i)
        }

        allTypesOfCharts.append((months, studyHours))
    
    }

    override func viewWillAppear(_ animated: Bool) {
//        NoteContent.text = course.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
