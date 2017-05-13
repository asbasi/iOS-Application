//
//  QuarterStatsViewController.swift
//  TMA
//
//  Created by Minjie Tan on 5/3/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import Charts
import PieCharts
import RealmSwift

class QuarterStatsViewController: UIViewController {
    let realm = try! Realm()
    var quarter: Quarter!
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
        // Do any additional setup after loading the view.
        
        setPieChart();
        
    }
    
    func onSelected(slice: PieSlice, selected: Bool) {
        print("Selected: \(selected), slice: \(slice)")
    }
    
    func setPieChart() {
        
        let alpha: CGFloat = 0.1
        
        var labels: [String] = []
        
        let courses = self.realm.objects(Course.self).filter("quarter.title = '\(quarter.title!)'")
        
        var total: Float = 0.0
        for course in courses {
            total += Helpers.add_duration_studied(for: course, in: quarter)
        }
        
        if total != 0.0 {
            var models: [PieSliceModel] = [PieSliceModel]()

            for course in courses {
                let mins = Helpers.add_duration_studied(for: course, in: quarter)
                if mins > 0.0 {
                    let color = course.color == "None" ? colorMappings["Blue"] : colorMappings[course.color]
                    models.append(PieSliceModel(value: Double((mins / total) * 100), color: color!))
                    labels.append(course.identifier!)
                }
            }
            pieChart.models = models
        }
        else {
            pieChart.models = [PieSliceModel(value: 100, color: UIColor.cyan.withAlphaComponent(alpha))]
            labels = ["None"]
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

}
