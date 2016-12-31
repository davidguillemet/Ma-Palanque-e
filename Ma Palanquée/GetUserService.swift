//
//  GetUserService.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 11/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

class GetUserService : WebServiceProtocol
{
    private var _userName: String
    private var _serviceDelegate: WebServiceDelegate?
    private var _user: User?
    private var _error: Error?
    
    public init(userName: String)
    {
        self._userName = userName
        self._serviceDelegate = nil
        self._user = nil
    }
    var serviceUrl: String
    {
        get
        {
            return "user.php?action=get"
        }
    }
    
    var postData: String?
    {
        get
        {
            return "{ \"name\": \"\(self._userName)\"}"
        }
    }
    var headers: [String: String]?
    {
        get
        {
            return nil
        }
    }
    
    public var serviceDelegate: WebServiceDelegate?
    {
        get
        {
            return _serviceDelegate
        }
        set
        {
            _serviceDelegate = newValue
        }
        
    }
    
    var responseData: User?
    {
        get
        {
            return _user
        }
    }

    var error: Error?
    {
        get
        {
            return _error
        }
    }
    
    func setError(error: Error?)
    {
        _error = error
    }
    
    func OnResponse(data: NSDictionary, response: URLResponse) throws
    {
        // Response : { "name": "<username>", "mail": "<user email>" }
        let error = data.value(forKey: "error")
        if error == nil
        {
            let userName: String? = data.value(forKey: "name") as? String
            let mail: String? = data.value(forKey: "mail") as? String
                
            if userName != nil && mail != nil
            {
                _user = User(name: userName!, mail: mail!)
            }
            else
            {
                throw ErrorHelper.invalidResponse
            }
        }
    }

}
