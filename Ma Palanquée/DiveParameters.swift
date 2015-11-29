//
//  DiveParameters.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 19/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

class DiveParameters
{
    var depth: Int
    var time: Int
    var deco: [DecoStop]?
    
    init(depth: Int, time: Int, deco: [DecoStop]?)
    {
        self.depth = depth
        self.time = time
        self.deco = deco
    }
}