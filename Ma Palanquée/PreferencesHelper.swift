//
//  PreferencesHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 29/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

class PreferencesHelper
{
    private static var levelColors: [Int: UIColor] = [Int: UIColor]()
    
    class func loadPreferences()
    {
        // TODO : read persistence
    }
    
    class func GetDiveLevelColors(level: DiveLevel) -> (color: UIColor, reversedColor:UIColor)
    {
        return (UIColor ( red: 0.0, green: 0.2645, blue: 1.0, alpha: 1.0 ), UIColor ( red: 0.3981, green: 0.7257, blue: 1.0, alpha: 1.0 ))
    }
}