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
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return sections.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.sections[orderedSections[section]]!.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.orderedSections[section]
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor ( red: 0.7687, green: 0.9521, blue: 0.9974, alpha: 1.0 )
        headerView.textLabel?.textAlignment = .Center
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("DiveCell", forIndexPath: indexPath) as! DiveTableViewCell
        
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

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let dive: Dive = self.getDive(indexPath)
        var actions = [UITableViewRowAction]()
        
        let editAction = UITableViewRowAction(style: .Default, title: "Edit", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.tableView.editing = false
            self.performSegueWithIdentifier("EditDive", sender: dive)
        })
        
        editAction.backgroundColor = ColorHelper.PendingGroup
        actions.append(editAction)
    
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.deleteDive(action, indexPath: indexPath)
        })
    
        deleteAction.backgroundColor = ColorHelper.DeleteColor
        actions.append(deleteAction)
    
        return actions
    }
    
    func deleteDive(action:UITableViewRowAction!, indexPath:NSIndexPath!)
    {
        let dive2Delete: Dive = getDive(indexPath)
        MessageHelper.confirmAction("Etes-vous sûr de vouloir supprimer la plongée '\(dive2Delete.site)' du \(DateHelper.stringFromDate(dive2Delete.date, fullStyle: false)) à \(DateHelper.stringFromTime(dive2Delete.time))?", controller: self, onOk: {() -> Void in
            
            // Delete the dive object
            TripManager.RemoveDive(dive2Delete, trip: self.trip)
            
            let sectionId = self.orderedSections[indexPath.section]
            
            // Remove the dive from the section in the data model:
            self.sections[sectionId]!.removeAtIndex(indexPath.row)
            
            // Delete the row from the data source
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)

            // Now, remove the section from data model if needed
            if (self.sections[sectionId]!.isEmpty)
            {
                self.sections[sectionId] = nil
                self.orderedSections.removeAtIndex(indexPath.section)
                self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
            }
        },
        onCancel: {(Void) -> Void in
            self.tableView.editing = false
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
        var orderedSections: [NSDate] = self.sections.keys.map({ (key: String) -> NSDate in
            return DateHelper.dateFromString(key, fullStyle: false)!
        })
        
        // Sort the key array
        orderedSections = orderedSections.sort({ (d1: NSDate, d2: NSDate) -> Bool in
            return (NSCalendar.currentCalendar().compareDate(d1, toDate: d2, toUnitGranularity: .Day) == NSComparisonResult.OrderedAscending)
        })
        
        // Convert the ordered NSDate array to a String array
        self.orderedSections = orderedSections.map({ ( key: NSDate ) -> String in
            return DateHelper.stringFromDate(key, fullStyle: false)
        })
        
        // Sort each dive array depending on the hour
        for (date, dives) in self.sections
        {
            self.sections[date] = dives.sort({ (d1: Dive, d2: Dive) -> Bool in
                return (NSCalendar.currentCalendar().compareDate(d1.time, toDate: d2.time, toUnitGranularity: .Hour) == NSComparisonResult.OrderedAscending)
            })
        }
    }
    
    func reloadDataTable()
    {
        prepareSections()
        tableView.reloadData()
    }


    // MARK: Actions
    
    @IBAction func doneAction(sender: AnyObject)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation

    @IBAction func unwindToDiveList(sender: UIStoryboardSegue)
    {
        let diveController = sender.sourceViewController as? NewDiveTableViewController
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
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let targetNavController = segue.destinationViewController as? UINavigationController
        
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
                let indexPath = tableView.indexPathForCell(selectedDiveCell!)!
                let dive: Dive = getDive(indexPath)
                targetController.trip = trip
                targetController.dive = dive
            }
        }
    }
    
    // MARK : Utils
    func getDive(indexPath: NSIndexPath) -> Dive
    {
        return self.sections[orderedSections[indexPath.section]]![indexPath.row]
    }
    
    
    //MARK: Search
    
    override func InternalProcessFilter(searchController: UISearchController)
    {
        let searchPredicate = NSPredicate(format: "site CONTAINS[c] %@", searchController.searchBar.text!)
        
        let array = (trip.getDives() as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        filteredDives = array as! [Dive]
        
        prepareSections()
    }

    override func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        super.searchBarCancelButtonClicked(searchBar)
        prepareSections()
    }

}
