//
//  User.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 11/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

class User: NSObject, NSCoding
{
    private static var nameKey: String = "name"
    private static var mailKey: String = "mail"

    private let _name: String
    private let _mail: String
    
    init(name: String, mail: String)
    {
        self._name = name
        self._mail = mail
    }
    
    public var name: String
    {
        get
        {
            return _name
        }
    }
    
    public var mail: String
    {
        get
        {
            return _mail
        }
    }

    // MARK: Persistence
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(_name, forKey: User.nameKey)
        aCoder.encode(_mail, forKey: User.mailKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        let name = aDecoder.decodeObject(forKey: User.nameKey) as! String
        let mail = aDecoder.decodeObject(forKey: User.mailKey) as! String
        self.init(name: name, mail: mail)
    }

}
