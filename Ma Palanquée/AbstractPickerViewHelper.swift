//
//  AbstractPickerViewHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 22/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import Foundation

import UIKit
import Foundation

class AbstractPickerViewHelper: NSObject
{
    var textField: UITextField!
    
    init(textField: UITextField)
    {
        super.init()
        
        self.textField = textField
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Terminé", style: UIBarButtonItemStyle.plain, target: self, action: Selector("donePicker"))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Annuler", style: UIBarButtonItemStyle.plain, target: self, action: #selector(AbstractPickerViewHelper.cancelPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
    }
        
    func cancelPicker()
    {
        textField.endEditing(true)
    }
}
