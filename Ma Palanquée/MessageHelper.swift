//
//  MessageHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 21/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

class MessageHelper
{
    class func displayError(msg: String, controller: UIViewController)
    {
        let alert:UIAlertController = UIAlertController(title: "Oops...", message: msg, preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in }))
        controller.presentViewController(alert, animated:true, completion:nil);
    }
    
    class func confirmAction(msg: String, controller: UIViewController, onOk: ((Void) -> Void), onCancel: ((Void) -> Void)?)
    {
        let alert:UIAlertController = UIAlertController(title: "", message: msg, preferredStyle:.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
            onOk()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action: UIAlertAction!) in
            onCancel?()
        }))
        controller.presentViewController(alert, animated:true, completion: nil);
    }
}
