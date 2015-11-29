//
//  Constraint.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 19/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

class Constraint
{
    var diver1: String
    var diver2: String
    var constraint: ConstraintType
    
    init(diver1: String, constraint: ConstraintType, diver2: String)
    {
        self.diver1 = diver1
        self.diver2 = diver2
        self.constraint = constraint
    }
}