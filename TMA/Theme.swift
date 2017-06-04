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
    case Default = 0, Purple = 1, Red = 2, Davis = 3, Pink = 4
    // set the color of bar background of the theame
    var barColor: UIColor {
        switch self {
            case .Default:
                return UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)
            case .Purple:
                return UIColor(red: 46.0/255.0, green: 14.0/255.0, blue: 74.0/255.0, alpha: 1.0)
            case .Red:
                return UIColor(red: 215.0/255.0, green: 37.0/255.0, blue: 37.0/255.0, alpha: 0.1)
            case .Davis:
                return UIColor(red: 0.0/255.0, green: 40.0/255.0, blue: 85.0/255.0, alpha: 1.0)
            case .Pink:
                return UIColor(red: 36.0/255.0, green: 129.0/255.0, blue: 87.0/255.0, alpha: 0.1)

        }
    }
    // set the color of the selected items and title in the theme
    var tintColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 65.0/255.0, green: 105.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        case .Purple:
            return UIColor.white
        case .Red:
            return UIColor.white
        case .Davis:
            return UIColor(red: 218.0/255.0, green: 170.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        case .Pink:
            return UIColor.white
            
        }
    }
    
}



struct ThemeManager {
    // set the current theme when lunch
    static func currentTheme() -> Theme {
        let storedTheme: Int = UserDefaults.standard.integer(forKey: selectedThemeKey)
        // if the theme hasn't change the default is the UC Davis Theme
        if storedTheme == 0 {
            return .Default
        }
        // if the theame has changed set the theme user specified
        else {
            return Theme(rawValue: storedTheme)!
        }
    }
    // Change the theme to the desire theme
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
