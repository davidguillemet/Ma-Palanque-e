//
//  WebServiceDelegate.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 09/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

protocol WebServiceDelegate
{
    func OnResponse<T: WebServiceProtocol>(fromService: T)
}
