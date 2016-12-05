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
    fileprivate var cellIdentifier: String = "GroupTableViewCell"
    fileprivate let toolbarButtonFontSize: CGFloat = 22.0

    var viewController: DiveGroupsCollectionViewController!
    
    var dive: Dive!
    
    var group: Group!
    {
        didSet
        {
            if (self.group.locked)
            {
                self.deleteButton.isHidden = true
            }
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
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(GroupCollectionViewCell.longPressGestureRecognized(_:)))
        
        longpress.delegate = self
        
        tableView.addGestureRecognizer(longpress)
        tableView.bounces = false
        
        IconHelper.SetButtonIcon(deleteButton, icon: IconValue.IconTrash, fontSize: toolbarButtonFontSize, center: false)
    }
    
    // MARK: UIGestureRecognizerDelegate

    func makeCollectionItemActive(_ item: UICollectionViewCell)
    {
        item.layer.borderWidth = 3.0
        item.layer.borderColor = UIColor.red.cgColor
    }
    
    func makeCollectionItemInactive(_ item: UICollectionViewCell)
    {
        item.layer.borderWidth = 0.0
    }
    
    func longPressGestureRecognized(_ gestureRecognizer: UIGestureRecognizer)
    {
        let longPress = gestureRecognizer as! UILongPressGestureRecognizer
        
        let state = longPress.state
        
        switch state
        {
            case UIGestureRecognizerState.began:
                
                // Get position relative to the table view and then the selected row index path
                let locationInTableView: CGPoint = longPress.location(in: tableView)
                let tableRowIndexPath = tableView.indexPathForRow(at: locationInTableView)

                if (tableRowIndexPath != nil)
                {
                    // Get the position relative to the parent view
                    let locationInCollectionView: CGPoint = longPress.location(in: viewController.collectionView)
                    let collectionItemIndexPath = viewController.collectionView!.indexPathForItem(at: locationInCollectionView)
                    let collectionItem = (viewController.collectionView!.cellForItem(at: collectionItemIndexPath!) as! GroupCollectionViewCell)
                
                    if (!collectionItem.group.locked)
                    {
                        // Take a snapshot from the current pressed table cell
                        let cell = tableView.cellForRow(at: tableRowIndexPath!) as UITableViewCell?
                        
                        if (cell != nil)
                        {
                            Drag.Initialize(
                                cell!,
                                parentView: viewController.collectionView!,
                                centerOffset: CGPoint(x: locationInTableView.x - cell!.center.x, y: locationInTableView.y - cell!.center.y))
                        
                            // update initial path (table row & collection item)
                            Drag.initialCollectionItemIndexPath = collectionItemIndexPath
                            Drag.initialTableRowIndexPath = tableRowIndexPath
                            Drag.targetCollectionItemIndexPath = collectionItemIndexPath
                            Drag.targetTableRowIndexPath = tableRowIndexPath
                        }
                    }
                }
            
            case UIGestureRecognizerState.changed:
                
                if (!Drag.IsInitialized)
                {
                    // Nothing to do if there is no snapshot...
                    break
                }
                
                // Move the snapshot according to the drag
                let locationInCollectionView: CGPoint = longPress.location(in: viewController.collectionView)
                
                var center: CGPoint = Drag.cellSnapshot!.center
                center.x = locationInCollectionView.x - Drag.offSetWithCenter!.x
                center.y = locationInCollectionView.y - Drag.offSetWithCenter!.y
                Drag.cellSnapshot!.center = center
                
                // Get the Collection item from the location
                let collectionItemIndexPath = viewController.collectionView!.indexPathForItem(at: locationInCollectionView)
                
                var collectionItem: GroupCollectionViewCell? = nil
                
                if (collectionItemIndexPath != nil)
                {
                    collectionItem = (viewController.collectionView!.cellForItem(at: collectionItemIndexPath!) as! GroupCollectionViewCell)
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
                        let previousTargetCollectionItem: GroupCollectionViewCell = viewController.collectionView!.cellForItem(at: Drag.targetCollectionItemIndexPath!) as! GroupCollectionViewCell
                        makeCollectionItemInactive(previousTargetCollectionItem)
                    }
                    
                    // Update the new active collection item
                    Drag.targetCollectionItemIndexPath = collectionItemIndexPath
                    
                    // Get the gesture position relative to tableView in order to get the offset to apply
                    let locationInTableView: CGPoint = longPress.location(in: collectionItem!.tableView)
                    
                    // Get the possible active table row
                    let tableRowIndexPath = collectionItem!.tableView.indexPathForRow(at: locationInTableView)

                    if (tableRowIndexPath != nil)
                    {
                        let activeTableRow: UITableViewCell = collectionItem!.tableView.cellForRow(at: tableRowIndexPath!)!
                        
                        var insertionIndicator: CGPoint = CGPoint()
                        
                        // Check if we are above or bellow the vertical middle of the table row in order to display th einsertion indicator at the bottom or top of the row
                        if (locationInTableView.y < activeTableRow.center.y)
                        {
                            insertionIndicator.y = activeTableRow.frame.origin.y - 2
                            Drag.targetTableRowIndexPath = tableRowIndexPath
                        }
                        else
                        {
                            insertionIndicator.y = activeTableRow.frame.origin.y + activeTableRow.frame.height - 2
                            if (tableRowIndexPath!.row  < collectionItem!.tableView.numberOfRows(inSection: 0) - 1)
                            {
                                Drag.targetTableRowIndexPath = IndexPath(row: tableRowIndexPath!.row + 1, section: 0)
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
                                viewController.collectionView!.convert(insertionIndicator, from: activeTableRow.superview),
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
                        let lastTableRow: UITableViewCell = collectionItem!.tableView.cellForRow(at: IndexPath(row: rowCount - 1, section: 0))!
                        
                        let insertionIndicatorPos: CGPoint = CGPoint(x: lastTableRow.frame.origin.x, y: lastTableRow.frame.origin.y + lastTableRow.frame.height - 2)
                        
                        Drag.ShowInsertionIndicatorView(
                            viewController.collectionView!.convert(insertionIndicatorPos, from: lastTableRow.superview),
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
                        let initialCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItem(at: Drag.targetCollectionItemIndexPath!) as! GroupCollectionViewCell
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
                    let targetCell: GroupCollectionViewCell = self.viewController.collectionView?.cellForItem(at: Drag.targetCollectionItemIndexPath!) as! GroupCollectionViewCell
                    
                    targetCell.tableView.beginUpdates()
                    
                    var targetRwoIndexPath: IndexPath? = Drag.targetTableRowIndexPath
                    var finalTargetIndexPath: IndexPath? = targetRwoIndexPath

                    if (Drag.targetCollectionItemIndexPath != Drag.initialCollectionItemIndexPath)
                    {
                        // Move a diver from a group to another one
                        
                        // 1. Remove the diver from the initial group
                        let initialCell: GroupCollectionViewCell = self.viewController.collectionView?.cellForItem(at: Drag.initialCollectionItemIndexPath!) as! GroupCollectionViewCell
                        let diverToMove = try! initialCell.group.diverAt(Drag.initialTableRowIndexPath!.row)
                        initialCell.group.removeDiver(diverToMove)
                        initialCell.tableView.beginUpdates()
                        initialCell.tableView.deleteRows(at: [Drag.initialTableRowIndexPath!], with: .fade)
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
                            targetRwoIndexPath = IndexPath(row: targetCell.tableView!.numberOfRows(inSection: 0), section: 0)
                            finalTargetIndexPath = targetRwoIndexPath
                        }
                        
                        // Insert/Append the new table row
                        targetCell.tableView.insertRows(at: [targetRwoIndexPath!], with: .bottom)
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
                            targetRwoIndexPath = IndexPath(row: targetCell.tableView.numberOfRows(inSection: 0), section: 0)
                            try! targetCell.group.moveDiver(Drag.initialTableRowIndexPath!.row, toIndex: targetRwoIndexPath!.row)
                        }
                        
                        // With tableView.moveRowAtIndexPath, toIndex must be the index of the moved item in the final array
                        // -> if fromIndex < toIndex, then toIndex--
                        // -> if fromIndex > toIndex then nothing
                        finalTargetIndexPath =
                            Drag.initialTableRowIndexPath!.row < targetRwoIndexPath!.row ?
                            IndexPath(row: targetRwoIndexPath!.row - 1, section: 0) :
                            targetRwoIndexPath!
                        
                        // 2. Move the table row
                        targetCell.tableView.moveRow(at: Drag.initialTableRowIndexPath!, to: finalTargetIndexPath!)
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
                    let initialCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItem(at: Drag.initialCollectionItemIndexPath!) as! GroupCollectionViewCell
                    // Get the initial table row
                    let initialTableRow: UITableViewCell = initialCollectionItem.tableView!.cellForRow(at: Drag.initialTableRowIndexPath!)!
                    
                    snapshotDestination = viewController.collectionView!.convert(initialTableRow.center, from: initialCollectionItem.tableView)
                }
                
                Drag.Terminate(snapshotDestination)
        }
    
    }
    
    func diverLabel(_ diver: Diver) -> String
    {
        return "\(diver.firstName) \(diver.lastName)"
    }
    
    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        // Override to support editing the table view.
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return self.group.locked == false
    }

    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        var actions = [UITableViewRowAction]()
        
        let diver = try! self.group.diverAt(indexPath.row)

        let restAction = UITableViewRowAction(style: .default, title: "Repos", handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            
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
            self.viewController.addNewExcludedDiver(diver)
            
            self.tableView.isEditing = false
            
            // Remove the ow from the table
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            // Invalidate layout to force redrawing the collection
            self.viewController.collectionView!.collectionViewLayout.invalidateLayout()
            
            self.tableView.endUpdates()
        })
        
        restAction.backgroundColor = ColorHelper.ExcludedDiverColor
        
        actions.append(restAction)
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Enlever", handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            // Supprimer le plongeur de la palanquée
            self.tableView.beginUpdates()
            
            if (self.group.guide == diver)
            {
                // Remove guide if needed
                try! self.group.setGuide(nil)
            }
            
            // Remove the diver from the group
            self.group.removeDiverAt(indexPath.row)
            
            self.tableView.isEditing = false
            
            // Remove the ow from the table
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            // Invalidate layout to force redrawing the collection
            self.viewController.collectionView!.collectionViewLayout.invalidateLayout()

            self.tableView.endUpdates()
        })
        
        deleteAction.backgroundColor = ColorHelper.DeleteColor
        
        actions.append(deleteAction)
        
        return actions
    }

    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.group.diverCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroupTableTableViewCell
        
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
            cell.guideButton.setTitleColor(ColorHelper.GuideIcon, for: UIControlState())
            cell.guideButton.backgroundColor = ColorHelper.GuideIconBackground
            cell.guideButton.layer.borderColor = ColorHelper.GuideIcon.cgColor
        }
        else if (diver.level.rawValue >= DiveLevel.n4.rawValue)
        {
            cell.guideButton.setTitleColor(UIColor.gray, for: UIControlState())
            cell.guideButton.backgroundColor = UIColor.white
            cell.guideButton.layer.borderColor = UIColor.lightGray.cgColor
        }
        else
        {
            cell.guideButton.isHidden = true
        }
        
        return cell
    }

    @IBAction func sendGroupToTrash(_ sender: AnyObject)
    {
        self.viewController.removeCollectionCell(self)
    }
    @IBAction func changeLock(_ sender: AnyObject)
    {
        // Switch lock
        if (self.group.locked)
        {
            // TODO : in case parameters are complete (time and depth) we should not be able to unlock the group...
            self.group.locked = false
            self.backgroundColor = ColorHelper.PendingGroup
            // remove trash button
            self.deleteButton.isHidden = false
        }
        else
        {
            self.group.locked = true
            self.backgroundColor = ColorHelper.LockedGroup
            self.deleteButton.isHidden = true
        }
        SetLockIconState()
    }
    
    func SetLockIconState()
    {
        IconHelper.SetButtonIcon(lockButton, icon: group.locked ? IconValue.IconLocked : IconValue.IconUnlocked, fontSize: toolbarButtonFontSize, center: false)
    }
}
