//
//  TripsTableViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 07/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class TripsTableViewController: SearchableTableViewController {

    fileprivate enum TripScope: Int
    {
        case pending = 0
        case archived = 1
        case all = 2
    }
    
    var trips: [Trip]!
    var filteredTrips = [Trip]()
    var tripPosition = [String: Int]()
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet var tripsTable: UITableView!
    @IBOutlet weak var tripScopeControl: UISegmentedControl!
    
    override func viewDidLoad() {
        
        IconHelper.SetIcon(forBarButtonItem: menuButton, icon: Icon.Menu, fontSize: 24)
        IconHelper.SetIcon(forBarButtonItem: addButton, icon: Icon.Plus, fontSize: 24)
        
        loadTrips()
        
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        TableViewHelper.ConfigureTable(tableView: tripsTable)

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
    
    func getTrip(_ indexPath: IndexPath) -> Trip
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
    
    func SetTripIconColor(_ iconLabel: UILabel, textColor: UIColor, bgColor: UIColor)
    {
        iconLabel.textColor = textColor
        iconLabel.layer.borderColor = textColor.cgColor
        iconLabel.backgroundColor = bgColor
        iconLabel.clipsToBounds = true
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
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

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "TripTableViewCell"

        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TripTableViewCell

        // Configure the cell...
        let trip: Trip = getTrip(indexPath)
        tripPosition[trip.id] = indexPath.row
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale.init(identifier:"fr")
        dateFormatter.dateStyle = DateFormatter.Style.medium

        IconHelper.SetCircledIcon(cell.tripIcon, icon: trip.diveType == DiveType.exploration ? Icon.Plane : Icon.University, fontSize: 18, center: true)
        
        SetTripIconColor(
            cell.tripIcon,
            textColor: trip.archived ? ColorHelper.ArchivedTrip : ColorHelper.PendingTrip,
            bgColor: trip.archived ? ColorHelper.ArchivedTripBackground : ColorHelper.PendingTripBackground)
        
        cell.tripNameLabel.text = trip.desc
        cell.tripDescLabel.text = trip.location
        cell.tripDateLabel.text = dateFormatter.string(from: trip.dateFrom)  + " au " + dateFormatter.string(from: trip.dateTo)
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        /*cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false*/
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {

    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let trip: Trip = self.getTrip(indexPath)
        var actions = [UITableViewRowAction]()
        
        if (trip.archived)
        {
            // You cannot edit an archived action
            // -> Custom action to "open" it again
            let activateAction = UITableViewRowAction(style: .default, title: "Activer", handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
                self.tableView.beginUpdates()
                
                TripManager.ArchiveTrip(trip, archived: false)
                self.loadTrips()
                
                // Delete the row from the data source
                self.tableView.isEditing = false
                if (self.TripScope != TripScope.all.rawValue)
                {
                    // remove item from list
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
                else
                {
                    // for the scope "All", we must refreah the item
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                }
                
                self.tableView.endUpdates()
            })
            
            activateAction.backgroundColor = ColorHelper.PendingTrip
            
            actions.append(activateAction)
        }
        else
        {
            let archiveAction = UITableViewRowAction(style: .default, title: "Archive", handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
                self.tableView.beginUpdates()
                
                TripManager.ArchiveTrip(trip, archived: true)
                self.loadTrips()
                // Delete the row from the data source
                self.tableView.isEditing = false
                if (self.TripScope != TripScope.all.rawValue)
                {
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
                else
                {
                    // for the scope "All", we must refreah the item
                    self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
                }
                
                self.tableView.endUpdates()
            })
        
            let editAction = UITableViewRowAction(style: .default, title: "Edit", handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
                self.tableView.beginUpdates()
                self.tableView.isEditing = false
                self.performSegue(withIdentifier: "EditTrip", sender: trip)
                self.tableView.endUpdates()
            })
            
            archiveAction.backgroundColor = ColorHelper.ArchivedTrip
            editAction.backgroundColor = ColorHelper.PendingTrip
            
            actions.append(archiveAction)
            actions.append(editAction)
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            self.deleteTrip(action, indexPath: indexPath)
        })
        
        deleteAction.backgroundColor = ColorHelper.DeleteColor
        
        actions.append(deleteAction)

        
        return actions
    }
    
    func deleteTrip(_ action:UITableViewRowAction!, indexPath:IndexPath!)
    {
        let trip2Delete: Trip = getTrip(indexPath)
        MessageHelper.confirmAction("Etes-vous sûr de vouloir supprimer la sortie '\(trip2Delete.desc)'", controller: self,
        onOk: {() -> Void in
            // Delete the Trip object
            TripManager.RemoveTrip(trip2Delete.id)
            // Reload trips
            self.loadTrips()
            // Delete the row from the data source
            self.tableView.endEditing(true)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        },
        onCancel: {() -> Void in
            self.tableView.isEditing = false
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
    
    fileprivate func refreshAll()
    {
        loadTrips()
        reloadDataTable()
    }
    
    fileprivate var TripScope: Int
    {
        get
        {
            return tripScopeControl.selectedSegmentIndex
        }
    }
    
    fileprivate func loadTrips()
    {
        self.trips = TripManager.GetTrips()
        
        switch self.TripScope
        {
        case TripScope.pending.rawValue: // pending = non archived
            self.trips = self.trips.filter({ (t: Trip) -> Bool in
                return !t.archived
            })
        case TripScope.archived.rawValue: // archived
            self.trips = self.trips.filter({ (t: Trip) -> Bool in
                return t.archived
            })
        default: break // TripScope.All.rawValue
            // Nothing to do...trips is already uinitialized
        }
    }
    
    @IBAction func tripScopeChanged(_ sender: UISegmentedControl)
    {
        refreshAll()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let targetNavController = segue.destination as? UINavigationController

        if (segue.identifier == "DiveList")
        {
            let targetController = targetNavController?.topViewController as? DivesTableViewController
            let selectedTripCell = sender as? TripTableViewCell
            if (selectedTripCell != nil)
            {
                let indexPath = tableView.indexPath(for: selectedTripCell!)!
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
    
    @IBAction func unwindToTripList(_ sender: UIStoryboardSegue)
    {
        let sourceController = sender.source as? NewTripViewController
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
    
    override func InternalProcessFilter(_ searchController: UISearchController)
    {
        filteredTrips.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "location CONTAINS[c] %@ OR desc CONTAINS[c] %@", searchController.searchBar.text!, searchController.searchBar.text!)
        
        let array = (trips as NSArray).filtered(using: searchPredicate)
        
        filteredTrips = array as! [Trip]
    }


}
