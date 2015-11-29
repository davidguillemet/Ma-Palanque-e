//
//  TripManager.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 08/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

class TripManager
{
    private struct Instance
    {
        static var dico: [String: Trip] = [String: Trip]()
        static var loaded = TripManager.LoadTrips()
    }
    
    class func GetTrips() -> [Trip]
    {
        let _ = Instance.loaded // Force loading Trips the first time
        
        return Array(Instance.dico.values).sort({ (t1: Trip, t2: Trip) -> Bool in
            return t1.dateFrom.compare(t2.dateTo) == NSComparisonResult.OrderedAscending
        })
    }
    
    private class func LoadTrips() -> Bool
    {
        let divers: [Diver] = DiverManager.GetDivers()
        
        let diversSet: Set<String> = Set<String>(divers.map({(d: Diver) -> String in
            return d.id
        }))
        
        var newTrip = Trip(location:"Marseille", desc:"Week-End Technique Novembre 2015", dateFrom:NSDate(), dateTo:NSDate(), tripType:TripType.training ,divers: diversSet, constraints: nil)
        Instance.dico[newTrip.id] = newTrip
        
        newTrip = Trip(location:"La Ciotat", desc:"Stage Bio Juin 2015", dateFrom:NSDate(), dateTo:NSDate(), tripType:TripType.training ,divers: diversSet, constraints: nil)
        Instance.dico[newTrip.id] = newTrip
        
        newTrip = Trip(location:"Cap Creus", desc:"Sortie Rentrée 2015", dateFrom:NSDate(), dateTo:NSDate(), tripType:TripType.training ,divers: diversSet, constraints: nil)
        Instance.dico[newTrip.id] = newTrip
        
        return true
    }
    
    class func ArchiveTrip(trip: Trip, archived: Bool)
    {
        trip.archived = archived
        Persist()
    }
    
    class func AddTrip(newTrip: Trip)
    {
        Instance.dico[newTrip.id] = newTrip
        Persist()
    }
    
    class func RemoveTrip(id: String)
    {
        Instance.dico[id] = nil
        Persist()
    }
    
    class func RemoveDive(dive: Dive, trip: Trip)
    {
        trip.removeDive(dive)
        Persist()
    }
    
    class func AddDive(newDive: Dive, trip: Trip)
    {
        trip.addDive(newDive)
        Persist()
    }
        
    class func Persist()
    {
        // TODO: Implement persistence
    }
}
