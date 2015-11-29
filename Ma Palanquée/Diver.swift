//
//  Diver.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 08/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation


class Diver : NSObject
{
    var id: String!
    var firstName: String
    var lastName: String
    var level: DiveLevel
    var trainingLevel: DiveLevel?
    
    init(firstName: String, lastName: String, level: DiveLevel, trainingLevel: DiveLevel?)
    {
        self.firstName = firstName
        self.lastName = lastName
        self.level = level
        self.trainingLevel = trainingLevel
        self.id = NSUUID().UUIDString
    }
    
    override var description: String
    {
        get
        {
            return "\(firstName) \(lastName) - \(level.stringValue)"
        }
    }
    
    
}