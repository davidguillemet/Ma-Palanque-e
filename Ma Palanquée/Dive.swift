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
    var date: NSDate
    var time: NSDate
    var site: String
    var director: String
    var groups: [Group]?
    var excludedDivers: Set<String>?
    var id: String
    
    init(date: NSDate, time: NSDate, site: String, director: String, groups: [Group]?, excludedDivers: Set<String>?)
    {
        self.date = date
        self.time = time
        self.site = site
        self.director = director
        self.groups = groups
        self.excludedDivers = excludedDivers

        self.id = NSUUID().UUIDString
    }
    
    func update(date: NSDate, time: NSDate, site: String, director: String, groups: [Group]?, excludedDivers: Set<String>?)
    {
        self.date = date
        self.time = time
        self.site = site
        self.director = director
        self.groups = groups
        self.excludedDivers = excludedDivers
    }
    
    func generateGroups(trip: Trip)
    {
        var divers = Set<String>()
        
        for diver in trip.divers
        {
            if (excludedDivers != nil && !excludedDivers!.contains(diver))
            {
                divers.insert(diver)
            }
        }
        
        // Get possible locked groups
        var lockedGroups: [Group]? = nil
        if (self.groups != nil)
        {
            lockedGroups = self.groups!.filter({ (group: Group) -> Bool in
                return group.locked
            })
        }
        
        // Remove divers which are part of a locked group
        if (lockedGroups != nil)
        {
            for lockedGroup in lockedGroups!
            {
                if (lockedGroup.guide != nil)
                {
                    divers.remove(lockedGroup.guide!)
                }
                
                if (lockedGroup.divers != nil)
                {
                    for diver in lockedGroup.divers!
                    {
                        divers.remove(diver)
                    }
                }
            }
        }
        
        // Build a diver list from still available divers
        let availableDivers: [Diver] = divers.map { (id: String) -> Diver in
            return DiverManager.GetDiver(id)
        }
        
        // Build groups from available divers
        let newGroups: [Group] = DiverManager.GenerateGroupsFromDivers(availableDivers)
        
        // Append new groups to locked groups
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