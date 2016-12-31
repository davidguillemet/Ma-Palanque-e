//
//  ConnectionService.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 09/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

class ConnectionService: NSObject, WebServiceProtocol
{
    private var _userName: String
    private var _password: String
    private var _serviceDelegate: WebServiceDelegate?
    private var _responseData: (userName: String, active: Bool)?
    private var _error: Error?
    
    public init(userName: String, userPwd: String)
    {
        _userName = userName
        _password = userPwd
        _responseData = nil
        _serviceDelegate = nil
    }
    
    public var serviceUrl: String
    {
        get
        {
            return "session.php?action=get"
        }
    }
    
    public var postData: String?
    {
        get
        {
            return nil
        }
    }
    
    public var headers: [String: String]?
    {
        get
        {
            let authenticationHeader =
                _userName.addingPercentEncoding(withAllowedCharacters: .alphanumerics)! +
                    ":" +
                    _password.addingPercentEncoding(withAllowedCharacters: .alphanumerics)!
            
            let utf8str = authenticationHeader.data(using: String.Encoding.utf8)!
            let headerValue = "Basic \(utf8str.base64EncodedString())"
            
            return ["Authorization" : headerValue]
        }
    }
    
    public var responseData: (userName: String, active: Bool)?
    {
        get
        {
            return _responseData
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
    
    func OnResponse(data: NSDictionary, response: URLResponse) throws
    {
        // Get the session Cookie
        let httpResponse: HTTPURLResponse  = response as! HTTPURLResponse
        let cookies: [HTTPCookie] = HTTPCookie.cookies(withResponseHeaderFields: httpResponse.allHeaderFields as! [String : String], for: response.url!)
        var authCookie: HTTPCookie? = nil
        
        for cookie: HTTPCookie in cookies
        {
            if cookie.name == ServiceManager.AuthenticationCookieName
            {
                authCookie = cookie
                break
            }
        }
        
        if (authCookie != nil)
        {
            // response {"username": "<username>", "active": 0|1, "mail": "<mail>"}
            let userName: String? = data.value(forKey: "username") as! String?
            let mail: String? = data.value(forKey: "mail") as! String?
            let activeString: String? = data.value(forKey: "active") as! String?
            
            if userName == nil || activeString == nil || mail == nil
            {
                throw ErrorHelper.invalidResponse
            }
            
            let active: Bool = activeString == "1" ? true : false
            _responseData = (userName: userName!, active: active)
            
            if active
            {
                // Ok the session is open
                let user: User = User(name: userName!, mail: mail!)
                ServiceManager.OpenSession(forUser: user, withToken: authCookie!.value)
            }
        }
    }
}
