//
//  CourseGraphViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 5/6/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import PieCharts
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
        // Do any additional setup after loading the view.
        
        setPieChart();
        
    }
    
    func onSelected(slice: PieSlice, selected: Bool) {
        print("Selected: \(selected), slice: \(slice)")
    }
    
    func setPieChart() {
        
        let alpha: CGFloat = 0.1

        var labels: [String] = []
        
        let allLogs = self.realm.objects(Log.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true")
        let total = Helpers.add_duration(events: allLogs)
        
        if total != 0.0 {
            var models: [PieSliceModel] = [PieSliceModel]()
            
            let colors: [UIColor] = [UIColor.red.withAlphaComponent(alpha), UIColor.blue.withAlphaComponent(alpha), UIColor.green.withAlphaComponent(alpha), UIColor.purple.withAlphaComponent(alpha), UIColor.lightGray.withAlphaComponent(alpha)]
            
            let tags: [String] = ["Studying", "Homework", "Projects", "Labs", "Other"]
            
            for type in 0...4 {
                let logs = self.realm.objects(Log.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true AND type == \(type)")
                let mins = Helpers.add_duration(events: logs)
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
}
