//
//  GroupCollectionViewCell.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 27/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class GroupCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate
{
    private var cellIdentifier: String = "GroupTableViewCell"
    private let toolbarButtonFontSize: CGFloat = 22.0

    var viewController: DiveGroupsCollectionViewController!
    
    var dive: Dive!
    
    var divers: [Diver]!
    var groupId: String!
    
    var group: Group!
    {
        didSet
        {
            self.divers = DiverManager.GetSortedDivers(group.divers)
            SetLockIconState()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        tableView.delegate = self
        tableView.dataSource = self
        
        let longpress = UILongPressGestureRecognizer(target: self, action: "longPressGestureRecognized:")
        
        longpress.delegate = self
        
        tableView.addGestureRecognizer(longpress)
        
        IconHelper.SetButtonIcon(deleteButton, icon: IconValue.IconTrash, fontSize: toolbarButtonFontSize, center: false)
    }
    
    // MARK: UIGestureRecognizerDelegate
    /*func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }*/

    func makeCollectionItemActive(item: UICollectionViewCell)
    {
        item.layer.borderWidth = 1.0
        item.layer.borderColor = UIColor.blueColor().CGColor
    }
    
    func makeCollectionItemInactive(item: UICollectionViewCell)
    {
        item.layer.borderWidth = 0.0
    }
    
    func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer)
    {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        
        let state = longPress.state
        
        switch state
        {
            case UIGestureRecognizerState.Began:
                
                // Get position relative to the table view and then the selected row index path
                let locationInTableView: CGPoint = longPress.locationInView(tableView)
                let tableRowIndexPath = tableView.indexPathForRowAtPoint(locationInTableView)

                if (tableRowIndexPath != nil)
                {
                    // Get the position relative to the parent view
                    let locationInCollectionView: CGPoint = longPress.locationInView(viewController.collectionView)
                    let collectionItemIndexPath = viewController.collectionView!.indexPathForItemAtPoint(locationInCollectionView)
                    let collectionItem = (viewController.collectionView!.cellForItemAtIndexPath(collectionItemIndexPath!) as! GroupCollectionViewCell)
                
                    if (!collectionItem.group.locked)
                    {
                        // Take a snapshot from the current pressed table cell
                        let cell = tableView.cellForRowAtIndexPath(tableRowIndexPath!) as UITableViewCell!
                        
                        DraggableDiverData.Initialize(
                            cell,
                            parentView: viewController.collectionView!,
                            centerOffset: CGPoint(x: locationInTableView.x - cell.center.x, y: locationInTableView.y - cell.center.y))
                        
                        // update initial path (table row & collection item)
                        DraggableDiverData.initialCollectionItemIndexPath = collectionItemIndexPath
                        DraggableDiverData.initialTableRowIndexPath = tableRowIndexPath
                        DraggableDiverData.targetCollectionItemIndexPath = collectionItemIndexPath
                        DraggableDiverData.targetTableRowIndexPath = tableRowIndexPath
                    }
                }
            case UIGestureRecognizerState.Changed:
                
                if (DraggableDiverData.cellSnapshot == nil)
                {
                    // Nothing to do if there is no snapshot...
                    break
                }
                
                // Move the snapshot according to the drag
                let locationInCollectionView: CGPoint = longPress.locationInView(viewController.collectionView)
                
                var center: CGPoint = DraggableDiverData.cellSnapshot!.center
                center.x = locationInCollectionView.x - DraggableDiverData.offSetWithCenter!.x
                center.y = locationInCollectionView.y - DraggableDiverData.offSetWithCenter!.y
                DraggableDiverData.cellSnapshot!.center = center
                
                // Get the Collection item from the location
                let collectionItemIndexPath = viewController.collectionView!.indexPathForItemAtPoint(locationInCollectionView)
                
                var collectionItem: GroupCollectionViewCell? = nil
                
                if (collectionItemIndexPath != nil)
                {
                    collectionItem = (viewController.collectionView!.cellForItemAtIndexPath(collectionItemIndexPath!) as! GroupCollectionViewCell)
                }
                
                if (collectionItem != nil && !collectionItem!.group.locked)
                {
                    // Hide error indicator
                    DraggableDiverData.HideErrorIndicatorView()
                    
                    // Set the collection item as active
                    makeCollectionItemActive(collectionItem!)
                    
                    if (DraggableDiverData.targetCollectionItemIndexPath != nil && collectionItemIndexPath != DraggableDiverData.targetCollectionItemIndexPath)
                    {
                        // the new active collection item is not the same -> clear border
                        let initialCollectionItem: GroupCollectionViewCell = viewController.collectionView!.cellForItemAtIndexPath(DraggableDiverData.targetCollectionItemIndexPath!) as! GroupCollectionViewCell
                        makeCollectionItemInactive(initialCollectionItem)
                    }
                    
                    // Update the new active collection item
                    DraggableDiverData.targetCollectionItemIndexPath = collectionItemIndexPath
                    
                    // Get the gesture position relative to tableView in order to get the offset to apply
                    let locationInTableView: CGPoint = longPress.locationInView(collectionItem!.tableView)
                    
                    // Get the possible active table row
                    let tableRowIndexPath = collectionItem!.tableView.indexPathForRowAtPoint(locationInTableView)

                    if (tableRowIndexPath != nil)
                    {
                        if (collectionItemIndexPath!.row == DraggableDiverData.targetCollectionItemIndexPath?.row)
                        {
                            // Drag & Drop in the same collection Item table as the previous one
                            if (tableRowIndexPath != DraggableDiverData.targetTableRowIndexPath)
                            {
                                // Switch divers from the same table
                                //collectionItem.divers.insert(collectionItem.divers.removeAtIndex(DraggableDiverData.targetTableRowIndexPath!.row), atIndex: tableRowIndexPath!.row)
                                //collectionItem.tableView.moveRowAtIndexPath(DraggableDiverData.targetTableRowIndexPath!, toIndexPath: tableRowIndexPath!)
                                
                                // Update previous table row index
                                //DraggableDiverData.targetTableRowIndexPath = tableRowIndexPath
                            }
                        }
                        else
                        {
                            // Drag the diver into another collection item (another group)
                            
                            // 1. Get the previous collection item
                            /*et initialCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItemAtIndexPath(DraggableDiverData.targetCollectionItemIndexPath!) as! GroupCollectionViewCell
                            // 2. Remove the diver from the initial group
                            initialCollectionItem.divers.removeAtIndex(DraggableDiverData.targetTableRowIndexPath!.row)
                            // 3. Remove the table row from the initial group 
                            initialCollectionItem.tableView.deleteRowsAtIndexPaths([DraggableDiverData.targetTableRowIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                            
                            // 4. Add the diver to the new collection item / Group
                            let newCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItemAtIndexPath(collectionItemIndexPath!) as! GroupCollectionViewCell
                            newCollectionItem.divers.insert(DraggableDiverData.diver!, atIndex: tableRowIndexPath!.row)
                            // 5. Add the new table Row
                            newCollectionItem.tableView.insertRowsAtIndexPaths([tableRowIndexPath!], withRowAnimation: UITableViewRowAnimation.Fade)
                            // 6. Hide the row
                            let newCell = newCollectionItem.tableView.cellForRowAtIndexPath(tableRowIndexPath!) as UITableViewCell!
                            newCell.hidden = true*/
                            
                            // Update previous table row index
                            //DraggableDiverData.targetTableRowIndexPath = tableRowIndexPath
                        }
                        
                        let activeTableRow: UITableViewCell = collectionItem!.tableView.cellForRowAtIndexPath(tableRowIndexPath!)!
                        
                        var insertionIndicator: CGPoint = CGPoint()
                        
                        // Check if we are above or bellow the vertical middle of the table row in order to display th einsertion indicator at the bottom or top of the row
                        if (locationInTableView.y < activeTableRow.center.y)
                        {
                            insertionIndicator.y = activeTableRow.frame.origin.y - 1
                            DraggableDiverData.targetTableRowIndexPath = tableRowIndexPath
                        }
                        else
                        {
                            insertionIndicator.y = activeTableRow.frame.origin.y + activeTableRow.frame.height - 1
                            DraggableDiverData.targetTableRowIndexPath = NSIndexPath(forRow: tableRowIndexPath!.row + 1, inSection: 0)
                        }

                        if (DraggableDiverData.targetCollectionItemIndexPath == DraggableDiverData.initialCollectionItemIndexPath && abs(DraggableDiverData.targetTableRowIndexPath!.row - DraggableDiverData.initialTableRowIndexPath!.row) <= 1)
                        {
                            // The target item is exactly the same as the initial one, or just the next one
                            DraggableDiverData.HideInsertionIndicatorView()         // Hide insertion indicators
                            DraggableDiverData.ShowErrorIndicatorView()             // Show Error Indicator
                            DraggableDiverData.targetTableRowIndexPath = nil        // No table row target
                            DraggableDiverData.targetCollectionItemIndexPath = nil  // No collection item target
                            makeCollectionItemInactive(collectionItem!)             // Make the current collction item inactive
                        }
                        else
                        {
                            insertionIndicator.x = activeTableRow.frame.origin.x
                            
                            DraggableDiverData.ShowInsertionIndicatorView(
                                viewController.collectionView!.convertPoint(insertionIndicator, fromView: activeTableRow.superview),
                                width: activeTableRow.frame.width)
                        }
                    }
                    else if (collectionItem!.divers.count > 0)
                    {
                        // No active target row -> we will insert the diver at the end
                        // -> Make the bottom border of the last row active
                        // Get the last table view row
                        let rowCount = collectionItem!.divers.count
                        
                        // Get the last cell
                        let lastTableRow: UITableViewCell = collectionItem!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowCount - 1, inSection: 0))!
                        
                        let insertionIndicatorPos: CGPoint = CGPoint(x: lastTableRow.frame.origin.x, y: lastTableRow.frame.origin.y + lastTableRow.frame.height - 1)
                        
                        DraggableDiverData.ShowInsertionIndicatorView(
                            viewController.collectionView!.convertPoint(insertionIndicatorPos, fromView: lastTableRow.superview),
                            width: lastTableRow.frame.width)
                        
                        // And then -> No target row
                        DraggableDiverData.targetTableRowIndexPath = nil
                    }
                    else
                    {
                        // We drag the diver on an empty collection Item
                        // -> No insertion indicator
                        DraggableDiverData.HideInsertionIndicatorView()
                        // And then -> No target row
                        DraggableDiverData.targetTableRowIndexPath = nil
                    }
                }
                else // collectionItemIndexPath = nil
                {
                    // Deactivate the possible previous active Colletion Item
                    if (DraggableDiverData.targetCollectionItemIndexPath != nil)
                    {
                        // the new active collection item is not the same -> clear border
                        let initialCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItemAtIndexPath(DraggableDiverData.targetCollectionItemIndexPath!) as! GroupCollectionViewCell
                        makeCollectionItemInactive(initialCollectionItem)
                    }
                    
                    // hide possible table insertion view
                    DraggableDiverData.HideInsertionIndicatorView()
                    
                    // Show error indicator
                    DraggableDiverData.ShowErrorIndicatorView()
                    
                    DraggableDiverData.targetCollectionItemIndexPath = nil
                    DraggableDiverData.targetTableRowIndexPath = nil
                }
                
            default:

                if (DraggableDiverData.cellSnapshot == nil)
                {
                    // Nothing to do if there is no snapshot...
                    break
                }
                
                var snapshotDestination: CGPoint
                
                if (DraggableDiverData.targetCollectionItemIndexPath != nil)
                {
                    // Get the target Collection item from the location
                    let targetCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItemAtIndexPath(DraggableDiverData.targetCollectionItemIndexPath!) as! GroupCollectionViewCell
                    
                    makeCollectionItemInactive(targetCollectionItem)
                    
                    // Get the initial table cell
                    if (DraggableDiverData.targetTableRowIndexPath != nil)
                    {
                        // Insert the
                        let targetTableRow = targetCollectionItem.tableView.cellForRowAtIndexPath(DraggableDiverData.targetTableRowIndexPath!) as UITableViewCell!
                        
                        snapshotDestination = viewController.collectionView!.convertPoint(targetTableRow.center, fromView: targetTableRow.superview)
                    }
                    else
                    {
                        // No target cell...only the collection item
                        // Just animate the snapshot to the same position
                        snapshotDestination = DraggableDiverData.cellSnapshot!.center
                    }
                }
                else
                {
                    // Do nothing but animate the snapshot to the initial cell
                    // Get the initial Collection item
                    let initialCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItemAtIndexPath(DraggableDiverData.initialCollectionItemIndexPath!) as! GroupCollectionViewCell
                    // Get the initial table row
                    let initialTableRow: UITableViewCell = initialCollectionItem.tableView!.cellForRowAtIndexPath(DraggableDiverData.initialTableRowIndexPath!)!
                    
                    snapshotDestination = viewController.collectionView!.convertPoint(initialTableRow.center, fromView: initialCollectionItem.tableView)
                }
                
                DraggableDiverData.Terminate(snapshotDestination)
        }
    
    }
    
    func diverLabel(diver: Diver) -> String
    {
        return "\(diver.firstName) \(diver.lastName)"
    }
    
    // MARK: UITableViewDataSource

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
    {
        // Override to support editing the table view.
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        var actions = [UITableViewRowAction]()
        
        let restAction = UITableViewRowAction(style: .Default, title: "Repos", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // Mettre le plongeur au repos
            //var diver = self.getDiver(indexPath)
            // TODO
            self.tableView.editing = false
        })
        
        restAction.backgroundColor = ColorHelper.ExcludedDiverColor
        
        actions.append(restAction)
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Enlever", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.tableView.editing = false
        })
        
        deleteAction.backgroundColor = ColorHelper.DeleteColor
        
        actions.append(deleteAction)
        
        return actions
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.divers.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GroupTableTableViewCell
        
        let diver = self.divers[indexPath.row]
        
        cell.group = self.group
        cell.diverId = diver.id
        cell.collectionItem = self
        
        cell.diverLabel.text = diverLabel(diver)
        
        cell.diverLevel.adjustsFontSizeToFitWidth = true
        cell.diverLevel.text = diver.level.stringValue
        
        let colors = PreferencesHelper.GetDiveLevelColors(diver.level)
        cell.diverLevel.backgroundColor = colors.color
        cell.diverLevel.textColor = colors.reversedColor
        cell.diverLevel.layer.cornerRadius = cell.diverLevel.layer.frame.width / 2
        cell.diverLevel.clipsToBounds = true
        
        IconHelper.SetButtonIcon(cell.guideButton, icon: IconValue.IconRibbon, fontSize: 18, center: true)
        cell.guideButton.layer.cornerRadius = 15
        cell.guideButton.layer.borderWidth = 1.0
        cell.guideButton.clipsToBounds = true
        if (self.group.guide != nil && self.group.guide == diver.id)
        {
            cell.guideButton.setTitleColor(ColorHelper.GuideIcon, forState: .Normal)
            cell.guideButton.backgroundColor = ColorHelper.GuideIconBackground
            cell.guideButton.layer.borderColor = ColorHelper.GuideIcon.CGColor
        }
        else if (diver.level.rawValue >= DiveLevel.N4.rawValue)
        {
            cell.guideButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
            cell.guideButton.backgroundColor = UIColor.whiteColor()
            cell.guideButton.layer.borderColor = UIColor.lightGrayColor().CGColor
        }
        else
        {
            cell.guideButton.hidden = true
        }
        
        return cell
    }

    @IBAction func changeLock(sender: AnyObject)
    {
        // Switch lock
        if (self.group.locked)
        {
            // TODO : in case parameters are complete (time and depth) we should not be able to unlock the group...
            self.group.locked = false
            self.backgroundColor = ColorHelper.PendingGroup
        }
        else
        {
            self.group.locked = true
            self.backgroundColor = ColorHelper.LockedGroup
        }
        SetLockIconState()
    }
    
    func SetLockIconState()
    {
        IconHelper.SetButtonIcon(lockButton, icon: group.locked ? IconValue.IconLocked : IconValue.IconUnlocked, fontSize: toolbarButtonFontSize, center: false)
    }
}
