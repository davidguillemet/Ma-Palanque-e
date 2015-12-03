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
    
    // divers which have been excluded from the groups
    // -> add to the dive once we save the groups
    var newExcludedDivers: Set<String> = Set<String>()
    
    //var divers: [Diver]!
    var groupId: String!
    
    var group: Group!
    {
        didSet
        {
            //self.divers = DiverManager.GetSortedDivers(group.divers)
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
        tableView.bounces = false
        
        IconHelper.SetButtonIcon(deleteButton, icon: IconValue.IconTrash, fontSize: toolbarButtonFontSize, center: false)
    }
    
    // MARK: UIGestureRecognizerDelegate
    /*func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }*/

    func makeCollectionItemActive(item: UICollectionViewCell)
    {
        item.layer.borderWidth = 3.0
        item.layer.borderColor = UIColor.redColor().CGColor
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
                        
                        Drag.Initialize(
                            cell,
                            parentView: viewController.collectionView!,
                            centerOffset: CGPoint(x: locationInTableView.x - cell.center.x, y: locationInTableView.y - cell.center.y))
                        
                        // update initial path (table row & collection item)
                        Drag.initialCollectionItemIndexPath = collectionItemIndexPath
                        Drag.initialTableRowIndexPath = tableRowIndexPath
                        Drag.targetCollectionItemIndexPath = collectionItemIndexPath
                        Drag.targetTableRowIndexPath = tableRowIndexPath
                    }
                }
            
            case UIGestureRecognizerState.Changed:
                
                if (!Drag.IsInitialized)
                {
                    // Nothing to do if there is no snapshot...
                    break
                }
                
                // Move the snapshot according to the drag
                let locationInCollectionView: CGPoint = longPress.locationInView(viewController.collectionView)
                
                var center: CGPoint = Drag.cellSnapshot!.center
                center.x = locationInCollectionView.x - Drag.offSetWithCenter!.x
                center.y = locationInCollectionView.y - Drag.offSetWithCenter!.y
                Drag.cellSnapshot!.center = center
                
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
                    Drag.HideErrorIndicatorView()
                    
                    // Set the collection item as active
                    makeCollectionItemActive(collectionItem!)
                    
                    if (Drag.targetCollectionItemIndexPath != nil && collectionItemIndexPath != Drag.targetCollectionItemIndexPath)
                    {
                        // the new active collection item is not the same -> clear border
                        let previousTargetCollectionItem: GroupCollectionViewCell = viewController.collectionView!.cellForItemAtIndexPath(Drag.targetCollectionItemIndexPath!) as! GroupCollectionViewCell
                        makeCollectionItemInactive(previousTargetCollectionItem)
                    }
                    
                    // Update the new active collection item
                    Drag.targetCollectionItemIndexPath = collectionItemIndexPath
                    
                    // Get the gesture position relative to tableView in order to get the offset to apply
                    let locationInTableView: CGPoint = longPress.locationInView(collectionItem!.tableView)
                    
                    // Get the possible active table row
                    let tableRowIndexPath = collectionItem!.tableView.indexPathForRowAtPoint(locationInTableView)

                    if (tableRowIndexPath != nil)
                    {
                        let activeTableRow: UITableViewCell = collectionItem!.tableView.cellForRowAtIndexPath(tableRowIndexPath!)!
                        
                        var insertionIndicator: CGPoint = CGPoint()
                        
                        // Check if we are above or bellow the vertical middle of the table row in order to display th einsertion indicator at the bottom or top of the row
                        if (locationInTableView.y < activeTableRow.center.y)
                        {
                            insertionIndicator.y = activeTableRow.frame.origin.y - 1
                            Drag.targetTableRowIndexPath = tableRowIndexPath
                        }
                        else
                        {
                            insertionIndicator.y = activeTableRow.frame.origin.y + activeTableRow.frame.height - 1
                            if (tableRowIndexPath!.row  < collectionItem!.tableView.numberOfRowsInSection(0) - 1)
                            {
                                Drag.targetTableRowIndexPath = NSIndexPath(forRow: tableRowIndexPath!.row + 1, inSection: 0)
                            }
                            else
                            {
                                Drag.targetTableRowIndexPath = nil
                            }
                        }
                        
                        let sameGroup: Bool = (Drag.targetCollectionItemIndexPath == Drag.initialCollectionItemIndexPath)
                        let sameRow: Bool = (Drag.targetTableRowIndexPath?.row == Drag.initialTableRowIndexPath!.row)
                        let nextRow: Bool = (Drag.targetTableRowIndexPath?.row == Drag.initialTableRowIndexPath!.row + 1)
                        
                        if (sameGroup && (sameRow || nextRow))
                        {
                            // The target item is exactly the same as the initial one, or just the next one
                            Drag.HideInsertionIndicatorView()           // Hide insertion indicators
                            Drag.ShowErrorIndicatorView()               // Show Error Indicator
                            Drag.targetTableRowIndexPath = nil          // No table row target
                            Drag.targetCollectionItemIndexPath = nil    // No collection item target
                            makeCollectionItemInactive(collectionItem!) // Make the current collction item inactive
                        }
                        else
                        {
                            insertionIndicator.x = activeTableRow.frame.origin.x
                            
                            Drag.ShowInsertionIndicatorView(
                                viewController.collectionView!.convertPoint(insertionIndicator, fromView: activeTableRow.superview),
                                width: activeTableRow.frame.width)
                        }
                    }
                    else if (collectionItem!.group.diverCount > 0)
                    {
                        // No active target row -> we will insert the diver at the end
                        
                        // -> Make the bottom border of the last row active
                        // Get the last table view row
                        let rowCount = collectionItem!.group.diverCount
                        
                        // Get the last cell
                        let lastTableRow: UITableViewCell = collectionItem!.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: rowCount - 1, inSection: 0))!
                        
                        let insertionIndicatorPos: CGPoint = CGPoint(x: lastTableRow.frame.origin.x, y: lastTableRow.frame.origin.y + lastTableRow.frame.height - 1)
                        
                        Drag.ShowInsertionIndicatorView(
                            viewController.collectionView!.convertPoint(insertionIndicatorPos, fromView: lastTableRow.superview),
                            width: lastTableRow.frame.width)
                        
                        // And then -> No target row
                        Drag.targetTableRowIndexPath = nil
                    }
                    else
                    {
                        // We drag the diver on an empty collection Item
                        // -> No insertion indicator
                        Drag.HideInsertionIndicatorView()
                        // And then -> No target row
                        Drag.targetTableRowIndexPath = nil
                    }
                }
                else // collectionItemIndexPath = nil
                {
                    // Deactivate the possible previous active Colletion Item
                    if (Drag.targetCollectionItemIndexPath != nil)
                    {
                        // the new active collection item is not the same -> clear border
                        let initialCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItemAtIndexPath(Drag.targetCollectionItemIndexPath!) as! GroupCollectionViewCell
                        makeCollectionItemInactive(initialCollectionItem)
                    }
                    
                    // hide possible table insertion view
                    Drag.HideInsertionIndicatorView()
                    
                    // Show error indicator
                    Drag.ShowErrorIndicatorView()
                    
                    Drag.targetCollectionItemIndexPath = nil
                    Drag.targetTableRowIndexPath = nil
                }

                
            default:

                if (!Drag.IsInitialized)
                {
                    // Nothing to do if there is no snapshot...
                    break
                }
                
                var snapshotDestination: CGPoint
                
                if (Drag.targetCollectionItemIndexPath != nil)
                {
                    // Get the target collection cell
                    let targetCell: GroupCollectionViewCell = self.viewController.collectionView?.cellForItemAtIndexPath(Drag.targetCollectionItemIndexPath!) as! GroupCollectionViewCell
                    
                    targetCell.tableView.beginUpdates()
                    
                    var targetRwoIndexPath: NSIndexPath? = Drag.targetTableRowIndexPath
                    var finalTargetIndexPath: NSIndexPath? = targetRwoIndexPath

                    if (Drag.targetCollectionItemIndexPath != Drag.initialCollectionItemIndexPath)
                    {
                        // Move a diver from a group to another one
                        
                        // 1. Remove the diver from the initial group
                        let initialCell: GroupCollectionViewCell = self.viewController.collectionView?.cellForItemAtIndexPath(Drag.initialCollectionItemIndexPath!) as! GroupCollectionViewCell
                        let diverToMove = try! initialCell.group.diverAt(Drag.initialTableRowIndexPath!.row)
                        initialCell.group.removeDiver(diverToMove)
                        initialCell.tableView.beginUpdates()
                        initialCell.tableView.deleteRowsAtIndexPaths([Drag.initialTableRowIndexPath!], withRowAnimation: .Fade)
                        initialCell.tableView.endUpdates()
                        
                        // 1.Bis Remove the Group if the source group is empty...
                        if (initialCell.group.diverCount == 0)
                        {
                            self.viewController.removeCollectionCell(initialCell)
                        }
                        
                        // 2. Insert the diver in the target group
                        // Drag from a group to another group
                        if (targetRwoIndexPath != nil)
                        {
                            // Add the diver in the group
                            targetCell.group.insertDiver(diverToMove, atIndex: Drag.targetTableRowIndexPath!.row)
                        }
                        else
                        {
                            // Add the diver in the group as last diver
                            targetCell.group.addDiver(diverToMove)
                            // Create tne index path to append the new diver
                            targetRwoIndexPath = NSIndexPath(forRow: targetCell.tableView!.numberOfRowsInSection(0), inSection: 0)
                            finalTargetIndexPath = targetRwoIndexPath
                        }
                        
                        // Insert/Append the new table row
                        targetCell.tableView.insertRowsAtIndexPaths([targetRwoIndexPath!], withRowAnimation: .Bottom)
                    }
                    else
                    {
                        // Move a diver inside the same group
                        // -> just move rows inside the same tableview
                        
                        // 1. Move the diver inside the group
                        if (targetRwoIndexPath != nil)
                        {
                            try! targetCell.group.moveDiver(Drag.initialTableRowIndexPath!.row, toIndex: targetRwoIndexPath!.row)
                        }
                        else
                        {
                            // The target row is nil, what means that we will move it at the end
                            targetRwoIndexPath = NSIndexPath(forRow: targetCell.tableView.numberOfRowsInSection(0), inSection: 0)
                            try! targetCell.group.moveDiver(Drag.initialTableRowIndexPath!.row, toIndex: targetRwoIndexPath!.row)
                        }
                        
                        // With tableView.moveRowAtIndexPath, toIndex must be the index of the moved item in the final array
                        // -> if fromIndex < toIndex, then toIndex--
                        // -> if fromIndex > toIndex then nothing
                        finalTargetIndexPath =
                            Drag.initialTableRowIndexPath!.row < targetRwoIndexPath!.row ?
                            NSIndexPath(forRow: targetRwoIndexPath!.row - 1, inSection: 0) :
                            targetRwoIndexPath!
                        
                        // 2. Move the table row
                        targetCell.tableView.moveRowAtIndexPath(Drag.initialTableRowIndexPath!, toIndexPath: finalTargetIndexPath!)
                    }

                    targetCell.tableView.endUpdates()
                    
                    // Get the snapshot target positon using the insertion indicator
                    snapshotDestination = CGPoint(x: Drag.insertionIndicatorView!.center.x, y: Drag.insertionIndicatorView!.frame.origin.y + Drag.cellSnapshot!.frame.size.height / 2)
                    
                    // Invalidate layout in order to update collection cells size
                    self.viewController.collectionView?.collectionViewLayout.invalidateLayout()
                    
                    makeCollectionItemInactive(targetCell)
                }
                else
                {
                    // Do nothing but animate the snapshot to the initial cell
                    // Get the initial Collection item
                    let initialCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItemAtIndexPath(Drag.initialCollectionItemIndexPath!) as! GroupCollectionViewCell
                    // Get the initial table row
                    let initialTableRow: UITableViewCell = initialCollectionItem.tableView!.cellForRowAtIndexPath(Drag.initialTableRowIndexPath!)!
                    
                    snapshotDestination = viewController.collectionView!.convertPoint(initialTableRow.center, fromView: initialCollectionItem.tableView)
                }
                
                Drag.Terminate(snapshotDestination)
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return self.group.locked == false
    }

    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]?
    {
        var actions = [UITableViewRowAction]()
        
        let diver = try! self.group.diverAt(indexPath.row)

        let restAction = UITableViewRowAction(style: .Default, title: "Repos", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            
            self.tableView.beginUpdates()
            
            // Mettre le plongeur au repos
            
            if (self.group.guide == diver)
            {
                // Remove guide if needed
                try! self.group.setGuide(nil)
            }
            
            // Remove the diver from the group
            self.group.removeDiverAt(indexPath.row)
            
            // Set the diver as exclided for the dive
            self.newExcludedDivers.insert(diver)
            
            self.tableView.editing = false
            
            // Remove the ow from the table
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            // Invalidate layout to force redrawing the collection
            self.viewController.collectionView!.collectionViewLayout.invalidateLayout()
            
            self.tableView.endUpdates()
        })
        
        restAction.backgroundColor = ColorHelper.ExcludedDiverColor
        
        actions.append(restAction)
        
        let deleteAction = UITableViewRowAction(style: .Default, title: "Enlever", handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            // Supprimer le plongeur de la palanquée
            self.tableView.beginUpdates()
            
            if (self.group.guide == diver)
            {
                // Remove guide if needed
                try! self.group.setGuide(nil)
            }
            
            // Remove the diver from the group
            self.group.removeDiverAt(indexPath.row)
            
            self.tableView.editing = false
            
            // Remove the ow from the table
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
            
            // Invalidate layout to force redrawing the collection
            self.viewController.collectionView!.collectionViewLayout.invalidateLayout()

            self.tableView.endUpdates()
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
        return self.group.diverCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GroupTableTableViewCell
        
        let diverId = try! self.group.diverAt(indexPath.row)
        let diver = DiverManager.GetDiver(diverId)
        
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

    @IBAction func sendGroupToTrash(sender: AnyObject)
    {
        self.viewController.removeCollectionCell(self)
    }
    @IBAction func changeLock(sender: AnyObject)
    {
        // Switch lock
        if (self.group.locked)
        {
            // TODO : in case parameters are complete (time and depth) we should not be able to unlock the group...
            self.group.locked = false
            self.backgroundColor = ColorHelper.PendingGroup
            // remove trash button
            self.deleteButton.hidden = false
        }
        else
        {
            self.group.locked = true
            self.backgroundColor = ColorHelper.LockedGroup
            self.deleteButton.hidden = true
        }
        SetLockIconState()
    }
    
    func SetLockIconState()
    {
        IconHelper.SetButtonIcon(lockButton, icon: group.locked ? IconValue.IconLocked : IconValue.IconUnlocked, fontSize: toolbarButtonFontSize, center: false)
    }
}
