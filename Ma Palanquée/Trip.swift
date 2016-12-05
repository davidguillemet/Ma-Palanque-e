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
    var dateFrom: Date
    var dateTo: Date
    var tripType: TripType
    var divers: Set<String>
    var constraints: [Constraint]?
    var archived: Bool
    
    fileprivate var dives: [String: Dive] = [String: Dive]()
    
    init(location: String, desc: String, dateFrom: Date, dateTo: Date, tripType: TripType, divers: Set<String>, constraints: [Constraint]?)
    {
        self.location = location
        self.desc = desc
        self.dateFrom = dateFrom
        self.dateTo = dateTo
        self.tripType = tripType
        self.divers = divers
        self.constraints = constraints
        
        self.id = UUID().uuidString
        self.archived = false
    }

    func update(_ location: String, desc: String, dateFrom: Date, dateTo: Date, tripType: TripType, divers: Set<String>, constraints: [Constraint]?)
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
        
    func addDive(_ dive: Dive)
    {
        dives[dive.id] = dive
    }
    
    func removeDive(_ dive: Dive)
    {
        dives[dive.id] = nil
    }
    
    func canRemoveDiver(_ diver: String) -> Bool
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
    func getMaximalStartDate(_ currentDateTo: Date) -> Date?
    {
        if (dives.isEmpty)
        {
            return currentDateTo
        }
        
        var minimumDiveDate: Date? = nil
            
        for (_, dive) in dives
        {
            if (minimumDiveDate == nil)
            {
                minimumDiveDate = dive.date
                continue
            }
                
            if ((Calendar.current as NSCalendar).compare(dive.date, to: minimumDiveDate!, toUnitGranularity: .day) == ComparisonResult.orderedAscending)
            {
                minimumDiveDate = dive.date
            }
        }
        
        return minimumDiveDate
    }
    
    func getMinimalEndDate(_ currentDateFrom: Date) -> Date?
    {
        if (dives.isEmpty)
        {
            return currentDateFrom
        }
        
        var maximumDiveDate: Date? = nil
        
        for (_, dive) in dives
        {
            if (maximumDiveDate == nil)
            {
                maximumDiveDate = dive.date
                continue
            }
            
            if ((Calendar.current as NSCalendar).compare(maximumDiveDate!, to: dive.date, toUnitGranularity: .day) == ComparisonResult.orderedAscending)
            {
                maximumDiveDate = dive.date
            }
        }
        
        return maximumDiveDate
    }

}
