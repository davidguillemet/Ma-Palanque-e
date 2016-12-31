//
//  PickerViewHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 22/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit
import Foundation

class PickerViewHelper: AbstractPickerViewHelper, UIPickerViewDataSource, UIPickerViewDelegate
{
    var elements: [AnyObject]!
    var selectedElement: Int = 0
    var onSelection: ((AnyObject) -> Void)?
    
    var pickerView = UIPickerView()
    
    init(textField: UITextField, elements: [AnyObject], onSelection: ((_ selectedObject: AnyObject) -> Void)?)
    {
        super.init(textField: textField)
        
        self.elements = elements
        self.onSelection = onSelection
        
        pickerView.dataSource = self
        pickerView.delegate = self
        textField.inputView = pickerView
    }
    
    //MARK: - Delegates and data sources
    
    //MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return elements.count
    }
    
    //MARK: Delegates
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return  elements[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        selectedElement = row
    }
    
    override func donePicker()
    {
        updateField()
        textField.endEditing(true)
    }
    
    override func nextPicker()
    {
        updateField()
        textField.resignFirstResponder()
        textField.sendActions(for: .editingDidEndOnExit)        
    }

    private func updateField()
    {
        textField.text = elements[selectedElement].description
        if (self.onSelection != nil)
        {
            onSelection!(elements[selectedElement])
        }
    }
}
