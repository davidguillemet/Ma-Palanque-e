//
//  PopDatepicker.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 10/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

public class PopDatePicker : NSObject, UIPopoverPresentationControllerDelegate, DataPickerViewControllerDelegate {
    
    public typealias PopDatePickerCallback = (newDate : NSDate, forTextField : UITextField)->()
    
    var datePickerVC : PopDateViewController
    var popover : UIPopoverPresentationController?
    var textField : UITextField!
    var dataChanged : PopDatePickerCallback?
    var presented = false
    var offset : CGFloat = 8.0
    
    public init(forTextField: UITextField) {
        
        datePickerVC = PopDateViewController()
        self.textField = forTextField
        super.init()
    }
    
    public func pick(inViewController : UIViewController, initDate : NSDate?, dataChanged : PopDatePickerCallback) {
        
        if presented {
            return  // we are busy
        }
        
        datePickerVC.delegate = self
        datePickerVC.modalPresentationStyle = UIModalPresentationStyle.Popover
        datePickerVC.preferredContentSize = CGSizeMake(600,200)
        datePickerVC.currentDate = initDate
        
        popover = datePickerVC.popoverPresentationController
        if let _popover = popover {
            
            _popover.sourceView = textField
            _popover.sourceRect = CGRectMake(self.offset,textField.bounds.size.height,0,0)
            _popover.delegate = self
            self.dataChanged = dataChanged
            inViewController.presentViewController(datePickerVC, animated: true, completion: nil)
            presented = true
        }
    }
    
    public func adaptivePresentationStyleForPresentationController(PC: UIPresentationController) -> UIModalPresentationStyle {
        
        return .None
    }
    
    func datePickerVCDismissed(date : NSDate?) {
        
        if let _dataChanged = dataChanged {
            
            if let _date = date {
                
                _dataChanged(newDate: _date, forTextField: textField)
                
            }
        }
        presented = false
    }
}