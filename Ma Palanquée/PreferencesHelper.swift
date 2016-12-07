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
    fileprivate static var levelColors: [Int: UIColor] = [Int: UIColor]()
    
    private static var _nameDisplayOption: NameDisplay!
    
    class func loadPreferences()
    {
        // TODO : read persistence
        
        _nameDisplayOption = NameDisplay.FirstNameLastName;
    }
    
    class func GetDiveLevelColors(_ level: DiveLevel) -> (color: UIColor, reversedColor:UIColor)
    {
        switch (level)
        {
            case DiveLevel.e4:
                return (UIColor ( red: 0.8105, green: 0.1984, blue: 0.1975, alpha: 1.0 ), UIColor ( red: 0.9357, green: 0.7006, blue: 0.6831, alpha: 1.0 ))
            case DiveLevel.e3:
                return (UIColor ( red: 0.9886, green: 0.3674, blue: 0.2422, alpha: 1.0 ), UIColor ( red: 0.9935, green: 0.6964, blue: 0.6168, alpha: 1.0 ))
            case DiveLevel.e2:
                return (UIColor ( red: 0.9907, green: 0.5181, blue: 0.0502, alpha: 1.0 ), UIColor ( red: 0.9962, green: 0.8248, blue: 0.5609, alpha: 1.0 ))
            default:
                return (UIColor ( red: 0.0, green: 0.2645, blue: 1.0, alpha: 1.0 ), UIColor ( red: 0.3981, green: 0.7257, blue: 1.0, alpha: 1.0 ))
        }
    }
    
    static var NameDisplayOption: NameDisplay
    {
        get
        {
            return _nameDisplayOption
        }
        set
        {
            _nameDisplayOption = newValue
            // TODO: persist preferences
        }
    }
}
