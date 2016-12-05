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
    class func displayError(_ msg: String, controller: UIViewController)
    {
        let alert:UIAlertController = UIAlertController(title: "Oops...", message: msg, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in }))
        controller.present(alert, animated:true, completion:nil);
    }
    
    class func confirmAction(_ msg: String, controller: UIViewController, onOk: @escaping ((Void) -> Void), onCancel: ((Void) -> Void)?)
    {
        let alert:UIAlertController = UIAlertController(title: "", message: msg, preferredStyle:.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            onOk()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            onCancel?()
        }))
        controller.present(alert, animated:true, completion: nil);
    }
}
