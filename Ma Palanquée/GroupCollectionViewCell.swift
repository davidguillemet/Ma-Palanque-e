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
    private let cellIdentifier: String = "GroupTableViewCell"
    private let toolbarButtonFontSize: CGFloat = 22.0
    
    // Distance entre la position courante du Drag et le top/botttom qui va déclencher un scoll auto
    private let scrollThreshold: CGFloat = 20.0
    // Valeur du scroll automatique lors du Drag
    private let autoScrollOffset: CGFloat = 10
    private let animateAutoScroll: Bool = false
    
    private var scrollTimer: Timer?

    var viewController: DiveGroupsCollectionViewController!
    
    var dive: Dive?
    
    var group: Group?
    {
        didSet
        {
            if self.group != nil && self.group!.locked
            {
                updateButtonsVisibility(visible: false)
            }
            SetLockIconState()

            tableView.tableFooterView = UIView(frame: CGRect.zero)
            tableView.backgroundColor = UIColor(red: 0.949, green: 1, blue: 0.9961, alpha: 1.0)
            
            self.backgroundColor = group?.locked == true ? ColorHelper.LockedGroup : ColorHelper.PendingGroup
            
            tableView.reloadData()
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var addDiverButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        tableView.delegate = self
        tableView.dataSource = self
        
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(GroupCollectionViewCell.longPressGestureRecognized(_:)))
        
        longpress.delegate = self
        
        tableView.addGestureRecognizer(longpress)
        tableView.bounces = false
        tableView.layer.cornerRadius = 4
        
        IconHelper.SetButtonIcon(deleteButton, icon: Icon.Trash, fontSize: toolbarButtonFontSize, center: false)
        IconHelper.SetButtonIcon(addDiverButton, icon: Icon.AddUser, fontSize: toolbarButtonFontSize, center: false)
        IconHelper.SetButtonIcon(settingsButton, icon: Icon.Settings, fontSize: toolbarButtonFontSize, center: false)
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
        
        if self.scrollTimer != nil && self.scrollTimer!.isValid
        {
            self.scrollTimer!.invalidate()
        }
        
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
                
                    if (!collectionItem.group!.locked)
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
                
                updateDragInfo(fromGesture: longPress, timer: nil)
                
            case UIGestureRecognizerState.ended:

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
                    
                    var targetRwoIndexPath: IndexPath? = Drag.targetTableRowIndexPath
                    var finalTargetIndexPath: IndexPath? = targetRwoIndexPath

                    if (Drag.targetCollectionItemIndexPath != Drag.initialCollectionItemIndexPath)
                    {
                        // Move a diver from a group to another one
                        self.viewController.moveDiver(
                            at: Drag.initialTableRowIndexPath!,
                            fromGroupAt: Drag.initialCollectionItemIndexPath!,
                            toGroupAt: Drag.targetCollectionItemIndexPath!,
                            at: targetRwoIndexPath)
                    }
                    else
                    {
                        targetCell.tableView.beginUpdates()
                        
                        // Move a diver inside the same group
                        // -> just move rows inside the same tableview
                        
                        // 1. Move the diver inside the group
                        if (targetRwoIndexPath != nil)
                        {
                            try! targetCell.group!.moveDiver(Drag.initialTableRowIndexPath!.row, toIndex: targetRwoIndexPath!.row)
                        }
                        else
                        {
                            // The target row is nil, what means that we will move it at the end
                            targetRwoIndexPath = IndexPath(row: targetCell.tableView.numberOfRows(inSection: 0), section: 0)
                            try! targetCell.group!.moveDiver(Drag.initialTableRowIndexPath!.row, toIndex: targetRwoIndexPath!.row)
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

                        targetCell.tableView.endUpdates()
                    }
                    
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
                    // -> it might happen iti snot available anymore due to scrolling
                    if let initialCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItem(at: Drag.initialCollectionItemIndexPath!) as?GroupCollectionViewCell
                    {
                        // Get the initial table row
                        let initialTableRow: UITableViewCell = initialCollectionItem.tableView!.cellForRow(at: Drag.initialTableRowIndexPath!)!
                    
                        snapshotDestination = viewController.collectionView!.convert(initialTableRow.center, from: initialCollectionItem.tableView)
                    }
                    else
                    {
                        // the snapshot destination is the current location
                        let locationInCollectionView: CGPoint = longPress.location(in: viewController.collectionView)
                        let yPositionOnScreen: CGFloat = locationInCollectionView.y - self.viewController.collectionView!.contentOffset.y
                        snapshotDestination = CGPoint(x: locationInCollectionView.x, y: yPositionOnScreen)
                    }
                }
                
                Drag.Terminate(snapshotDestination)
            
            default:

                var snapshotDestination: CGPoint

                // Do nothing but animate the snapshot to the initial cell
                // Get the initial Collection item
                // -> it might happen iti snot available anymore due to scrolling
                if let initialCollectionItem: GroupCollectionViewCell = viewController.collectionView?.cellForItem(at: Drag.initialCollectionItemIndexPath!) as?GroupCollectionViewCell
                {
                    // Get the initial table row
                    let initialTableRow: UITableViewCell = initialCollectionItem.tableView!.cellForRow(at: Drag.initialTableRowIndexPath!)!
                    
                    snapshotDestination = viewController.collectionView!.convert(initialTableRow.center, from: initialCollectionItem.tableView)
                }
                else
                {
                    // the snapshot destination is the current location
                    let locationInCollectionView: CGPoint = longPress.location(in: viewController.collectionView)
                    let yPositionOnScreen: CGFloat = locationInCollectionView.y - self.viewController.collectionView!.contentOffset.y
                    snapshotDestination = CGPoint(x: locationInCollectionView.x, y: yPositionOnScreen)
                }
                
                Drag.Terminate(snapshotDestination)
        }
    
    }
    
    func timerCallBack(timer: Timer)
    {
        let longPress: UILongPressGestureRecognizer = timer.userInfo as! UILongPressGestureRecognizer
        updateDragInfo(fromGesture: longPress, timer: timer)
    }
    
    func updateDragInfo(fromGesture longPress: UILongPressGestureRecognizer, timer: Timer?)
    {
        if (!Drag.IsInitialized)
        {
            // Nothing to do if there is no snapshot...
            return
        }
        
        // Manage Auto scroll
        // -> Get screen height
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        let insetTop: CGFloat = self.viewController.collectionView!.contentInset.top
        let insetBottom: CGFloat = self.viewController.collectionView!.contentInset.bottom
        
        // Move the snapshot according to the drag
        var locationInCollectionView: CGPoint = longPress.location(in: viewController.collectionView)
        var yPositionOnScreen: CGFloat = locationInCollectionView.y - self.viewController.collectionView!.contentOffset.y
        
        var scrollOffset: CGPoint?
        
        if yPositionOnScreen < self.scrollThreshold + insetTop
        {
            // Scroll up according to autoScrollOffset
            // -> only if not already on the top
            if self.viewController.collectionView!.contentOffset.y > (-insetTop)
            {
                var newContentOffsetY: CGFloat = self.viewController.collectionView!.contentOffset.y - self.autoScrollOffset
                if newContentOffsetY < (-insetTop)
                {
                    newContentOffsetY = -insetTop
                }
                scrollOffset = CGPoint(x: CGFloat(0), y: newContentOffsetY)
            }
        }
        else if yPositionOnScreen > screenHeight - insetBottom - self.scrollThreshold
        {
            // Scroll down according to autoScrollOffset
            // -> only if not already on the bottom
            let maxContentOffsetY: CGFloat = self.viewController.collectionView!.contentSize.height + insetBottom - self.viewController.collectionView!.frame.size.height
            if self.viewController.collectionView!.contentOffset.y < maxContentOffsetY
            {
                var newContentOffsetY: CGFloat = self.viewController.collectionView!.contentOffset.y + self.autoScrollOffset
                if newContentOffsetY > maxContentOffsetY
                {
                    newContentOffsetY = maxContentOffsetY
                }
                scrollOffset = CGPoint(x: CGFloat(0), y: newContentOffsetY)
            }
        }
        
        if scrollOffset != nil
        {
            self.viewController.collectionView?.setContentOffset(scrollOffset!, animated: self.animateAutoScroll)
        }
        
        // Update the gesture position after scrolling
        locationInCollectionView = longPress.location(in: viewController.collectionView)
        yPositionOnScreen = locationInCollectionView.y - self.viewController.collectionView!.contentOffset.y
        
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
        
        if (collectionItem != nil && !collectionItem!.group!.locked)
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
            else if (collectionItem!.group!.diverCount > 0)
            {
                // No active target row -> we will insert the diver at the end
                
                // -> Make the bottom border of the last row active
                // Get the last table view row
                let rowCount = collectionItem!.group!.diverCount
                
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
        
        if timer == nil && scrollOffset != nil
        {
            self.scrollTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timerCallBack), userInfo: longPress, repeats: true)
        }
        
        if timer != nil && scrollOffset == nil
        {
            // invalidate timer
            timer!.invalidate()
        }
        
    }
    
    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath)
    {
        // Override to support editing the table view.
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        return self.group?.locked == false
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        var actions = [UITableViewRowAction]()
        
        let diver: String = try! self.group!.diverAt(indexPath.row)

        let restAction = UITableViewRowAction(style: .default, title: "Repos", handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            // Mettre le plongeur au repos
            self.viewController.addNewExcludedDiver(diver)
            self.removediverFromGroup(diver, indexPath: indexPath)
        })
        
        restAction.backgroundColor = ColorHelper.ExcludedDiverColor
        
        actions.append(restAction)
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Enlever", handler: { (action:UITableViewRowAction!, indexPath:IndexPath!) -> Void in
            // Supprimer le plongeur de la palanquée
            self.removediverFromGroup(diver, indexPath: indexPath)
        })
        
        deleteAction.backgroundColor = ColorHelper.DeleteColor
        
        actions.append(deleteAction)
        
        return actions
    }

    func removediverFromGroup(_ diver: String, indexPath: IndexPath)
    {
        if self.group?.diverCount == 1
        {
            // Remove the group
            self.viewController.removeCollectionCell(self)
        }
        else
        {
            self.tableView.beginUpdates()
            
            if (self.group?.guide == diver)
            {
                // Remove guide if needed
                try! self.group?.setGuide(nil)
            }
            
            // Remove the diver from the group
            self.group?.removeDiverAt(indexPath.row)
            
            self.tableView.isEditing = false
            
            // Remove the ow from the table
            self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            
            // Invalidate layout to force redrawing the collection
            self.viewController.collectionView!.collectionViewLayout.invalidateLayout()
            
            self.tableView.endUpdates()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.group == nil ? 0 : self.group!.diverCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! GroupTableTableViewCell
        
        let diverId = try! self.group!.diverAt(indexPath.row)
        
        cell.diverId = diverId
        cell.group = self.group
        cell.collectionItem = self
        
        return cell
    }
    
    @IBAction func addDiverToGroup(_ sender: Any)
    {
        self.viewController.addDivers(toGroup: self)
    }
        
    @IBAction func sendGroupToTrash(_ sender: AnyObject)
    {
        self.viewController.removeCollectionCell(self)
    }
    @IBAction func changeLock(_ sender: AnyObject)
    {
        // Switch lock
        if self.group?.locked == true
        {
            // TODO : in case parameters are complete (time and depth) we should not be able to unlock the group...
            self.group?.locked = false
            self.backgroundColor = ColorHelper.PendingGroup
            // remove trash button
            updateButtonsVisibility(visible: true)
        }
        else
        {
            self.group?.locked = true
            self.backgroundColor = ColorHelper.LockedGroup
            updateButtonsVisibility(visible: false)
        }
        SetLockIconState()
    }
    
    func updateButtonsVisibility(visible: Bool)
    {
        self.deleteButton.isEnabled = visible
        self.addDiverButton.isEnabled = visible
        self.settingsButton.isEnabled = visible
    }
    
    func SetLockIconState()
    {
        IconHelper.SetButtonIcon(lockButton, icon: group?.locked == true ? Icon.Locked : Icon.Unlocked, fontSize: toolbarButtonFontSize, center: false)
    }
}
