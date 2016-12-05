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
    class func dateFromString(_ date: String, fullStyle: Bool) -> Date?
    {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier:"fr")
        formatter.dateStyle = fullStyle ? .full : .medium
        formatter.timeStyle = .none
        return formatter.date(from: date)
    }
    
    class func stringFromDate(_ date: Date, fullStyle: Bool) -> String
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale.init(identifier:"fr")

        dateFormatter.dateStyle = fullStyle ? .full : .medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        return dateFormatter.string(from: date)
    }
    class func stringFromTime(_ date: Date) -> String
    {
        let dateFormatter = DateFormatter()
        
        dateFormatter.locale = Locale.init(identifier:"fr")

        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = DateFormatter.Style.short
        
        return dateFormatter.string(from: date)
    }
}
