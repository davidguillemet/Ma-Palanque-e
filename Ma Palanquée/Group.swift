//
//  Group.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 20/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

class Group
{
    var guide: String?
    var divers: Set<String>?
    var locked: Bool
    var id: String
    
    init(divers: Set<String>?, guide: String?)
    {
        // TODO check the guild is part of the divers
        self.divers = divers
        self.guide = guide
        self.locked = false
        self.id = NSUUID().UUIDString
    }
    
    init(group: Group)
    {
        self.divers = group.divers
        self.guide = group.guide
        self.locked = group.locked
        self.id = NSUUID().UUIDString
    }
    
    func addDiver(diver: String)
    {
        if (divers == nil)
        {
            divers = Set<String>()
        }
        divers!.insert(diver)
    }
    
    // Set the guide, which MUST be part of the group divers
    // 1. addDiver (d1)
    // 2. setGuide (d1)
    func setGuide(guide: String?) throws
    {
        self.guide = guide

        if (guide != nil)
        {
            // Check the guide is part of the divers
            if (self.divers == nil || !self.divers!.contains(guide!))
            {
                throw ErrorHelper.InvalidGuide(guide: guide!)
            }
        }
    }
    
    func removeDiver(diver: String)
    {
        if (divers == nil)
        {
            return
        }
        
        divers!.remove(diver)
    }
}