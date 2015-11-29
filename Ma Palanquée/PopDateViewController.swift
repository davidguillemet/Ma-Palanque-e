//
//  PopDateViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 10/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

protocol DataPickerViewControllerDelegate : class {
    
    func datePickerVCDismissed(date : NSDate?)
}

class PopDateViewController : UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate : DataPickerViewControllerDelegate?
    
    var currentDate : NSDate? {
        didSet {
            updatePickerCurrentDate()
        }
    }
    
    convenience init() {
        self.init(nibName: "PopDateViewController", bundle: nil)
    }
    
    private func updatePickerCurrentDate() {
        
        if let _currentDate = self.currentDate {
            if let _datePicker = self.datePicker {
                _datePicker.date = _currentDate
            }
        }
    }
    
    @IBAction func onOk(sender: UIButton) {
        self.dismissViewControllerAnimated(true) {
            
            let nsdate = self.datePicker.date
            self.delegate?.datePickerVCDismissed(nsdate)
            
        }
    }
    
    override func viewDidLoad() {
        datePicker.datePickerMode = UIDatePickerMode.Date
        datePicker.locale = NSLocale.init(localeIdentifier:"fr")
        datePicker.timeZone = NSTimeZone.localTimeZone()
        updatePickerCurrentDate()
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        self.delegate?.datePickerVCDismissed(nil)
    }
}