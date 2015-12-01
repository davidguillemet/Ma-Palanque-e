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
    
    var diveDate: NSDate?
    var diveTime: NSDate?
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
    @IBOutlet weak var generateGroups: UIButton!
    @IBOutlet weak var viewGroupsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.tableFooterView = UIView()
        diveSiteTextfield.borderStyle = .None
        diveDateTextField.borderStyle = .None
        diveDirectorTextField.borderStyle = .None
        diveTimeTextField.borderStyle = .None
        
        diveSiteTextfield.delegate = self
        diveDateTextField.delegate = self
        diveDirectorTextField.delegate = self
        diveTimeTextField.delegate = self
        
        if (initialDive == nil)
        {
            self.title = "Nouvelle Plongée"
        }
        else
        {
            self.title = "Modifier une plongée"
            self.editionMode = true

            self.groups = self.initialDive!.groups
            self.diveDate = self.initialDive!.date
            self.diveTime = self.initialDive!.time
            self.diveDirector = DiverManager.GetDiver(self.initialDive!.director)
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

        if (initialDive == nil || initialDive!.groups == nil || initialDive!.groups!.count == 0)
        {
            viewGroupsLabel.text = "Générer les palanquées"
        }
        else
        {
            viewGroupsLabel.text = "Afficher les palanquées"
        }
        
        updateExcludedDiversButtonLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 6
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return self.trip.desc
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView
        {
            headerView.textLabel?.textAlignment = .Center
        }
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
        
        excludedDiversButton.setTitle("\(self.excludedDivers.count) Plongeur(s) au repos", forState: .Normal)
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
        
        // New Dive
        if (initialDive != nil)
        {
            initialDive!.update(diveDate!, time: diveTime!, site: diveSiteTextfield.text!, director: diveDirector!.id, groups: self.groups, excludedDivers: self.excludedDivers)
        }
        else
        {
            self.newdive = Dive(date: diveDate!, time: diveTime!, site: diveSiteTextfield.text!, director: diveDirector!.id, groups: self.groups, excludedDivers: self.excludedDivers)
        }
        
        return true
    }


    // MARK: - Navigation

    @IBAction func unwindToNewDive(sender: UIStoryboardSegue)
    {
        let diversController = sender.sourceViewController as? DiversTableViewController
        if (diversController != nil)
        {
            self.excludedDivers = (diversController?.selection)!
            updateExcludedDiversButtonLabel()
        }
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let targetNavController = segue.destinationViewController as? UINavigationController
        
        if (segue.identifier == "ExcludedDivers" ||
            segue.identifier == "ExcludedDiversFromRow")
        {
            let targetController = targetNavController?.topViewController as? DiversTableViewController
            targetController?.selection = excludedDivers
            
            // Get the list of divers from the group list
            var usedDivers: Set<String> = Set<String>()
            if (self.initialDive != nil && self.initialDive!.groups != nil && self.initialDive!.groups!.count > 0)
            {
                for group in self.initialDive!.groups!
                {
                    if (group.divers != nil)
                    {
                        group.divers!.forEach({ (diver: String) -> Void in
                          usedDivers.insert(diver)
                        })
                    }
                }
            }
            
            // build a diver list from the current trip
            var tripDivers: [Diver] = [Diver]()
            for diver in trip.divers
            {
                // Exclude the dive current dive director
                if (self.diveDirector != nil && self.diveDirector!.id == diver || usedDivers.contains(diver))
                {
                    continue
                }
                tripDivers.append(DiverManager.GetDiver(diver))
            }
            
            targetController?.initialDivers = tripDivers
            targetController?.selectionType = "DiveExcludedDivers"
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
    
    func textFieldShouldClear(textField: UITextField) -> Bool
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

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        if (textField === diveDirectorTextField)
        {
            // We must remove excluded divers from possible dice directors
            var possibleDirectors = [Diver]()
            for id in self.trip.divers
            {
                if (excludedDivers.contains(id))
                {
                    continue
                }
                let diver = DiverManager.GetDiver(id)
                if (diver.level.rawValue >= DiveLevel.E3.rawValue || diver.trainingLevel?.rawValue == DiveLevel.E3.rawValue)
                {
                    possibleDirectors.append(diver)
                }
            }
            
            // Sort possible directors
            possibleDirectors = possibleDirectors.sort({ (d1: Diver, d2: Diver) -> Bool in
                return d1.lastName < d2.lastName
            })
            
            pickerHelper = PickerViewHelper(textField: diveDirectorTextField, elements: possibleDirectors, onSelection: { (selection: AnyObject) -> Void in
                self.diveDirector = selection as? Diver
            })
        }
        else if (textField === diveDateTextField)
        {
            datePickerHelper = DatePickerViewHelper(textField: diveDateTextField, initialDate: self.diveDate ?? trip.dateFrom , minimumDate: trip.dateFrom, maximumDate: trip.dateTo, pickerMode: UIDatePickerMode.Date, validationDelegate: { (newDate: NSDate, forTextField: UITextField) -> Bool in
                self.diveDate = newDate;
                return true
            })
        }
        else if (textField === diveTimeTextField)
        {
            timePickerHelper = DatePickerViewHelper(textField: diveTimeTextField, initialDate: self.diveTime, minimumDate: nil, maximumDate: nil, pickerMode: UIDatePickerMode.Time, validationDelegate: { (newDate: NSDate, forTextField: UITextField) -> Bool in
                self.diveTime = newDate;
                return true
            })
        }
        
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        self.diveSiteTextfield.resignFirstResponder()
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func cancelAction(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
