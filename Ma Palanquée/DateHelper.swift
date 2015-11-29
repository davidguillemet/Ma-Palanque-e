//
//  DateHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 21/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

class DateHelper
{
    class func dateFromString(date: String, fullStyle: Bool) -> NSDate?
    {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale.init(localeIdentifier:"fr")
        formatter.dateStyle = fullStyle ? .FullStyle : .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter.dateFromString(date)
    }
    
    class func stringFromDate(date: NSDate, fullStyle: Bool) -> String
    {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale.init(localeIdentifier:"fr")

        dateFormatter.dateStyle = fullStyle ? .FullStyle : .MediumStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.NoStyle
        
        return dateFormatter.stringFromDate(date) ?? "??"
    }
    class func stringFromTime(date: NSDate) -> String
    {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.locale = NSLocale.init(localeIdentifier:"fr")

        dateFormatter.dateStyle = .NoStyle
        dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
        return dateFormatter.stringFromDate(date) ?? "??"
    }
}