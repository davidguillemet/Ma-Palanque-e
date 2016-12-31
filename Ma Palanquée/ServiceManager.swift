//
//  WebService.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 07/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

enum ServiceType
{
    case GetDivers
}

class ServiceManager: NSObject
{
    public static let AuthenticationCookieName = "AUTHCOOKIE"

    static let DocumentsDirectory: URL = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let SessionArchiveUrl: URL = DocumentsDirectory.appendingPathComponent("session")
    
    static private var _userSession: UserSession?
    static private let serviceRoot: String = "https://www.davidphotosub.com/services/"
    
    static public var User: User?
    {
        get
        {
            return _userSession?.User
        }
    }
    
    static public var IsConnected: Bool
    {
        get
        {
            return _userSession != nil
        }
    }
    
    // The session might be identified while we are offline..
    static public var IsOffline: Bool = false
        
    class func loadPersistedSession(controller: UIViewController, delegate: WebServiceDelegate) -> Bool
    {
        if let archivedSession = NSKeyedUnarchiver.unarchiveObject(withFile: SessionArchiveUrl.path)
        {
            if let userSession: UserSession = archivedSession as? UserSession
            {
                _userSession = userSession
                // Check that the user is still valid
                // -> Call get user service
                let userService: GetUserService = GetUserService(userName: _userSession!.User.name)
                userService.serviceDelegate = delegate
                ServiceManager.InvokeService(withService: userService, controller: controller)
                return true
            }
       }
        
        return false
    }
    
    class func CloseSession()
    {
        // No more user session
        _userSession = nil
        
        // Make sure to delete the persisted session
        do
        {
            try FileManager.default.removeItem(at: SessionArchiveUrl)
        }
        catch
        {
            // Nothing...pas très grave
        }
    }
    
    class func OpenSession(forUser user: User, withToken authToken: String)
    {
        _userSession = UserSession(user: user, sessionCookie: authToken)
        
        // Persist the new user session
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(_userSession!, toFile: SessionArchiveUrl.path)
        if !isSuccessfulSave
        {
            // TODO... What if the url session has not been persisted...
        }
    }
    
    class func PrepareRequest(serviceUrl: String, postData: String?, headers: [String: String]?) -> URLRequest
    {
        let connectUrl = serviceRoot + serviceUrl
        let url: URL = URL(string: connectUrl)!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        
        // Write Body
        if postData != nil && !postData!.isEmpty
        {
            // Populate request body
            request.httpBody = postData!.data(using: .utf8)
            //request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
        }

        // Write Headers
        if headers != nil
        {
            for (headerName, headerValue) in headers!
            {
                request.setValue(headerValue, forHTTPHeaderField: headerName)
            }
        }
        
        // Write authentication cookie is user is already open
        if _userSession != nil
        {
            let jar = HTTPCookieStorage.shared
            let cookieHeaderField = ["Set-Cookie": "\(ServiceManager.AuthenticationCookieName)=\(_userSession!.SessionCookie)"]
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: cookieHeaderField, for: url)
            jar.setCookies(cookies, for: url, mainDocumentURL: url)
        }
        
        return request as URLRequest
    }
    
    class func InvokeService<T: WebServiceProtocol>(withService service: T, controller: UIViewController)
    {
        let request: URLRequest = PrepareRequest(serviceUrl: service.serviceUrl, postData: service.postData, headers: service.headers)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in

            DispatchQueue.main.async { [unowned controller] in
            
                let callError: ErrorHelper? = OnServiceRequestCompleted(data: data, response: response, error: error, fromService: service, controller: controller)
            
                service.setError(error: callError)
            
                if callError == nil
                {
                    // Finally, Always tell the delegate the service call is completed (error or success)
                    service.serviceDelegate?.OnResponse(fromService: service)
                }
                else
                {
                    
                    MessageHelper.displayError(ErrorHelper.ErrorDesc(error: callError!), controller: controller) {
                        // Call the service delegate after the user clicks on Ok
                        service.serviceDelegate?.OnResponse(fromService: service)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    class func OnServiceRequestCompleted<T: WebServiceProtocol>(
        data: Data?, response: URLResponse?, error: Error?, fromService service: T, controller: UIViewController) -> ErrorHelper?
    {
        // check for fundamental networking error
        guard error == nil else
        {
            return ErrorHelper.noInternetConnection
        }
        
        // check for http errors
        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200
        {
            if httpStatus.statusCode == 401
            {
                return ErrorHelper.invalidCredentials
            }
            else
            {
                return ErrorHelper.serverError
            }
        }
        
        if data == nil
        {
            return ErrorHelper.invalidResponse
        }
        
        let jsonResult: NSDictionary
        
        do
        {
            jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        }
        catch
        {
            return ErrorHelper.invalidResponse
        }
        
        // Here data has been read...inform the service
        do
        {
            try service.OnResponse(data: jsonResult, response: response!)
        }
        catch
        {
            return ErrorHelper.invalidResponse
        }
        
        return nil
    }
}
