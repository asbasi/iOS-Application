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
    var courseIdentifier: String!
    
    @IBOutlet weak var chart: VBPieChart!
    
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
    
    func setPieChart() {
        self.view.addSubview(chart);
        
        let allLogs = self.realm.objects(Log.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true")
        
        chart.holeRadiusPrecent = 0.3;
        
        let total = Helpers.add_duration(events: allLogs)
        
        let studyingLogs = self.realm.objects(Log.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true AND type == \(STUDY_EVENT)")
        let studyingMins = Helpers.add_duration(events: studyingLogs)
        
        let homeworkLogs = self.realm.objects(Log.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true AND type == \(HOMEWORK_EVENT)")
        let homeworkMins = Helpers.add_duration(events: homeworkLogs)
        
        let projectLogs = self.realm.objects(Log.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true AND type == \(PROJECT_EVENT)")
        let projectMins = Helpers.add_duration(events: projectLogs)

        let labLogs = self.realm.objects(Log.self).filter("course.identifier = '\(self.course.identifier!)' AND course.quarter.current = true AND type == \(LAB_EVENT)")
        let labMins = Helpers.add_duration(events: labLogs)
        
        let otherMins = total - studyingMins - homeworkMins - projectMins - labMins

        let chartValues = [ ["name":"Studying", "value": (studyingMins / total) * 100.0, "color":UIColor.red],
                            ["name":"Homework", "value": (homeworkMins / total) * 100.0, "color":UIColor.blue],
                            ["name":"Projects", "value": (projectMins / total) * 100.0, "color":UIColor.green],
                            ["name":"Labs", "value": (labMins / total) * 100.0, "color":UIColor.cyan],
                            ["name":"Other", "value": (otherMins / total) * 100.0, "color":UIColor.lightGray]
        ];
        
        chart.setChartValues(chartValues as [AnyObject], animation:true);
    }
}
