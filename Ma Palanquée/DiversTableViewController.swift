//
//  DiversTableViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 11/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class DiversTableViewController: SearchableTableViewController {

    var selectionType: String!
    
    var initialDivers: [Diver]?
    var dive: Dive?
    var trip: Trip?
    
    private var divers: [Diver]!
    private var filteredDivers: [Diver] = [Diver]()
    private var diverSections: [String: [Diver]]!
    private var orderedSections: [String]!
    
    // Selected divers
    var selection: Set<String> = Set<String>()
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBOutlet weak var diverScope: UISegmentedControl!
    
    override func viewDidLoad() {
        
        // Initial display = all divers if the selection is empty
        GetDiversFromScope(selection.count == 0, loading: true)
        
        updateSelection()
        
        super.viewDidLoad()
        
        TableViewHelper.ConfigureTable(tableView: self.tableView)
        
        // Reload the table
        self.tableView.reloadData()
        
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

    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return DisplaySearchResult() ? 1 : orderedSections.count
    }
        
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return DisplaySearchResult() ? self.filteredDivers.count : self.diverSections[self.orderedSections[section]]!.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return DisplaySearchResult() ? "" : self.orderedSections[section]
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let headerView = view as! UITableViewHeaderFooterView
        headerView.contentView.backgroundColor = UIColor(red: 0.8863, green: 1, blue: 0.898, alpha: 1.0)
        //headerView.textLabel?.textAlignment = .center
    }
    
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]?
    {
        return self.orderedSections as [String]?
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return self.orderedSections.index(of: title)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cellIdentifier = "DiverTableViewCell"
        var diver: Diver!
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DiverTableViewCell
        
        var divers: [Diver]!
        
        if (DisplaySearchResult())
        {
            divers = self.filteredDivers
        }
        else
        {
            divers = self.diverSections[self.orderedSections[indexPath.section]]
        }
        
        diver = divers[indexPath.row]
        
        cell.firstNameLabel.attributedText = UIHelper.GetDiverNameAttributedString(forDiver: diver)
        
        IconHelper.WriteDiveLevel(cell.levelLabel, diver.level)
        cell.id = diver.id
        
        cell.viewcontroller = self
        
        // In case a trip is specified it means we are selecting divers for the trip
        // then we can disable the switch in case the diver is already part of a dive
        // In case no trip is specified, we just select divers which are not diving for a new dive
        if ((self.selectionType == "TripDivers" && self.trip != nil && !self.trip!.canRemoveDiver(diver.id)) ||
            (self.selectionType == "DiveExcludedDivers" && self.dive != nil && self.dive!.diverIsInGroup(diver.id)))
        {
            cell.selectionSwitch.isEnabled = false // cannot remove a diver which is already part of a group...or cannot exclude dive director
            cell.backgroundColor =  UIColor ( red: 0.90, green: 0.90, blue: 0.90, alpha: 1.0 )

        }
        else
        {
            cell.selectionSwitch.isEnabled = true
            cell.backgroundColor = UIColor.white
        }
        
        if (selection.contains(diver.id))
        {
            cell.selectionSwitch.setOn(true, animated: false)
        }
        else
        {
            cell.selectionSwitch.setOn(false, animated: false)
        }

        return cell
    }
    
    func selectDiver(_ cell: DiverTableViewCell, selected: Bool)
    {
        if (selected)
        {
            selection.insert(cell.id)
        }
        else
        {
            selection.remove(cell.id)
        }
        updateSelection()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        let diverCell: DiverTableViewCell = cell as! DiverTableViewCell
        if (selection.contains(diverCell.id))
        {
            diverCell.selectionSwitch.setOn(true, animated: false)
        }
        else
        {
            diverCell.selectionSwitch.setOn(false, animated: false)
        }
    }
        
    func getDiver(_ indexPath: IndexPath) -> Diver
    {
        if (DisplaySearchResult())
        {
            return self.filteredDivers[indexPath.row]
        }
        else
        {
            return self.divers![indexPath.row]
        }
    }
    
    func updateSelection()
    {
        if (self.selectionType == "DiveExcludedDivers")
        {
            self.diverScope.setTitle("Repos (\(selection.count))", forSegmentAt: 1)
        }
        else
        {
            self.diverScope.setTitle("Sélection (\(selection.count))", forSegmentAt: 1)
        }
    }
    
    func GetDiversFromScope(_ all: Bool, loading: Bool)
    {
        var divers = initialDivers ?? DiverManager.GetDivers()
        
        // If selection is not empty, only display selected divers
        if (!all && (selection.count > 0 || !loading))
        {
            divers = divers.filter({ (diver: Diver) -> Bool in
                return selection.contains(diver.id)
            })
            
            if (loading)
            {
                diverScope.selectedSegmentIndex = 1
            }
        }
        
        // Sort in alphabetical order
        self.divers = divers.sorted(by: { (d1: Diver, d2: Diver) -> Bool in
            return d1.lastName < d2.lastName
        })
        
        // Prepare sections
        self.diverSections = [String: [Diver]]()
        self.orderedSections = [String]()
        
        for diver: Diver in self.divers
        {
            let lastNameFirstLetter = String(describing: diver.lastName.characters.first!)
            var section = self.diverSections[lastNameFirstLetter]
            if section == nil
            {
                section = [Diver]()
                self.diverSections[lastNameFirstLetter] = section
                self.orderedSections.append(lastNameFirstLetter)
            }
            
            self.diverSections[lastNameFirstLetter]!.append(diver)
        }
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
    
    // MARK: Actions
    
    @IBAction func diverScopeChanged(_ sender: UISegmentedControl)
    {
        if (sender.selectedSegmentIndex == 0)
        {
            GetDiversFromScope(true, loading: false)
        }
        else
        {
            GetDiversFromScope(false, loading: false)
        }
        
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation
    @IBAction func doneAction(_ sender: AnyObject)
    {
        if (self.selectionType == "TripDivers")
        {
            // Back To New Trip
            self.performSegue(withIdentifier: "TripSelectedDivers", sender: self)
        }
        else
        {
            // Back To New Dive
            self.performSegue(withIdentifier: "DiveExcludedDivers", sender: self)
        }
    }
    @IBAction func cancel(_ sender: AnyObject)
    {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveSelection(_ sender: UIBarButtonItem) {
    }
    override func shouldPerformSegue(withIdentifier identifier: String,sender: Any?) -> Bool
    {
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    // MARK: Search
    
    override func InternalProcessFilter(_ searchController: UISearchController)
    {
        filteredDivers.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "firstName CONTAINS[c] %@ OR lastName CONTAINS[c] %@", searchController.searchBar.text!, searchController.searchBar.text!)
        
        let array = (divers as NSArray).filtered(using: searchPredicate)
        
        filteredDivers = array as! [Diver]
    }
}
