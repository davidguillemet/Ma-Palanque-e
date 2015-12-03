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
    private var divers: [String]?
    
    var guide: String?
    var locked: Bool
    var id: String
    
    init(divers: [String]?, guide: String?)
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
            divers = [String]()
        }
        else if (divers!.contains(diver))
        {
            return
        }
        divers!.append(diver)
    }
    
    func insertDiver(diver: String, atIndex: Int)
    {
        if (divers == nil)
        {
            divers = [String]()
        }
        else if (divers!.contains(diver))
        {
            return
        }
        if (atIndex <= divers!.count)
        {
            divers!.insert(diver, atIndex: atIndex)
        }
    }
    func moveDiver(fromIndex: Int, toIndex: Int) throws
    {
        if (self.divers == nil)
        {
            return
        }
        
        if (fromIndex < 0 || fromIndex > self.divers!.count)
        {
            throw ErrorHelper.InvalidDiverIndex(index: fromIndex)
        }
        
        if (toIndex < 0 || toIndex > self.divers!.count)
        {
            throw ErrorHelper.InvalidDiverIndex(index: toIndex)
        }
        
        let diver = self.divers![fromIndex]
        
        // if fromIndex < toIndex, first add toIndex and then remove fromIndex
        if (fromIndex < toIndex)
        {
            self.divers!.insert(diver, atIndex: toIndex)
            self.divers!.removeAtIndex(fromIndex)
        }
        // if fromIndex > toIndex, first remove fromIndex and then add toIndex
        else
        {
            self.divers!.removeAtIndex(fromIndex)
            self.divers!.insert(diver, atIndex: toIndex)
        }
    }
    
    func containsDiver(diver: String) -> Bool
    {
        return self.divers == nil ? false : self.divers!.contains(diver)
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
    
    func removeDiverAt(atIndex: Int)
    {
        if (divers == nil || atIndex > divers!.count || atIndex < 0)
        {
            return
        }
        
        // Check if we remove the guide
        let diverToRemove: String = self.divers![atIndex]
        
        if (diverToRemove == self.guide)
        {
            self.guide = nil
        }
        
        self.divers!.removeAtIndex(atIndex)
    }
    
    func removeDiver(diverToRemove: String)
    {
        if (divers == nil)
        {
            return
        }
        
        // search for diver index
        var indexToRemove: Int = -1
        for (var index = 0; index < divers!.count; index++)
        {
            let diver = divers![index]
            if (diver == diverToRemove)
            {
                indexToRemove = index
                if (self.guide == diverToRemove)
                {
                    // In case we remove the guide, set guide as nil
                    self.guide = nil
                }
                break
            }
        }
        
        if (indexToRemove >= 0)
        {
            divers!.removeAtIndex(indexToRemove)
        }
    }
    
    var diverCount: Int
    {
        get
        {
            return self.divers == nil ? 0 : self.divers!.count
        }
    }
    
    func diverAt(atIndex: Int) throws -> String
    {
        if (self.divers == nil || atIndex < 0 || atIndex > self.divers!.count)
        {
            throw ErrorHelper.InvalidDiverIndex(index: atIndex)
        }
        
        return self.divers![atIndex]
    }
    
    func validateGroup() -> [String]?
    {
        // TODO : returns message list about group errors
        // - one single diver
        // - no guide for non autonom divers
        // - etc
        return nil
    }
}