//
//  Tutorial6ViewController.swift
//  TMA
//
//  Created by Minjie Tan on 4/12/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit

class Tutorial6ViewController: UIViewController {

    @IBOutlet weak var Photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.Photo.image = UIImage(named: "test")
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
