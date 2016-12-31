//
//  NewDiveTableViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 22/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class NewDiveTableViewController: UITableViewController, UITextFieldDelegate  {

    var editionMode : Bool = false
    
    var trip: Trip!

    var initialDive: Dive?
    var newdive: Dive?
    
    var diveDate: Date?
    var diveTime: Date?
    var diveDirector: Diver?
    var excludedDivers: Set<String> = Set<String>()
    var groups: [Group]?

    var pickerHelper: PickerViewHelper!
    var datePickerHelper: DatePickerViewHelper!
    var timePickerHelper: DatePickerViewHelper!

    @IBOutlet weak var diveSiteTextfield: UITextField!
    @IBOutlet weak var diveDateTextField: UITextField!
    @IBOutlet weak var diveTimeTextField: UITextField!
    @IBOutlet weak var diveDirectorTextField: UITextField!
    @IBOutlet weak var diveDiversLabel: UILabel!
    @IBOutlet weak var excludedDiversButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var diveTypeSwitch: UISwitch!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        IconHelper.SetIcon(forBarButtonItem: saveButton, icon: Icon.Save, fontSize: 24)
        IconHelper.SetIcon(forBarButtonItem: cancelButton, icon: Icon.CancelCircled, fontSize: 24)
        
        TableViewHelper.ConfigureTable(tableView: self.tableView)
        
        UITextField.connectFields(fields: [diveSiteTextfield, diveDateTextField, diveTimeTextField, diveDirectorTextField])
        
        diveSiteTextfield.borderStyle = .none
        diveDateTextField.borderStyle = .none
        diveDirectorTextField.borderStyle = .none
        diveTimeTextField.borderStyle = .none
        
        diveSiteTextfield.delegate = self
        diveDateTextField.delegate = self
        diveDirectorTextField.delegate = self
        diveTimeTextField.delegate = self
        
        if (initialDive == nil)
        {
            self.title = "Nouvelle Plongée"
            
            // Initialize doive type from trip type
            if (self.trip.diveType == DiveType.training)
            {
                self.diveTypeSwitch.setOn(true, animated: false)
            }
            else
            {
                self.diveTypeSwitch.setOn(false, animated: false)
            }
        }
        else
        {
            self.title = "Modifier une plongée"
            self.editionMode = true

            self.groups = self.initialDive!.groups
            self.diveDate = self.initialDive!.date
            self.diveTime = self.initialDive!.time
            self.diveDirector = DiverManager.GetDiver(self.initialDive!.director)
            
            if (self.initialDive!.diveType == DiveType.training)
            {
                self.diveTypeSwitch.setOn(true, animated: false)
            }
            else
            {
                self.diveTypeSwitch.setOn(false, animated: false)
            }
            
            if (self.initialDive!.excludedDivers != nil)
            {
                self.excludedDivers = self.initialDive!.excludedDivers!
            }
            
            // Populate UI fields
            diveSiteTextfield.text = self.initialDive!.site
            diveDateTextField.text = DateHelper.stringFromDate(self.initialDive!.date, fullStyle: true)
            diveTimeTextField.text = DateHelper.stringFromTime(self.initialDive!.time)
            diveDirectorTextField.text = self.diveDirector!.description
        }
        
        updateExcludedDiversButtonLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return self.trip.desc
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        if let headerView = view as? UITableViewHeaderFooterView
        {
            headerView.textLabel?.textAlignment = .center
            headerView.contentView.backgroundColor = ColorHelper.TableViewBackground
        }
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    func updateExcludedDiversButtonLabel()
    {
        diveDiversLabel.text = "\(trip.divers.count - self.excludedDivers.count) Plongeur(s)"
        
        excludedDiversButton.setTitle("\(self.excludedDivers.count) Plongeur(s) au repos", for: UIControlState())
        excludedDiversButton.sizeToFit()
    }

    func validateDive() -> Bool
    {
        // 1. Check Dive site
        if (diveSiteTextfield.text == "")
        {
            MessageHelper.displayError("Le site de la plongée n'est pas renseigné", controller: self)
            return false
        }
        
        // 2. Check Dive Date
        if (diveDate == nil)
        {
            MessageHelper.displayError("La date de la plongée n'est pas renseignée", controller: self)
            return false
        }
        
        // 3. Check Dive Time
        if (diveTime == nil)
        {
            MessageHelper.displayError("L'heure de la plongée n'est pas renseignée", controller: self)
            return false
        }
        
        // 3. Check Dive Director
        if (self.diveDirector == nil)
        {
            MessageHelper.displayError("Le directeur de plongée n'est pas renseigné", controller: self)
            return false
        }
        
        var diveType: DiveType!
        
        if self.diveTypeSwitch.isOn
        {
            diveType = DiveType.training
        }
        else
        {
            diveType = DiveType.exploration
        }
        
        // New Dive
        if (initialDive != nil)
        {
            initialDive!.update(diveDate!, time: diveTime!, site: diveSiteTextfield.text!, director: diveDirector!.id, diveType: diveType, groups: self.groups, excludedDivers: self.excludedDivers)
        }
        else
        {
            self.newdive = Dive(date: diveDate!, time: diveTime!, site: diveSiteTextfield.text!, director: diveDirector!.id, diveType: diveType, groups: self.groups, excludedDivers: self.excludedDivers)
        }
        
        return true
    }


    // MARK: - Navigation

    @IBAction func unwindToNewDive(_ sender: UIStoryboardSegue)
    {
        let diversController = sender.source as? DiversTableViewController
        if (diversController != nil)
        {
            self.excludedDivers = (diversController?.selection)!
            updateExcludedDiversButtonLabel()
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool
    {
        if (identifier == "UnwindToDiveList")
        {
            if (!validateDive())
            {
                // Oops, dive is not valid...cancel segue
                return false
            }
        }
        
        return true
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let targetNavController = segue.destination as? UINavigationController
        
        if (segue.identifier == "ExcludedDivers" ||
            segue.identifier == "ExcludedDiversFromRow")
        {
            let targetController = targetNavController?.topViewController as? DiversTableViewController
            targetController?.selection = excludedDivers
            targetController?.dive = initialDive
            targetController?.initialDivers = trip.divers.map{ (diverId: String) -> Diver in return DiverManager.GetDiver(diverId) }
            targetController?.selectionType = DiversSelectionType.DiveExcludedDivers
        }
        else if (segue.identifier == "ShowDiveGroups")
        {
            let targetController = targetNavController?.topViewController as! DiveGroupsCollectionViewController
            let selectedDiveCell = sender as? DiveTableViewCell
            if (selectedDiveCell != nil)
            {
                targetController.trip = trip
            }
        }
    }

    
    // MARK: Actions
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool
    {
        textField.text = ""
        if (textField === diveDirectorTextField)
        {
            diveDirector = nil
        }
        else if (textField === diveDateTextField)
        {
            self.diveDate = nil
        }
        return false
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        if (textField === diveDirectorTextField)
        {
            // Get possible dive directors from level >= E3 or training level is E3
            var possibleDirectors = [Diver]()
            for id in self.trip.divers
            {
                let diver = DiverManager.GetDiver(id)
                if (diver.level.rawValue >= DiveLevel.e3.rawValue || diver.trainingLevel?.rawValue == DiveLevel.e3.rawValue)
                {
                    possibleDirectors.append(diver)
                }
            }
            
            // Sort possible directors
            possibleDirectors = possibleDirectors.sorted(by: { (d1: Diver, d2: Diver) -> Bool in
                return d1.lastName < d2.lastName
            })
            
            pickerHelper = PickerViewHelper(textField: diveDirectorTextField, elements: possibleDirectors, onSelection: { (selection: AnyObject) -> Void in
                self.diveDirector = selection as? Diver
            })
        }
        else if (textField === diveDateTextField)
        {
            datePickerHelper = DatePickerViewHelper(textField: diveDateTextField, initialDate: self.diveDate ?? trip.dateFrom , minimumDate: trip.dateFrom, maximumDate: trip.dateTo, pickerMode: UIDatePickerMode.date, validationDelegate: { (newDate: Date, forTextField: UITextField) -> Bool in
                self.diveDate = newDate;
                return true
            })
        }
        else if (textField === diveTimeTextField)
        {
            timePickerHelper = DatePickerViewHelper(textField: diveTimeTextField, initialDate: self.diveTime, minimumDate: nil, maximumDate: nil, pickerMode: UIDatePickerMode.time, validationDelegate: { (newDate: Date, forTextField: UITextField) -> Bool in
                self.diveTime = newDate;
                return true
            })
        }
        
        return true
    }

    /*func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.diveSiteTextfield.resignFirstResponder()
        self.view.endEditing(true)
        return false
    }*/
    
    
    @IBAction func onCancelAction(_ sender: Any)
    {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}
