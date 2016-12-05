//
//  PopDateViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 10/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

protocol DataPickerViewControllerDelegate : class {
    
    func datePickerVCDismissed(_ date : Date?)
}

class PopDateViewController : UIViewController {
    
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    weak var delegate : DataPickerViewControllerDelegate?
    
    var currentDate : Date? {
        didSet {
            updatePickerCurrentDate()
        }
    }
    
    convenience init() {
        self.init(nibName: "PopDateViewController", bundle: nil)
    }
    
    fileprivate func updatePickerCurrentDate() {
        
        if let _currentDate = self.currentDate {
            if let _datePicker = self.datePicker {
                _datePicker.date = _currentDate
            }
        }
    }
    
    @IBAction func onOk(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
            let nsdate = self.datePicker.date
            self.delegate?.datePickerVCDismissed(nsdate)
            
        }
    }
    
    override func viewDidLoad() {
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.locale = Locale.init(identifier:"fr")
        datePicker.timeZone = TimeZone.autoupdatingCurrent
        updatePickerCurrentDate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        self.delegate?.datePickerVCDismissed(nil)
    }
}
