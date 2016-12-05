//
//  DiveLevel.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 08/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

enum DiveLevel : Int
{
    case    n0      = 0,
            n1      = 1,
            pa20    = 2,
            n2      = 3,
            pe40    = 4,
            n3      = 5,
            n4      = 6,
            e2      = 7,
            e3      = 8,
            e4      = 9
    
    var stringValue : String
    {
        switch self {
                // Use Internationalization, as appropriate.
            case .n0: return "N0";
            case .n1: return "N1";
            case .pa20: return "PA20";
            case .n2: return "N2";
            case .pe40: return "PE40";
            case .n3: return "N3";
            case .n4: return "N4";
            case .e2: return "E2";
            case .e3: return "E3";
            case .e4: return "E4";
        }
    }
}
