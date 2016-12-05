//
//  DivesTableViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 20/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class DivesTableViewController: SearchableTableViewController
{

    var trip: Trip!
    var filteredDives = [Dive]()
    
    var sections: [String: [Dive]] = [String: [Dive]]()
    var orderedSections: [String]!
        
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IconHelper.SetBarButtonIcon(doneButton, icon: IconValue.IconDone, fontSize: nil, center: false)
        IconHelper.SetBarButtonIcon(addButton, icon: IconValue.IconPlus, fontSize: nil, center: false)

        self.title = trip.desc
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        reloadDataTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.sections[orderedSections[section]]!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.orderedSections[section]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor ( red: 0.7687, green: 0.9521, blue: 0.9974, alpha: 1.0 )
        headerView.textLabel?.textAlignment = .center
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "DiveCell", for: indexPath) as! DiveTableViewCell
        
        let dives = self.sections[orderedSections[indexPath.section]]
        let dive = dives![indexPath.row]
        
        cell.diveSiteTextField.text = dive.site
        cell.diveTimeTextField.text = DateHelper.stringFromTime(dive.time)
        
        return cell
    }

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

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let dive: Dive = self.getDive(indexPath)
        var actions = [UITableViewRowAction]()
        
        let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.tableView.isEditing = false
            self.performSegue(withIdentifier: "EditDive", sender: dive)
        })
        
        editAction.backgroundColor = ColorHelper.PendingTrip
        actions.append(editAction)
    
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.deleteDive(action, indexPath: indexPath)
        })
    
        deleteAction.backgroundColor = ColorHelper.DeleteColor
        actions.append(deleteAction)
    
        return actions
    }
    
    func deleteDive(_ action:UITableViewRowAction!, indexPath:IndexPath!)
    {
        let dive2Delete: Dive = getDive(indexPath)
        MessageHelper.confirmAction("Etes-vous sûr de vouloir supprimer la plongée '\(dive2Delete.site)' du \(DateHelper.stringFromDate(dive2Delete.date, fullStyle: false)) à \(DateHelper.stringFromTime(dive2Delete.time))?", controller: self, onOk: {() -> Void in
            
            // Delete the dive object
            TripManager.RemoveDive(dive2Delete, trip: self.trip)
            
            let sectionId = self.orderedSections[indexPath.section]
            
            // Remove the dive from the section in the data model:
            self.sections[sectionId]!.remove(at: indexPath.row)
            
            // Delete the row from the data source
            self.tableView.deleteRows(at: [indexPath], with: .fade)

            // Now, remove the section from data model if needed
            if (self.sections[sectionId]!.isEmpty)
            {
                self.sections[sectionId] = nil
                self.orderedSections.remove(at: indexPath.section)
                self.tableView.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
            }
        },
        onCancel: {(Void) -> Void in
            self.tableView.isEditing = false
        })
    }

    func prepareSections()
    {
        // Calculate number of sections
        self.sections = [String: [Dive]]()
        
        let dives = DisplaySearchResult() ? filteredDives : trip.getDives()
        
        for dive in dives
        {
            let diveDate: String = DateHelper.stringFromDate(dive.date, fullStyle: false)
            if let _ = sections[diveDate]
            {
                sections[diveDate]!.append(dive)
            }
            else
            {
                let dives: [Dive] = [dive]
                sections[diveDate] = dives
            }
        }
        
        // Create an array containing keys as NSDates
        var orderedSections: [Date] = self.sections.keys.map({ (key: String) -> Date in
            return DateHelper.dateFromString(key, fullStyle: false)!
        })
        
        // Sort the key array
        orderedSections = orderedSections.sorted(by: { (d1: Date, d2: Date) -> Bool in
            return ((Calendar.current as NSCalendar).compare(d1, to: d2, toUnitGranularity: .day) == ComparisonResult.orderedAscending)
        })
        
        // Convert the ordered NSDate array to a String array
        self.orderedSections = orderedSections.map({ ( key: Date ) -> String in
            return DateHelper.stringFromDate(key, fullStyle: false)
        })
        
        // Sort each dive array depending on the hour
        for (date, dives) in self.sections
        {
            self.sections[date] = dives.sorted(by: { (d1: Dive, d2: Dive) -> Bool in
                return ((Calendar.current as NSCalendar).compare(d1.time, to: d2.time, toUnitGranularity: .hour) == ComparisonResult.orderedAscending)
            })
        }
    }
    
    func reloadDataTable()
    {
        prepareSections()
        tableView.reloadData()
    }


    // MARK: Actions
    
    @IBAction func doneAction(_ sender: AnyObject)
    {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    @IBAction func unwindToDiveList(_ segue: UIStoryboardSegue)
    {
        if (segue.identifier == "SaveDiveGroups")
        {
            if let diveGroupsController = segue.source as? DiveGroupsCollectionViewController
            {
                // Update the new Dive groups from controller
                let dive = diveGroupsController.dive!
                dive.groups = diveGroupsController.groups
                
                // Update excluded divers
                diveGroupsController.newExcludedDivers.forEach({ (diver: String) -> Void in
                    dive.excludedDivers?.insert(diver)
                })
            }
        }
        else if (segue.identifier == "UnwindToDiveList")
        {
            let diveController = segue.source as? NewDiveTableViewController
            if (diveController == nil)
            {
                return
            }
        
            if (diveController!.editionMode)
            {
                TripManager.Persist()
            }
            else
            {
                TripManager.AddDive(diveController!.newdive!, trip: trip)
            }
        
            // Reload the whole table since the updated/new might be moved to any row in the table
            // depending on the date property
            reloadDataTable()
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let targetNavController = segue.destination as? UINavigationController
        
        if (segue.identifier == "EditDive")
        {
            let targetController = targetNavController?.topViewController as? NewDiveTableViewController
            targetController!.trip = self.trip
            targetController!.initialDive = sender as? Dive
        }
        else if (segue.identifier == "ShowDiveGroups")
        {
            let targetController = targetNavController?.topViewController as! DiveGroupsCollectionViewController
            let selectedDiveCell = sender as? DiveTableViewCell
            if (selectedDiveCell != nil)
            {
                let indexPath = tableView.indexPath(for: selectedDiveCell!)!
                let dive: Dive = getDive(indexPath)
                targetController.trip = trip
                targetController.dive = dive
            }
        }
    }
    
    // MARK : Utils
    func getDive(_ indexPath: IndexPath) -> Dive
    {
        return self.sections[orderedSections[indexPath.section]]![indexPath.row]
    }
    
    
    //MARK: Search
    
    override func InternalProcessFilter(_ searchController: UISearchController)
    {
        let searchPredicate = NSPredicate(format: "site CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (trip.getDives() as NSArray).filtered(using: searchPredicate)
        
        filteredDives = array as! [Dive]
        
        prepareSections()
    }

    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        super.searchBarCancelButtonClicked(searchBar)
        prepareSections()
    }

}
