//
//  QuarterStatsViewController.swift
//  TMA
//
//  Created by Minjie Tan on 5/3/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import Charts
import RealmSwift

class QuarterStatsViewController: UIViewController {
    
    var quarter: Quarter!
    @IBOutlet weak var pieChart: PieChartView!
    @IBOutlet weak var lineChart: LineChartView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
