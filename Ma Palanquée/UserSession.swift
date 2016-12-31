//
//  UserSession.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 07/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

class UserSession : NSObject, NSCoding
{
    private static var userKey: String = "user"
    private static var sessionCookieKey: String = "sessionCookie"
    
    private let _sessionCookie: String
    private let _user: User
    
    init(user: User, sessionCookie: String)
    {
        _sessionCookie = sessionCookie
        _user = user
    }
    
    public var User: User
    {
        get
        {
            return _user
        }
    }
    
    public var SessionCookie: String
    {
        get
        {
            return _sessionCookie
        }
    }
    
    // MARK: Persistence
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(_user, forKey: UserSession.userKey)
        aCoder.encode(_sessionCookie, forKey: UserSession.sessionCookieKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        let user = aDecoder.decodeObject(forKey: UserSession.userKey) as! User
        let sessionCookie = aDecoder.decodeObject(forKey: UserSession.sessionCookieKey) as! String
        self.init(user: user, sessionCookie: sessionCookie)
    }

}
