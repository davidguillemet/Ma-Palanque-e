//
//  PopDatepicker.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 10/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

open class PopDatePicker : NSObject, UIPopoverPresentationControllerDelegate, DataPickerViewControllerDelegate {
    
    public typealias PopDatePickerCallback = (_ newDate : Date, _ forTextField : UITextField)->()
    
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
    
    open func pick(_ inViewController : UIViewController, initDate : Date?, dataChanged : @escaping PopDatePickerCallback) {
        
        if presented {
            return  // we are busy
        }
        
        datePickerVC.delegate = self
        datePickerVC.modalPresentationStyle = UIModalPresentationStyle.popover
        datePickerVC.preferredContentSize = CGSize(width: 600,height: 200)
        datePickerVC.currentDate = initDate
        
        popover = datePickerVC.popoverPresentationController
        if let _popover = popover {
            
            _popover.sourceView = textField
            _popover.sourceRect = CGRect(x: self.offset,y: textField.bounds.size.height,width: 0,height: 0)
            _popover.delegate = self
            self.dataChanged = dataChanged
            inViewController.present(datePickerVC, animated: true, completion: nil)
            presented = true
        }
    }
    
    open func adaptivePresentationStyle(for PC: UIPresentationController) -> UIModalPresentationStyle {
        
        return .none
    }
    
    func datePickerVCDismissed(_ date : Date?) {
        
        if let _dataChanged = dataChanged {
            
            if let _date = date {
                
                _dataChanged(_date, textField)
                
            }
        }
        presented = false
    }
}
