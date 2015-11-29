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
    
    init(guide: String?, divers: Set<String>?)
    {
        self.guide = guide
        self.divers = divers
        self.locked = false
    }
    
    func addDiver(diver: String)
    {
        if (divers == nil)
        {
            divers = Set<String>()
        }
        divers!.insert(diver)
    }
    
    func removeDiver(diver: String)
    {
        if (divers == nil)
        {
            return
        }
        
        divers?.remove(diver)
    }
}