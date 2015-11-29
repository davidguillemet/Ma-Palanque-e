//
//  ColorHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 24/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

class ColorHelper
{
    // Standard color to delete an item from a listÒ
    static let DeleteColor: UIColor = UIColor ( red: 0.9538, green: 0.4087, blue: 0.2572, alpha: 1.0 )
    
    // Trip colors : Pending / Archived
    static let PendingTrip: UIColor = UIColor ( red: 0.1606, green: 0.3406, blue: 0.9722, alpha: 1.0 )
    static let PendingTripBackground: UIColor = UIColor ( red: 0.6953, green: 0.8018, blue: 1.0, alpha: 1.0 )
    
    static let ArchivedTrip: UIColor = UIColor ( red: 0.163, green: 0.7283, blue: 0.0398, alpha: 1.0 )
    static let ArchivedTripBackground: UIColor = UIColor ( red: 0.7733, green: 0.9609, blue: 0.7053, alpha: 1.0 )

    static let LockedGroup = UIColor ( red: 0.6639, green: 1.0, blue: 0.4687, alpha: 1.0 )
    static let FinishedGroup = UIColor ( red: 0.0344, green: 0.8537, blue: 0.1278, alpha: 1.0 )
    static let PendingGroup = UIColor ( red: 0.9087, green: 0.9087, blue: 0.9087, alpha: 1.0 )
}