//
//  DiverManager.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 08/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

class DiverManager
{
    private struct Instance
    {
        static var dico: [String: Diver] = [String: Diver]()
        static var loaded = DiverManager.LoadDivers()
    }
    
    class func AddDiver(newDiver: Diver)
    {
        Instance.dico[newDiver.id] = newDiver
        Persist()
    }
    
    class func RemoveDiver(diver2Remove: Diver)
    {
        Instance.dico[diver2Remove.id] = nil
        Persist()
    }
    
    class func GetDiver(id: String) -> Diver
    {
        return Instance.dico[id]!
    }
    
    class func GetDivers() -> [Diver]
    {
        var _ = Instance.loaded // Force loading divers the first time
        
        return Array(Instance.dico.values)
    }
    
    class func GetSortedDivers(divers: Set<String>?) -> [Diver]
    {
        var sortedDivers = [Diver]()
        
        if (divers == nil)
        {
            return sortedDivers
        }
        
        for diver in divers!
        {
            sortedDivers.append(DiverManager.GetDiver(diver))
        }
        
        // Sort in alphabetical order
        sortedDivers = sortedDivers.sort({ (d1: Diver, d2: Diver) -> Bool in
            return d1.lastName < d2.lastName
        })
        
        return sortedDivers
    }
    
    class func GenerateGroupsFromDivers(divers: [Diver]) -> [Group]
    {
        var groups = [Group]()
        
        for (var index = 0; index < divers.count; /* Nothing */)
        {
            if (index == divers.count - 1 && groups.count > 0)
            {
                // Last diver
                // add to the first groups
                groups[0].addDiver(divers[index].id)
                break;
            }
            
            let newGroup = Group(divers: [divers[index].id], guide: divers[index].id)
            groups.append(newGroup)
            
            if (index < divers.count - 1)
            {
                index++
                newGroup.addDiver(divers[index].id)
            }
            
            index++
        }
        
        return groups
    }
    
    private class func LoadDivers() -> Bool
    {
        var diver = Diver(firstName:"Stéphane", lastName:"Desjardins", level:DiveLevel.E4, trainingLevel:nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName:"David", lastName:"Guillemet", level:DiveLevel.E2, trainingLevel:nil)
        Instance.dico[diver.id] = diver

        diver = Diver(firstName:"Isabelle", lastName:"Baudouin", level:DiveLevel.E2, trainingLevel:DiveLevel.E3)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName:"Hélène", lastName:"Som", level:DiveLevel.E2, trainingLevel:DiveLevel.E3)
        Instance.dico[diver.id] = diver

        diver = Diver(firstName:"Gilles", lastName:"Serafino", level:DiveLevel.E3, trainingLevel:nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName:"Caroline", lastName:"Lesavre", level:DiveLevel.E4, trainingLevel:nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName:"Bruno", lastName:"Merindol", level:DiveLevel.N4, trainingLevel:nil)
        Instance.dico[diver.id] = diver

        diver = Diver(firstName:"Stéphane", lastName:"Massot", level:DiveLevel.E2, trainingLevel:nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Hélène", lastName: "Brière", level: DiveLevel.N1, trainingLevel: DiveLevel.N2)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Mathieu", lastName: "De Seauve", level: DiveLevel.N3, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Olivier", lastName: "Deneux", level: DiveLevel.N3, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Caecilia", lastName: "Dijoux", level: DiveLevel.N2, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Cecile", lastName: "Farineau", level: DiveLevel.N2, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Laurence", lastName: "Haeusler", level: DiveLevel.E2, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Olivier", lastName: "Lanneluc", level: DiveLevel.N4, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Alexandre", lastName: "Merah", level: DiveLevel.N2, trainingLevel: DiveLevel.N3)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Véronique", lastName: "Pilch", level: DiveLevel.N1, trainingLevel: DiveLevel.N2)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Isabelle", lastName: "Philavong", level: DiveLevel.N1, trainingLevel: DiveLevel.N2)
        Instance.dico[diver.id] = diver

        return true
    }
    
    
    private class func Persist()
    {
        // TODO
    }
}