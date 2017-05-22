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

enum Theme: Int {
    case Default = 0, Purple = 1, Red = 2, LightGray = 3, Pink = 4
    
    var barColor: UIColor {
        switch self {
            case .Default:
                return UIColor(red: 0.0/255.0, green: 40.0/255.0, blue: 85.0/255.0, alpha: 1.0)
            case .Purple:
                return UIColor(red: 46.0/255.0, green: 14.0/255.0, blue: 74.0/255.0, alpha: 1.0)
            case .Red:
                return UIColor(red: 215.0/255.0, green: 37.0/255.0, blue: 37.0/255.0, alpha: 0.1)
            case .LightGray:
                return UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            case .Pink:
                return UIColor(red: 36.0/255.0, green: 129.0/255.0, blue: 87.0/255.0, alpha: 0.1)

        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 218.0/255.0, green: 170.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        case .Purple:
            return UIColor.white
        case .Red:
            return UIColor.white
        case .LightGray:
            return UIColor(red: 65.0/255.0, green: 105.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        case .Pink:
            return UIColor.white
            
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
