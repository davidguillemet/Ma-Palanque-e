//
//  UIHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 07/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

class UIHelper
{
    class func GetDiverNameAttributedString(forDiver diver: Diver) -> NSMutableAttributedString
    {
        var diverName: String!
        var boldRange: NSRange!
        switch PreferencesHelper.NameDisplayOption
        {
        case NameDisplay.LastNameOnly:
            diverName = diver.lastName
            boldRange = NSRange(location: 0, length: diver.lastName.characters.count)
            
        case NameDisplay.LastNameFirstName:
            diverName = diver.lastName + " " + diver.firstName
            boldRange = NSRange(location: 0, length: diver.lastName.characters.count)
            
        default:
            diverName = diver.firstName + " " + diver.lastName
            boldRange = NSRange(location: diver.firstName.characters.count + 1, length: diver.lastName.characters.count)
        }

        let attributedString = NSMutableAttributedString(string: diverName)
        attributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize:17), range: boldRange)
        return attributedString
    }
}
