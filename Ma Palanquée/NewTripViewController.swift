//
//  NewTripViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 10/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class NewTripViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    var editionMode : Bool = false
    
    var datePicker: DatePickerViewHelper!
    
    var initialTrip: Trip?
    var newTrip: Trip?
    
    var nsDateFrom: Date?
    var nsDateTo: Date?
    var divers: Set<String>?
    var constraints: [Constraint]?
    
    @IBOutlet weak var tripDesc: UITextField!
    
    @IBOutlet weak var tripLocation: UITextField!
    
    @IBOutlet weak var tripDateFrom: UITextField!
    
    @IBOutlet weak var tripDateTo: UITextField!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var tripType: UISegmentedControl!
    
    @IBOutlet weak var diverSelectionButton: UIButton!
    
    @IBOutlet weak var constraintsButton: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IconHelper.SetIcon(forBarButtonItem: cancelButton, icon: Icon.CancelCircled, fontSize: 24)
        IconHelper.SetIcon(forBarButtonItem: saveButton, icon: Icon.Save, fontSize: 24)

        
        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.contentView, attribute: NSLayoutAttribute.topMargin, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.topMargin
            , multiplier: 1.0, constant: 8)
        self.view.addConstraint(topConstraint)
        
        if (self.initialTrip != nil)
        {
            self.editionMode = true
            
            self.title = self.initialTrip!.desc
            self.tripDesc.text = self.initialTrip!.desc
            self.tripLocation.text = self.initialTrip!.location
            
            self.tripDateFrom.text = DateHelper.stringFromDate(self.initialTrip!.dateFrom, fullStyle: true)
            self.nsDateFrom = initialTrip!.dateFrom
            
            self.tripDateTo.text = DateHelper.stringFromDate(self.initialTrip!.dateTo, fullStyle: true)
            self.nsDateTo = initialTrip!.dateTo
            
            if (self.initialTrip!.diveType == DiveType.exploration)
            {
                self.tripType.selectedSegmentIndex = 1
            }
            else
            {
                self.tripType.selectedSegmentIndex = 0
            }
            
            // Copy the list of divers in order to not modify th etrip divers before save
            self.divers = Set<String>(self.initialTrip!.divers)
            updateDiversSelectionButtonLabel()
            
            if (self.initialTrip!.constraints != nil)
            {
                self.constraints = [Constraint](self.initialTrip!.constraints!)
            }
        }

        
        // Do any additional setup after loading the view.
        tripDesc.delegate = self
        tripLocation.delegate = self
        tripDateFrom.delegate = self
        tripDateTo.delegate = self
        
        CheckConstraintsButton()
    }

    func CheckConstraintsButton()
    {
        if (self.divers == nil || self.divers!.isEmpty)
        {
            constraintsButton.isEnabled = false
        }
        else
        {
            constraintsButton.isEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resign()
    {
        tripDesc.resignFirstResponder()
        tripLocation.resignFirstResponder()
        tripDateFrom.resignFirstResponder()
        tripDateTo.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        return true;
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        textField.text = ""
        if (textField == tripDateFrom)
        {
            nsDateFrom = nil
        }
        else if (textField == tripDateTo)
        {
            nsDateTo = nil
        }
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        
        if (textField == tripDateFrom)
        {
            let maximumDate = self.initialTrip != nil ? self.initialTrip!.getMaximalStartDate(nsDateTo!) : nsDateTo
            let initialDate = nsDateFrom ?? nsDateTo
            
            datePicker = DatePickerViewHelper(textField: textField, initialDate: initialDate, minimumDate: nil, maximumDate: maximumDate, pickerMode: UIDatePickerMode.date, validationDelegate: { (newDate: Date, forTextField : UITextField) -> Bool in
                self.nsDateFrom = newDate;
                return true
            })
        }
        else if (textField == tripDateTo)
        {
            let minimalEndDate = self.initialTrip != nil ? self.initialTrip!.getMinimalEndDate(nsDateFrom!) : nsDateFrom
            let initialDate = nsDateTo ?? nsDateFrom
            
            datePicker = DatePickerViewHelper(textField: textField, initialDate: initialDate, minimumDate: minimalEndDate, maximumDate: nil, pickerMode: UIDatePickerMode.date, validationDelegate: { (newDate: Date, forTextField : UITextField) -> Bool in
                self.nsDateTo = newDate;
                return true
            })
        }
        
        return true
    }
    
    func updateDiversSelectionButtonLabel()
    {
        diverSelectionButton.setTitle("\(self.divers!.count) Plongeur(s)", for: UIControlState())
        diverSelectionButton.sizeToFit()
    }
    
    func validateTrip() -> Bool
    {
        // 1. Check dateTo and DateFrom consistence
        if (tripDesc.text == "")
        {
            MessageHelper.displayError("Il manque une petite description pour cette nouvelle sortie", controller: self)
            return false
        }
        // 2. Check Location
        if (tripLocation.text == "")
        {
            MessageHelper.displayError("Il faudrait renseigner un lieu pour cette nouvelle sortie", controller: self)
            return false
        }
        
        // 3. Check start date
        if (nsDateFrom == nil)
        {
            MessageHelper.displayError("Merci de renseigner une date de début", controller: self)
            return false
        }
        // 4. Check end date
        if (nsDateTo == nil)
        {
            MessageHelper.displayError("Merci de renseigner une date de fin", controller: self)
            return false
        }
        // 5. Check start date is not after end date...
        if ((Calendar.current as NSCalendar).compare(nsDateFrom!, to: nsDateTo!, toUnitGranularity: .day) == ComparisonResult.orderedDescending)
        {
            MessageHelper.displayError("Il semblerait que la sortie se termine avant d'avoir commencé!", controller: self)
            return false
        }
        
        let diveType: DiveType = self.tripType.selectedSegmentIndex == 0 ? DiveType.training : DiveType.exploration
        let localDivers: Set<String> = self.divers != nil ? self.divers! : Set<String>()
        
        if (initialTrip == nil)
        {
            // New Trip
            self.newTrip = Trip(location: tripLocation.text!, desc: tripDesc.text!, dateFrom: self.nsDateFrom!, dateTo: self.nsDateTo!, diveType: diveType, divers: localDivers, constraints: self.constraints)
        }
        else
        {
            // Update Trip
            self.initialTrip!.update(tripLocation.text!, desc: tripDesc.text!, dateFrom: self.nsDateFrom!, dateTo: self.nsDateTo!, diveType: diveType, divers: localDivers, constraints: self.constraints)
        }
        
        return true
    }
    
    @IBAction func onCancel(_ sender: Any)
    {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        if ((sender as AnyObject) === saveButton)
        {
            if (!validateTrip())
            {
                // Oops, trip is not valid...cancel segue
                return false
            }
        }
        
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if ((sender as AnyObject) === saveButton)
        {
            // Nothing here...
        }
        else if ((sender as AnyObject) === diverSelectionButton)
        {
            let targetNavController = segue.destination as? UINavigationController
            let targetController = targetNavController?.topViewController as? DiversTableViewController
            if (self.divers != nil)
            {
                targetController?.selection = self.divers!
            }
            targetController?.trip = self.initialTrip
            targetController?.selectionType = DiversSelectionType.TripDivers
        }
        else if ((sender as AnyObject) === constraintsButton)
        {
            let targetNavController = segue.destination as? UINavigationController
            let targetController = targetNavController?.topViewController as? ConstraintsTableViewController
            if (self.divers != nil)
            {
                targetController?.constraints = self.constraints
                targetController?.divers = self.divers
            }
        }
   }
    
    @IBAction func unwindToNewTrip(_ sender: UIStoryboardSegue)
    {
        let diversController = sender.source as? DiversTableViewController
        if (diversController != nil)
        {
            self.divers = diversController?.selection
            updateDiversSelectionButtonLabel()
            CheckConstraintsButton()
            return
        }
    }
    
}
