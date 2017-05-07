//
//  CourseGraphViewController.swift
//  TMA
//
//  Created by Arvinder Basi on 5/6/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import VBPieChart
import RealmSwift

class CourseStatsViewController: UIViewController {
    let realm = try! Realm()
    var course: Course!
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.populateCharts()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func populateCharts()
    {
        // Do any additional setup after loading the view.
        
        setPieChart();
        
    }
    
    let chart = VBPieChart()
    
    func setPieChart() {
        self.view.addSubview(chart);
        
        let allLogs = self.realm.objects(Log.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true")
        
        chart.frame = CGRect(x: 10, y: 50, width: 300, height: 300);
        chart.holeRadiusPrecent = 0.3;
        
        let total = Helpers.add_duration(events: allLogs)
        print(total)
        
        let studyingLogs = self.realm.objects(Log.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true AND type == \(STUDY_EVENT)")
        let studyingHours = Helpers.add_duration(events: studyingLogs) / total
        print(studyingHours)
        
        let otherHours = (total - studyingHours ) / total
        print(otherHours)
        
        let chartValues = [ ["name":"Studying", "value": studyingHours, "color":UIColor.red],
                         /*   ["name":"Homework", "value": 20, "color":UIColor.blue],
                            ["name":"Projects", "value": 40, "color":UIColor.green],
                            ["name":"Labs", "value": 70, "color":UIColor.cyan],*/
                            ["name":"Other", "value": otherHours, "color":UIColor.lightGray]
        ];
        
        chart.setChartValues(chartValues as [AnyObject], animation:true);
    }
}
