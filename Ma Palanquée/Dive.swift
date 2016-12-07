//
//  Dive.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 19/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

class Dive : NSObject
{
    var date: Date
    var time: Date
    var site: String
    var director: String
    var groups: [Group]?
    var excludedDivers: Set<String>?
    var id: String
    
    init(date: Date, time: Date, site: String, director: String, groups: [Group]?, excludedDivers: Set<String>?)
    {
        self.date = date
        self.time = time
        self.site = site
        self.director = director
        self.groups = groups
        self.excludedDivers = excludedDivers

        self.id = UUID().uuidString
    }
    
    func update(_ date: Date, time: Date, site: String, director: String, groups: [Group]?, excludedDivers: Set<String>?)
    {
        self.date = date
        self.time = time
        self.site = site
        self.director = director
        self.groups = groups
        self.excludedDivers = excludedDivers
    }
    
    func addExcludedDiver(_ diver: String)
    {
        if (self.excludedDivers == nil)
        {
            self.excludedDivers = Set<String>()
        }
        self.excludedDivers!.insert(diver)
    }
    
    func diverIsInGroup(_ diverId: String) -> Bool
    {
        if (groups == nil)
        {
            return false;
        }

        for group in self.groups!
        {
            if group.containsDiver(diverId)
            {
                return true;
            }
        }
        
        return false;
    }
    
    func getAvailableDivers(_ trip: Trip, scanOnlyLockedGroups: Bool) -> Set<String>
    {
        var availableDivers = Set<String>()
        
        for diver in trip.divers
        {
            if (excludedDivers != nil && !excludedDivers!.contains(diver))
            {
                availableDivers.insert(diver)
            }
        }
        
        var groupsToScan: [Group]? = self.groups
        
        if (scanOnlyLockedGroups && self.groups != nil)
        {
            // Scan only locked groups
            groupsToScan = self.groups!.filter({ (group: Group) -> Bool in
                return group.locked
            })
        }
        
        // Remove divers which are part of groups
        if (groupsToScan != nil)
        {
            for group in groupsToScan!
            {
                for index in (0 ..< group.diverCount)
                {
                    try! availableDivers.remove(group.diverAt(index))
                }
            }
        }
        return availableDivers
    }
    
    func generateGroups(_ trip: Trip)
    {
        // Get available divers which are not part of a locked group
        let divers = getAvailableDivers(trip, scanOnlyLockedGroups: true)
        
        // Build a diver list from still available divers
        let availableDivers: [Diver] = divers.map { (id: String) -> Diver in
            return DiverManager.GetDiver(id)
        }
        
        // Build groups from available divers
        let newGroups: [Group] = DiverManager.GenerateGroupsFromDivers(availableDivers)
        
        var lockedGroups: [Group]? = nil
        
        if (self.groups != nil)
        {
            // Scan only locked groups
            lockedGroups = self.groups!.filter({ (group: Group) -> Bool in
                return group.locked
            })
        }
        
        // Append new groups to possible locked groups
        if (lockedGroups != nil)
        {
            self.groups = lockedGroups! + newGroups
        }
        else
        {
            self.groups = newGroups
        }
    }
}
