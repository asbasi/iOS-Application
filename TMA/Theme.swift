//
//  Theme.swift
//  TMA
//
//  Created by Arvinder Basi on 4/5/17.
//  Copyright © 2017 Abdulrahman Sahmoud. All rights reserved.
//

import Foundation
import UIKit

// NOTE: UCD Blue - UIColor(red: 0.0/255.0, green: 40.0/255.0, blue: 85.0/255.0, alpha: 1.0)
// NOTE: UCD Gold - UIColor(red: 218.0/255.0, green: 170.0/255.0, blue: 0.0/255.0, alpha: 1.0)

let selectedThemeKey = "SelectedTheme"

enum Theme: Int {
    case Default = 0, UCDavis = 1
    
    var barColor: UIColor {
        switch self {
            case .Default:
                return UIColor(red: 46.0/255.0, green: 14.0/255.0, blue: 74.0/255.0, alpha: 1.0)
            case .UCDavis:
                return UIColor(red: 0.0/255.0, green: 40.0/255.0, blue: 85.0/255.0, alpha: 1.0)
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .Default:
            return UIColor.white
        case .UCDavis:
            return UIColor(red: 218.0/255.0, green: 170.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        }
    }
}

struct ThemeManager {
    static func currentTheme() -> Theme {
        let storedTheme: Int = UserDefaults.standard.integer(forKey: selectedThemeKey)
        if storedTheme == 0 {
            return .Default
        }
        else {
            return Theme(rawValue: storedTheme)!
        }
    }
    
    static func applyTheme(theme: Theme) {
        UserDefaults.standard.set(theme.rawValue, forKey: selectedThemeKey)
        UserDefaults.standard.synchronize()
        
        UINavigationBar.appearance().barTintColor = theme.barColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: theme.tintColor]
        UINavigationBar.appearance().tintColor = theme.tintColor
        
        UITabBar.appearance().barTintColor = theme.barColor
        UITabBar.appearance().tintColor = theme.tintColor
    }
}
