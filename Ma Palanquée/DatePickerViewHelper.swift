//
//  DatePickerViewHelper.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 22/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit
import Foundation

class DatePickerViewHelper: AbstractPickerViewHelper
{
    typealias DatePickerCallback = (_ newDate : Date, _ forTextField : UITextField)-> Bool
 
    var pickerView = UIDatePicker()
    
    var pickerMode: UIDatePickerMode?
    var selectedDate: Date?
    var validationDelegate: DatePickerCallback?
  
    init(textField: UITextField, initialDate: Date?, minimumDate: Date?, maximumDate: Date?, pickerMode: UIDatePickerMode, validationDelegate: DatePickerCallback?)
    {
        super.init(textField: textField)
        
        self.pickerMode = pickerMode
        self.validationDelegate = validationDelegate
        
        textField.inputView = pickerView
        
        if (initialDate != nil)
        {
            pickerView.date = initialDate!
        }
        pickerView.datePickerMode = pickerMode
        if (self.pickerMode == UIDatePickerMode.time)
        {
            pickerView.minuteInterval = 15
        }
        pickerView.locale = Locale.init(identifier:"fr")
        pickerView.timeZone = TimeZone.autoupdatingCurrent
        pickerView.addTarget(self, action: #selector(DatePickerViewHelper.datePickerValueChanged(_:)), for: UIControlEvents.valueChanged)
        
        pickerView.minimumDate = minimumDate
        pickerView.maximumDate = maximumDate
    }
    
    func datePickerValueChanged(_ sender:UIDatePicker)
    {
        selectedDate = pickerView.date
        updateField()
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
        if (validationDelegate != nil && validationDelegate!(selectedDate ?? pickerView.date, self.textField))
        {
            if (self.pickerMode == UIDatePickerMode.time)
            {
                textField.text = DateHelper.stringFromTime(selectedDate ?? pickerView.date)
            }
            else
            {
                textField.text = DateHelper.stringFromDate(selectedDate ?? pickerView.date, fullStyle: true)
            }
        }
    }
    
}
