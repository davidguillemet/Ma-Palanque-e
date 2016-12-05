//
//  ErrorHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 29/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

enum ErrorHelper : Error
{
    case invalidGuide(guide: String)
    case invalidDiverIndex(index: Int)
}
