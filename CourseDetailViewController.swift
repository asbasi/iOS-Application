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


    @IBOutlet weak var circularProgressView: KDCircularProgress!
    
    @IBOutlet weak var precentageText: UILabel!
   
    let maxCount = 100
    let realm = try! Realm()
    
    var allTypesOfCharts = [([String],[Double])]() //names,values
    
    @IBAction func segmentChanged(_ sender: Any) {
        let (a,b) =  allTypesOfCharts[segmentController.selectedSegmentIndex]
        
        setChar(data: a, values: b)
    }
    
    var course: Course!
    
    // Setting the Chart Data here
    func setChar(data: [String], values: [Double]){
        barChartView.noDataText = "data needs to be provided for the chart."
        
        var dataEntries: [BarChartDataEntry] = []
        let week = ["Mon", "Tue", "Wed", "Thur", "Fri", "Sat", "Sun"]
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: week)
        
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
    
    func setAngle() -> Void {
        // The value of precentageText should to be the hours assigned for the day
        // and then the value of toAngle has to relate to that value
        
        var percentage = Helpers.add_duration(events: self.realm.objects(Log.self))/Helpers.add_duration(events: self.realm.objects(Event.self))
        var angle = 360 * percentage
            
        circularProgressView.animate(toAngle: Double(angle), duration: 0.5, completion: nil)
        percentageLabel.text = "\(Int(percentage * 100))%"
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO DO THESE TOO
        
        //hardcoding the hours for now
        var studyHours = [Double]()
        
        circularProgressView.angle = 0
        setAngle()
        
        var components = DateComponents()
        components.second = -1
        var weekDays = [String]()
        

        //weekly
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
        allTypesOfCharts.append((weekDays,studyHours))
        
        
        //monthly
        studyHours = [Double]()
        for offsetDay in [28,21,14,7]{
            let calendar = Calendar.current
            let start = calendar.date(byAdding: .day, value: offsetDay * -1, to: Date())!
            let end = calendar.date(byAdding: .day, value: (offsetDay - 8 ) * -1, to: Date())!
            
            let x = self.realm.objects(Log.self).filter("date BETWEEN %@", [start.startOfDay,end.startOfDay])
            
            studyHours.append(0)
            for element in x {
                studyHours[studyHours.endIndex-1] += Double(element.duration)
            }
            
        }
        allTypesOfCharts.append((["1","2","3","4"],studyHours))
        
        
        
        
        //draw circle
//        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 200,y: 200), radius: CGFloat(85), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
//        
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.path = circlePath.cgPath
//        
//        //change the fill color
//        shapeLayer.fillColor = UIColor.clear.cgColor
//        //you can change the stroke color
//        shapeLayer.strokeColor = UIColor.red.cgColor
//        //you can change the line width
//        shapeLayer.lineWidth = 3.0
//        
//        view.layer.addSublayer(shapeLayer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        NoteContent.text = course.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
