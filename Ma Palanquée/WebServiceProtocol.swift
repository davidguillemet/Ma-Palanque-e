//
//  WebServiceProtocol.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 09/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

protocol WebServiceProtocol
{
    associatedtype ResponseType
    
    var serviceUrl: String { get }
    var postData: String? { get  }
    var headers: [String: String]? { get }
    var serviceDelegate: WebServiceDelegate? { get }
    var responseData: ResponseType { get }
    var error: Error? { get }
    func setError(error: Error?)
    func OnResponse(data: NSDictionary, response: URLResponse) throws
}
