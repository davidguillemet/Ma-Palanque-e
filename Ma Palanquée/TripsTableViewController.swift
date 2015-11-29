//
//  TripsTableViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 07/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class TripsTableViewController: SearchableTableViewController {

    private enum TripScope: Int
    {
        case Pending = 0
        case Archived = 1
        case All = 2
    }
    
    var trips: [Trip]!
    var filteredTrips = [Trip]()
    var tripPosition = [String: Int]()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet var tripsTable: UITableView!
    @IBOutlet weak var tripScopeControl: UISegmentedControl!
    
    override func viewDidLoad() {
        
        IconHelper.SetBarButtonIcon(menuButton, icon: IconValue.IconMenu, fontSize: nil, center: false)
        IconHelper.SetBarButtonIcon(addButton, icon: IconValue.IconPlus, fontSize: nil, center: false)
        
        loadTrips()
        
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        // Reload the table
        reloadDataTable()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    func reloadDataTable()
    {
        tripPosition = [String: Int]()
        self.tableView.reloadData()
    }
    
    func getTrip(indexPath: NSIndexPath) -> Trip
    {
        if (DisplaySearchResult())
        {
            return self.filteredTrips[indexPath.row]
        }
        else
        {
            return self.trips![indexPath.row]
        }
    }
    
    func SetTripIconColor(iconLabel: UILabel, textColor: UIColor, bgColor: UIColor)
    {
        iconLabel.textColor = textColor
        iconLabel.layer.borderColor = textColor.CGColor
        iconLabel.backgroundColor = bgColor
        iconLabel.clipsToBounds = true
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (DisplaySearchResult())
        {
            return self.filteredTrips.count
        }
        else
        {
            return trips.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "TripTableViewCell"

        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! TripTableViewCell

        // Configure the cell...
        let trip: Trip = getTrip(indexPath)
        tripPosition[trip.id] = indexPath.row
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale.init(localeIdentifier:"fr")
        dateFormatter.dateStyle = NSDateFormatterStyle.MediumStyle

        IconHelper.SetCircledIcon(cell.tripIcon, icon: trip.tripType == TripType.exploration ? IconValue.IconPlane : IconValue.IconUniversity, fontSize: 18, center: true)
        
        SetTripIconColor(
            cell.tripIcon,
            textColor: trip.archived ? ColorHelper.ArchivedTrip : ColorHelper.PendingTrip,
            bgColor: trip.archived ? ColorHelper.ArchivedTripBackground : ColorHelper.PendingTripBackground)
        
        cell.tripNameLabel.text = trip.desc
        cell.tripDescLabel.text = trip.location
        cell.tripDateLabel.text = dateFormatter.stringFromDate(trip.dateFrom)  + " au " + dateFormatter.stringFromDate(trip.dateTo)
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 75
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {

    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        let trip: Trip = self.getTrip(indexPath)
        var actions = [UITableViewRowAction]()
        
        if (trip.archived)
        {
            // You cannot edit an archived action
            // -> Custom action to "open" it again
            let activateAction = UITableViewRowAction(style: .Default, title: "Activer", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                TripManager.ArchiveTrip(trip, archived: false)
                self.loadTrips()
                // Delete the row from the data source
                self.tableView.editing = false
                if (self.TripScope != TripScope.All.rawValue)
                {
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            })
            
            activateAction.backgroundColor = ColorHelper.PendingTrip
            
            actions.append(activateAction)
        }
        else
        {
            let archiveAction = UITableViewRowAction(style: .Default, title: "Archive", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                TripManager.ArchiveTrip(trip, archived: true)
                self.loadTrips()
                // Delete the row from the data source
                self.tableView.editing = false
                if (self.TripScope != TripScope.All.rawValue)
                {
                    self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            })
        
            let editAction = UITableViewRowAction(style: .Default, title: "Edit", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
                self.tableView.editing = false
                self.performSegueWithIdentifier("EditTrip", sender: trip)
            })
            
            archiveAction.backgroundColor = ColorHelper.ArchivedTrip
            editAction.backgroundColor = ColorHelper.PendingTrip
            
            actions.append(archiveAction)
            actions.append(editAction)
        }
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.deleteTrip(action, indexPath: indexPath)
        })
        
        deleteAction.backgroundColor = ColorHelper.DeleteColor
        
        actions.append(deleteAction)

        
        return actions
    }
    
    func deleteTrip(action:UITableViewRowAction!, indexPath:NSIndexPath!)
    {
        let trip2Delete: Trip = getTrip(indexPath)
        MessageHelper.confirmAction("Etes-vous sûr de vouloir supprimer la sortie '\(trip2Delete.desc)'", controller: self,
        onOk: {() -> Void in
            // Delete the Trip object
            TripManager.RemoveTrip(trip2Delete.id)
            // Reload trips
            self.loadTrips()
            // Delete the row from the data source
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        },
        onCancel: {() -> Void in
            self.tableView.editing = false
        })
    }
    
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

    // MARK: Actions
    
    private func refreshAll()
    {
        loadTrips()
        reloadDataTable()
    }
    
    private var TripScope: Int
    {
        get
        {
            return tripScopeControl.selectedSegmentIndex
        }
    }
    
    private func loadTrips()
    {
        self.trips = TripManager.GetTrips()
        
        switch self.TripScope
        {
        case TripScope.Pending.rawValue: // pending = non archived
            self.trips = self.trips.filter({ (t: Trip) -> Bool in
                return !t.archived
            })
        case TripScope.Archived.rawValue: // archived
            self.trips = self.trips.filter({ (t: Trip) -> Bool in
                return t.archived
            })
        default: break // TripScope.All.rawValue
            // Nothing to do...trips is already uinitialized
        }
    }
    
    @IBAction func tripScopeChanged(sender: UISegmentedControl)
    {
        refreshAll()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        let targetNavController = segue.destinationViewController as? UINavigationController

        if (segue.identifier == "DiveList")
        {
            let targetController = targetNavController?.topViewController as? DivesTableViewController
            let selectedTripCell = sender as? TripTableViewCell
            if (selectedTripCell != nil)
            {
                let indexPath = tableView.indexPathForCell(selectedTripCell!)!
                let trip: Trip = getTrip(indexPath)
                targetController?.trip = trip
            }
        }
        else if (segue.identifier == "EditTrip")
        {
            let targetController = targetNavController?.topViewController as? NewTripViewController
            let trip = sender as? Trip
            if (trip != nil)
            {
                targetController?.initialTrip = trip
            }
        }
    }
    
    @IBAction func unwindToTripList(sender: UIStoryboardSegue)
    {
        let sourceController = sender.sourceViewController as? NewTripViewController
        if (sourceController == nil)
        {
            return
        }
        
        if (sourceController!.editionMode)
        {
            // Just update the persisted trips
            TripManager.Persist()
        }
        else
        {
            // Insert a new row in the table
            TripManager.AddTrip(sourceController!.newTrip!)
        }
        // In any case, reload the whole table since the updated/new might be moved to any row in the tabme
        // depending on the dateFrom property
        refreshAll()
    }
    
    //MARK: Search
    
    override func InternalProcessFilter(searchController: UISearchController)
    {
        filteredTrips.removeAll(keepCapacity: false)
        
        let searchPredicate = NSPredicate(format: "location CONTAINS[c] %@ OR desc CONTAINS[c] %@", searchController.searchBar.text!, searchController.searchBar.text!)
        
        let array = (trips as NSArray).filteredArrayUsingPredicate(searchPredicate)
        
        filteredTrips = array as! [Trip]
    }


}
