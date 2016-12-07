//
//  NameDisplay.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 05/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

class NameDisplay: NSObject
{
    static let FirstNameLastName:NameDisplay = NameDisplay(description: "Prénom Nom");
    static let LastNameFirstName:NameDisplay = NameDisplay(description: "Nom Prénom");
    static let LastNameOnly:NameDisplay = NameDisplay(description: "Nom");

    var _description: String!
    
    init(description: String)
    {
        _description = description
    }

    override var description: String
    {
        get
        {
            return self._description
        }
    }
}
