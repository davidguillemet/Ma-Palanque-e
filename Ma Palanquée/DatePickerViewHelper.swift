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
    typealias DatePickerCallback = (newDate : NSDate, forTextField : UITextField)-> Bool
 
    var pickerView = UIDatePicker()
    
    var pickerMode: UIDatePickerMode?
    var selectedDate: NSDate?
    var validationDelegate: DatePickerCallback?
  
    init(textField: UITextField, initialDate: NSDate?, minimumDate: NSDate?, maximumDate: NSDate?, pickerMode: UIDatePickerMode, validationDelegate: DatePickerCallback?)
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
        if (self.pickerMode == UIDatePickerMode.Time)
        {
            pickerView.minuteInterval = 15
        }
        pickerView.locale = NSLocale.init(localeIdentifier:"fr")
        pickerView.timeZone = NSTimeZone.localTimeZone()
        pickerView.addTarget(self, action: Selector("datePickerValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        
        pickerView.minimumDate = minimumDate
        pickerView.maximumDate = maximumDate
    }
    
    func datePickerValueChanged(sender:UIDatePicker)
    {
        selectedDate = pickerView.date
    }
    
    func donePicker()
    {
        if (validationDelegate != nil && validationDelegate!(newDate: selectedDate ?? pickerView.date, forTextField: self.textField))
        {
            if (self.pickerMode == UIDatePickerMode.Time)
            {
                textField.text = DateHelper.stringFromTime(selectedDate ?? pickerView.date)
            }
            else
            {
                textField.text = DateHelper.stringFromDate(selectedDate ?? pickerView.date, fullStyle: true)
            }
            textField.endEditing(true)
        }
    }

}