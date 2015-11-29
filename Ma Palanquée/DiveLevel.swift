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
    case    N0      = 0,
            N1      = 1,
            PA20    = 2,
            N2      = 3,
            PE40    = 4,
            N3      = 5,
            N4      = 6,
            E2      = 7,
            E3      = 8,
            E4      = 9
    
    var stringValue : String
    {
        switch self {
                // Use Internationalization, as appropriate.
            case .N0: return "N0";
            case .N1: return "N1";
            case .PA20: return "PA20";
            case .N2: return "N2";
            case .PE40: return "PE40";
            case .N3: return "N3";
            case .N4: return "N4";
            case .E2: return "E2";
            case .E3: return "E3";
            case .E4: return "E4";
        }
    }
}