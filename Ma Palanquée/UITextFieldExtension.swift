//
//  UITextFieldExtension.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 31/12/2016.
//  Copyright © 2016 David Guillemet. All rights reserved.
//

import Foundation

extension UITextField {
    
    class func connectFields(fields:[UITextField]) -> Void
    {
        guard let last = fields.last else {
            return
        }
        
        for i in 0 ..< fields.count - 1
        {
            fields[i].returnKeyType = .next
            fields[i].addTarget(fields[i+1], action: #selector(UIResponder.becomeFirstResponder), for: .editingDidEndOnExit)
        }
        last.returnKeyType = .go
        last.addTarget(last, action: #selector(UIResponder.resignFirstResponder), for: .editingDidEndOnExit)
    }
}
