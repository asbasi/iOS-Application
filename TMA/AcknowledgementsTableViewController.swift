//
//  AcknowledgementsTableViewController.swift
//  TMA
//
//  Created by Minjie Tan on 5/24/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import UIKit
import SafariServices

/// Class Acknowledges all SDKs the application using. 
class AcknowledgementsTableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            let svc = SFSafariViewController(url: URL(string:"https://github.com/Alamofire/Alamofire")!)
            present(svc, animated: true, completion: nil)
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            let svc = SFSafariViewController(url: URL(string:"https://github.com/WenchaoD/FSCalendar")!)
            present(svc, animated: true, completion: nil)
        }
        else if indexPath.section == 2 && indexPath.row == 0 {
            let svc = SFSafariViewController(url: URL(string:"https://github.com/Boris-Em/BEMCheckBox")!)
            present(svc, animated: true, completion: nil)
        }
        else if indexPath.section == 3 && indexPath.row == 0 {
            let svc = SFSafariViewController(url: URL(string:"https://github.com/danielgindi/Charts")!)
            present(svc, animated: true, completion: nil)
        }
        else if indexPath.section == 4 && indexPath.row == 0 {
            let svc = SFSafariViewController(url: URL(string:"https://github.com/i-schuetz/PieCharts")!)
            present(svc, animated: true, completion: nil)
        }
        else if indexPath.section == 5 && indexPath.row == 0 {
            let svc = SFSafariViewController(url: URL(string:"https://github.com/PureLayout/PureLayout")!)
            present(svc, animated: true, completion: nil)
        }
        else if indexPath.section == 6 && indexPath.row == 0 {
            let svc = SFSafariViewController(url: URL(string:"https://github.com/realm")!)
            present(svc, animated: true, completion: nil)
        }
        else if indexPath.section == 7 && indexPath.row == 0 {
            let svc = SFSafariViewController(url: URL(string:"https://realm.io/docs/swift/2.6.2/")!)
            present(svc, animated: true, completion: nil)
        }
        
    }

}
