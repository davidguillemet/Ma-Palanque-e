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
    fileprivate struct Instance
    {
        static var dico: [String: Diver] = [String: Diver]()
        static var loaded = DiverManager.LoadDivers()
    }
    
    class func AddDiver(_ newDiver: Diver)
    {
        Instance.dico[newDiver.id] = newDiver
        Persist()
    }
    
    class func RemoveDiver(_ diver2Remove: Diver)
    {
        Instance.dico[diver2Remove.id] = nil
        Persist()
    }
    
    class func GetDiver(_ id: String) -> Diver
    {
        return Instance.dico[id]!
    }
    
    class func GetDivers() -> [Diver]
    {
        var _ = Instance.loaded // Force loading divers the first time
        
        return Array(Instance.dico.values)
    }
    
    class func GetSortedDivers(_ divers: Set<String>?) -> [Diver]
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
        sortedDivers = sortedDivers.sorted(by: { (d1: Diver, d2: Diver) -> Bool in
            return d1.lastName < d2.lastName
        })
        
        return sortedDivers
    }
    
    class func GenerateGroupsFromDivers(_ divers: [Diver]) -> [Group]
    {
        var groups = [Group]()
        
        var index = 0;
        while index < divers.count
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
                index += 1
                newGroup.addDiver(divers[index].id)
            }
            
            index += 1
        }
        
        return groups
    }
    
    fileprivate class func LoadDivers() -> Bool
    {
        var diver = Diver(firstName:"Stéphane", lastName:"Desjardinsssfdfdfdfdfd", level:DiveLevel.e4, trainingLevel:nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName:"David", lastName:"Guillemet", level:DiveLevel.e2, trainingLevel:nil)
        Instance.dico[diver.id] = diver

        diver = Diver(firstName:"Isabelle", lastName:"Baudouin", level:DiveLevel.e2, trainingLevel:DiveLevel.e3)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName:"Hélène", lastName:"Som", level:DiveLevel.e2, trainingLevel:DiveLevel.e3)
        Instance.dico[diver.id] = diver

        diver = Diver(firstName:"Gilles", lastName:"Serafino", level:DiveLevel.e3, trainingLevel:nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName:"Caroline", lastName:"Lesavre", level:DiveLevel.e4, trainingLevel:nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName:"Bruno", lastName:"Merindol", level:DiveLevel.n4, trainingLevel:nil)
        Instance.dico[diver.id] = diver

        diver = Diver(firstName:"Stéphane", lastName:"Massot", level:DiveLevel.e2, trainingLevel:nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Hélène", lastName: "Brière", level: DiveLevel.n1, trainingLevel: DiveLevel.n2)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Mathieu", lastName: "De Seauve", level: DiveLevel.n3, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Olivier", lastName: "Deneux", level: DiveLevel.n3, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Caecilia", lastName: "Dijoux", level: DiveLevel.n2, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Cecile", lastName: "Farineau", level: DiveLevel.n2, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Laurence", lastName: "Haeusler", level: DiveLevel.e2, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Olivier", lastName: "Lanneluc", level: DiveLevel.n4, trainingLevel: nil)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Alexandre", lastName: "Merah", level: DiveLevel.n2, trainingLevel: DiveLevel.n3)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Véronique", lastName: "Pilch", level: DiveLevel.n1, trainingLevel: DiveLevel.n2)
        Instance.dico[diver.id] = diver
        
        diver = Diver(firstName: "Isabelle", lastName: "Philavong", level: DiveLevel.n1, trainingLevel: DiveLevel.n2)
        Instance.dico[diver.id] = diver

        return true
    }
    
    
    fileprivate class func Persist()
    {
        // TODO
    }
}
