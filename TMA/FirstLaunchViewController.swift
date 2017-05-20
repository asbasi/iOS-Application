//
//  FirstLaunchViewController.swift
//  TMA
//
//  Created by Minjie Tan on 5/9/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit

class FirstLaunchViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var tutorialPageViewController: TutorialPageViewController? {
        didSet {
            tutorialPageViewController?.tutorialDelegate = self
           
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loginPage" {
            let loginPageViewController = segue.destination as? LoginTableViewController
            loginPageViewController?.isTutorial = true
        }
        else {
            if let tutorialPageViewController = segue.destination as? TutorialPageViewController {
                self.tutorialPageViewController = tutorialPageViewController
            }
        }
    }
    
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
    }
    
}

extension FirstLaunchViewController: TutorialPageViewControllerDelegate {
    
    func tutorialPageViewController(_ tutorialPageViewController: TutorialPageViewController,
                                    didUpdatePageCount count: Int) {
    }
    
    func tutorialPageViewController(_ tutorialPageViewController: TutorialPageViewController,
                                    didUpdatePageIndex index: Int) {
    }
    
}

