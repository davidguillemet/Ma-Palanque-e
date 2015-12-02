//
//  Trip.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 08/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation


class Trip : NSObject
{
    var id: String
    var location: String
    var desc: String
    var dateFrom: NSDate
    var dateTo: NSDate
    var tripType: TripType
    var divers: Set<String>
    var constraints: [Constraint]?
    var archived: Bool
    
    private var dives: [String: Dive] = [String: Dive]()
    
    init(location: String, desc: String, dateFrom: NSDate, dateTo: NSDate, tripType: TripType, divers: Set<String>, constraints: [Constraint]?)
    {
        self.location = location
        self.desc = desc
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.tripType = tripType
        self.divers = divers
        self.constraints = constraints
        
        self.id = NSUUID().UUIDString
        self.archived = false
    }

    func update(location: String, desc: String, dateFrom: NSDate, dateTo: NSDate, tripType: TripType, divers: Set<String>, constraints: [Constraint]?)
    {
        self.location = location
        self.desc = desc
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.tripType = tripType
        self.divers = divers
        self.constraints = constraints
    }
    
    func getDives() -> [Dive]
    {
        return Array(dives.values)
    }
        
    func addDive(dive: Dive)
    {
        dives[dive.id] = dive
    }
    
    func removeDive(dive: Dive)
    {
        dives[dive.id] = nil
    }
    
    func canRemoveDiver(diver: String) -> Bool
    {
        if (dives.isEmpty)
        {
            return true
        }
        
        // Check all dives:
        for (_, dive) in dives
        {
            if (dive.groups == nil)
            {
                continue
            }
            
            for group: Group in dive.groups!
            {
                if (group.containsDiver(diver))
                {
                    return false
                }
            }
        }
        
        return true
    }
    
    // Get the minimal
    func getMaximalStartDate(currentDateTo: NSDate) -> NSDate?
    {
        if (dives.isEmpty)
        {
            return currentDateTo
        }
        
        var minimumDiveDate: NSDate? = nil
            
        for (_, dive) in dives
        {
            if (minimumDiveDate == nil)
            {
                minimumDiveDate = dive.date
                continue
            }
                
            if (NSCalendar.currentCalendar().compareDate(dive.date, toDate: minimumDiveDate!, toUnitGranularity: .Day) == NSComparisonResult.OrderedAscending)
            {
                minimumDiveDate = dive.date
            }
        }
        
        return minimumDiveDate
    }
    
    func getMinimalEndDate(currentDateFrom: NSDate) -> NSDate?
    {
        if (dives.isEmpty)
        {
            return currentDateFrom
        }
        
        var maximumDiveDate: NSDate? = nil
        
        for (_, dive) in dives
        {
            if (maximumDiveDate == nil)
            {
                maximumDiveDate = dive.date
                continue
            }
            
            if (NSCalendar.currentCalendar().compareDate(maximumDiveDate!, toDate: dive.date, toUnitGranularity: .Day) == NSComparisonResult.OrderedAscending)
            {
                maximumDiveDate = dive.date
            }
        }
        
        return maximumDiveDate
    }

}