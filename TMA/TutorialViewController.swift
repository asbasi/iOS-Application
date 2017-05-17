//
//  TutorialViewController.swift
//  TMA
//
//  Created by Minjie Tan on 4/19/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController {

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
        if let tutorialPageViewController = segue.destination as? TutorialPageViewController {
            self.tutorialPageViewController = tutorialPageViewController
        }
    }
    
    /**
     Fired when the user taps on the pageControl to change its current page.
     */
    func didChangePageControlValue() {
    }

}

extension TutorialViewController: TutorialPageViewControllerDelegate {
    
    func tutorialPageViewController(_ tutorialPageViewController: TutorialPageViewController,
                                    didUpdatePageCount count: Int) {
    }
    
    func tutorialPageViewController(_ tutorialPageViewController: TutorialPageViewController,
                                    didUpdatePageIndex index: Int) {
    }
    
}
