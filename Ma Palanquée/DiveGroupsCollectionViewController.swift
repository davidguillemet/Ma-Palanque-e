//
//  DiveGroupsCollectionViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 26/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class DiveGroupsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UIPopoverPresentationControllerDelegate
{
    fileprivate let reuseIdentifier = "GroupCollectionViewCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
    fileprivate let rowSpacing = CGFloat(10.0)
    fileprivate let colSpacing = CGFloat(10.0)
    fileprivate let groupCellCornerRadius = CGFloat(5)
    
    var trip: Trip!
    var dive: Dive!
    var groups: [Group]?
    var availableDivers: Set<String>!
    
    // divers which have been excluded from the groups
    // -> add to the dive once we save the groups
    var newExcludedDivers: Set<String> = Set<String>()
    
    private let buttonVerticalMargin = CGFloat(10)
    private let menuButtonSize = CGFloat(44)
    private let buttonBottomMargin: CGFloat = CGFloat(10)
    private let buttonRightMargin: CGFloat = CGFloat(10)
    
    private var menuButton: UIView!
    private var menuButtons: [UIView]?
    private var overlay: UIView?
    private let animationDelay: TimeInterval = 0.03
    
    private var collectionViewCellToAddDivers: GroupCollectionViewCell?
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        IconHelper.SetIcon(forBarButtonItem: cancelButton, icon: Icon.CancelCircled, fontSize: 24)
        IconHelper.SetIcon(forBarButtonItem: saveButton, icon: Icon.Save, fontSize: 24)

        if (dive.groups == nil || dive.groups!.count == 0)
        {
            dive.generateGroups(trip)
        }
        
        // Copy all groups
        if (dive.groups != nil)
        {
            groups = dive.groups!.map({ (group: Group) -> Group in
                return Group(group: group)
            })
        }
        
        // Build the list containing available divers which are not part of a group (locked or not locked)
        availableDivers = dive.getAvailableDivers(trip, scanOnlyLockedGroups: false)
        
        let layout: UICollectionViewFlowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSize(width: 250, height: 400);
        layout.sectionHeadersPinToVisibleBounds = true
        layout.sectionFootersPinToVisibleBounds = true
        
        self.collectionView?.allowsSelection = false
        
        self.menuButton = createButtonContainerView(icon: Icon.More, index: 0, action: #selector(openMenu))
        self.menuButton.alpha = 1

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func groupHasBeenModified(_ index: IndexPath)
    {
        self.collectionView?.reloadItems(at: [index]) // TODO : on doit faire ça ou pas?
    }
    
    func addNewExcludedDiver(_ diver: String)
    {
       newExcludedDivers.insert(diver)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Actions
    
    func removeCollectionCell(_ item: UICollectionViewCell)
    {
        // Simply remove the group from the list
        if let indexPath = self.collectionView!.indexPath(for: item)
        {
            self.collectionView?.performBatchUpdates({
                
                self.groups!.remove(at: indexPath.row)
                self.collectionView!.deleteItems(at: [indexPath])
                
            }, completion: { (finished: Bool) in
                
                self.collectionView!.collectionViewLayout.invalidateLayout()
                
            })
        }
    }

    func addGroup(sender: UIView)
    {
        self.performSegue(withIdentifier: "SelectDiversForNewGroup", sender: self)
    }

    func addDivers(toGroup group: GroupCollectionViewCell)
    {
        self.collectionViewCellToAddDivers = group
        self.performSegue(withIdentifier: "AddDiversToGroup", sender: self)
    }
    
    func moveDiver(at diverSourceIndex: IndexPath, fromGroupAt sourceGroupIndex: IndexPath, toGroupAt targetGroupIndex: IndexPath, at targetDiverIndex: IndexPath?)
    {
        // Remove the diver from the initial group, or remove the group if ot was th eonly diver
        let fromGroup: Group = self.groups![sourceGroupIndex.row]
        
        var indexToReload: [IndexPath] = [IndexPath]()
        var indexToRemove: [IndexPath] = [IndexPath]()
        
        guard let diverToMove: String = try? fromGroup.diverAt(diverSourceIndex.row) else
        {
            return
        }
        
        if fromGroup.diverCount > 1
        {
            // Just remove the diver
            fromGroup.removeDiverAt(diverSourceIndex.row)
            if let _: GroupCollectionViewCell = self.collectionView?.cellForItem(at: sourceGroupIndex) as? GroupCollectionViewCell
            {
                // If the cell is still on the screen...
                indexToReload.append(sourceGroupIndex)
            }
        }
        else
        {
            // Remove the group...
            indexToRemove.append(sourceGroupIndex)
        }
        
        // Add the diver in the target Group
        let targetGroup: Group = self.groups![targetGroupIndex.row]
        if targetDiverIndex != nil
        {
            targetGroup.insertDiver(diverToMove, atIndex: targetDiverIndex!.row)
        }
        else
        {
            targetGroup.addDiver(diverToMove)
        }
        
        indexToReload.append(targetGroupIndex)
        
        if indexToReload.count > 0
        {
            self.collectionView?.reloadItems(at: indexToReload)
        }
        
        if indexToRemove.count > 0
        {
            self.groups!.remove(at: indexToRemove[0].row)
            self.collectionView?.deleteItems(at: indexToRemove)
        }
    }
    
    func openMenu()
    {
        createOverlay(menuButtonView: menuButton)
        
        // Initialize Buttons array
        self.menuButtons = [UIView]()
        
        // Create Buttons
        var buttonIndex: CGFloat = CGFloat(0)
        
        createButtonContainerView(icon: Icon.Close, index: buttonIndex, action: #selector(closeMenu))
        buttonIndex += 1

        let availableDivers: [Diver] = getAvailableDivers()
        if availableDivers.count > 0
        {
            createButtonContainerView(icon: Icon.Users, index: buttonIndex, action: #selector(addGroup))
            buttonIndex += 1
        }
        
        createButtonContainerView(icon: Icon.Locked, index: buttonIndex, action: nil)
        buttonIndex += 1
        
        createButtonContainerView(icon: Icon.Unlocked, index: buttonIndex, action: nil)
        buttonIndex += 1

        createButtonContainerView(icon: Icon.Refresh, index: buttonIndex, action: nil)
        buttonIndex += 1

        // Animate alpha property for each view
        displaybuttonsWithAnimation()
    }
    
    func closeMenu()
    {
        // Remove overlay
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            
            self.overlay?.alpha = 0
            
        }, completion: { finished in
            
            self.overlay?.removeFromSuperview()
        })
        
        // Remove all buttons from super view
        hideButtonsWithAnimation()
        
    }
    
    func displaybuttonsWithAnimation()
    {
        var delay: TimeInterval = 0
        
        for buttonView in self.menuButtons!
        {
            UIView.animate(withDuration: 0.2, delay: delay, options: UIViewAnimationOptions.curveLinear, animations: {

                buttonView.alpha = 1
            
            }, completion: { finished in
                
                // Nothing here
            
            })
            
            delay += self.animationDelay
        }
    }
    
    func hideButtonsWithAnimation()
    {
        var delay: TimeInterval = 0
        
        // Browse buttons in reverse order
        for index in (0..<self.menuButtons!.count).reversed()
        {
            let buttonView: UIView = self.menuButtons![index]
            
            UIView.animate(withDuration: 0.2, delay: delay, options: UIViewAnimationOptions.curveLinear, animations: {
                
                buttonView.alpha = 0
            
            }, completion: { finished in
                
                buttonView.isHidden = true
                buttonView.removeFromSuperview()
            })
            
            delay += self.animationDelay
        }
    }
    
    func createOverlay(menuButtonView: UIView)
    {
        // Create overlay and insert it as subview
        self.overlay = UIView(frame: view.frame)
        self.overlay?.backgroundColor = UIColor.white
        self.overlay?.alpha = 0 // initially transparent
        
        self.overlay?.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        // Create Constraints
        let topConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: overlay, attribute: NSLayoutAttribute.top
            , multiplier: 1.0, constant: 0)
        let rightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: overlay, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0)
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: overlay, attribute: NSLayoutAttribute.bottom
            , multiplier: 1.0, constant: 0)
        let leftConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: overlay, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0)
        
        self.view.insertSubview(self.overlay!, belowSubview: menuButtonView)

        NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, leftConstraint])
 
        UIView.animate(withDuration: 0.2, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
            
            self.overlay?.alpha = 0.7
            
        }, completion: { finished in
            
            // Nothing here
            
        })
        
    }
    
    func createButtonContainerView(icon: Icon, index: CGFloat, action: Selector?) -> UIView
    {
        // Create the container view a white circle with shadows
        let containerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.menuButtonSize, height: self.menuButtonSize))
        // Set full transparency first
        containerView.alpha = 0
        containerView.backgroundColor = ColorHelper.TableViewBackground
        containerView.layer.cornerRadius = CGFloat(self.menuButtonSize / 2)
        
        // Set the container view shadow
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        containerView.layer.shadowRadius = 5
        
        // Create the embedded button using the specified Icon
        let menuButton: UIButton = UIButton(frame: CGRect(x: 7, y: 7, width: 30, height: 30))
        IconHelper.SetButtonIcon(menuButton, icon: icon, fontSize: 30, center: true)
        menuButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        
        if action != nil
        {
            menuButton.addTarget(self, action: action!, for: UIControlEvents.touchUpInside)
        }
        
        // Add the button as a subview of the circled container view
        containerView.addSubview(menuButton)
        
        menuButton.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleTopMargin]

        // Finally, add the Circled container view as a subview of the current view
        self.view.addSubview(containerView)
        
        // Get screen size to calculate Button position
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth: CGFloat = screenSize.width
        let screenHeight: CGFloat = screenSize.height
        
        let menuXPosition = screenWidth - self.buttonRightMargin - self.menuButtonSize
        let menuYposition = screenHeight - self.buttonBottomMargin - self.menuButtonSize
        
        // The Y-Position depends on the index of the button
        let newViewYPosition = menuYposition - index * (CGFloat(self.buttonVerticalMargin) + containerView.frame.size.height)
        let newViewXPosition = menuXPosition
        
        containerView.frame.origin.x = newViewXPosition
        containerView.frame.origin.y = newViewYPosition
        
        // Pin the new view to the right/Bottom edge of the super view
        containerView.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleLeftMargin]
        
        let bottomConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.bottom
            , multiplier: 1.0, constant: self.buttonBottomMargin)
        
        let rightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: containerView, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: self.buttonRightMargin)
        
        NSLayoutConstraint.activate([bottomConstraint, rightConstraint])
        
        // Add the current button view to the list for future removal.
        self.menuButtons?.append(containerView)
        
        return containerView
    }
    
    @IBAction func unwindToNewGroup(_ sender: UIStoryboardSegue)
    {
        let diversController = sender.source as? DiversTableViewController
        if (diversController != nil)
        {
            if diversController!.selection.count == 0
            {
                // No divers selected, just return
                return;
            }
            
            // Create a new group
            let divers: [String] = diversController!.selection.map { $0 }
            let group: Group = Group(divers: divers, guide: nil)
            
            // insert it in the list, at position 0
            self.groups?.insert(group, at: 0)
            
            // And refresh the collection again
            self.collectionView?.reloadData()
            self.collectionView?.collectionViewLayout.invalidateLayout()
        }
        
        // Dès que l'action a été effectuée, on ferme le menu
        closeMenu()
        
        // scroll to top
        let insetTop = self.collectionView?.contentInset.top
        let topOffest = CGPoint(x: CGFloat(0), y: CGFloat(-(insetTop ?? 0)))
        self.collectionView?.setContentOffset(topOffest, animated: true)
    }

    @IBAction func unwindToAddDiversToGroup(_ sender: UIStoryboardSegue)
    {
        let diversController = sender.source as? DiversTableViewController
        if (diversController != nil && self.collectionViewCellToAddDivers != nil)
        {
            if diversController!.selection.count == 0
            {
                // No divers selected, just return
                return;
            }

            // Convert the divers selectio to a string array
            let divers: [String] = diversController!.selection.map { $0 }
            
            // Add divers to the group
            self.collectionViewCellToAddDivers?.group?.addDivers(divers: divers)
            
            // Get the indexpath from the modified group collection view cell
            if let groupIndex: IndexPath = self.collectionView?.indexPath(for: self.collectionViewCellToAddDivers!)
            {
                // And reload the corresponding collectionview cell
                self.collectionView?.reloadItems(at: [groupIndex])
            }
        }
    }

    func getAvailableDivers() -> [Diver]
    {
        var availableDivers: Set<String> = Set<String>()
        
        // Get all trip divers and remove excluded divers (from the dive and newly excluded divers)
        let allDivers: Set<String> = self.trip.divers

        for diverFromTrip in allDivers
        {
            if let diveExcludedDivers = self.dive.excludedDivers, diveExcludedDivers.contains(diverFromTrip)
            {
                continue;
            }
            if newExcludedDivers.contains(diverFromTrip)
            {
                continue;
            }
            availableDivers.insert(diverFromTrip)
        }
        
        // Browse current groups to remove used divers
        if self.groups != nil
        {
            for group in self.groups!
            {
                for index in 0..<group.diverCount
                {
                    if let groupDiver = try? group.diverAt(index)
                    {
                        availableDivers.remove(groupDiver)
                    }
                }
            }
        }
        
        return availableDivers.map { DiverManager.GetDiver($0) }
    }

    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.groups != nil ? self.groups!.count : 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GroupCollectionViewCell
    
        cell.contentView.frame = cell.bounds
        cell.contentView.autoresizingMask = [UIViewAutoresizing.flexibleHeight]
        cell.contentView.translatesAutoresizingMaskIntoConstraints = true
        
        let group = groups![indexPath.row]
        
        cell.dive = self.dive
        cell.viewController = self
        cell.group = group
        
        cell.backgroundColor = group.locked ? ColorHelper.LockedGroup : ColorHelper.PendingGroup

        cell.layer.cornerRadius = groupCellCornerRadius    
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        self.groups!.insert(self.groups!.remove(at: sourceIndexPath.row), at: destinationIndexPath.row)
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    {
        // Selecton is disabled
        return false
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        let availableWidth = self.view.frame.size.width - sectionInsets.right - sectionInsets.left + colSpacing
        
        let minimumGroupWidth = CGFloat(250.0)
        let maximumGroupWidth = 350
        
        let numberOfGroupsPerRow = floor(availableWidth / (minimumGroupWidth + colSpacing))
        
        var groupWidth = Int( availableWidth / numberOfGroupsPerRow)
        groupWidth = groupWidth - Int(colSpacing)
        
        if (groupWidth > maximumGroupWidth)
        {
            groupWidth = maximumGroupWidth
        }
        
        var diverCount: Int
        
        if let groupCell = self.collectionView!.cellForItem(at: indexPath) as? GroupCollectionViewCell
        {
            diverCount = groupCell.group == nil ? 0 : groupCell.group!.diverCount
        }
        else
        {
           diverCount = groups![indexPath.row].diverCount
        }
        
        return CGSize(width: groupWidth, height: 44 + diverCount * 44)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
            return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return rowSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return colSpacing
    }
    
    // MARK: Actions
    @IBAction func cancelAction(_ sender: AnyObject)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let targetNavController = segue.destination as? UINavigationController
        
        if (segue.identifier == "SelectDiversForNewGroup")
        {
            let targetController = targetNavController?.topViewController as? DiversTableViewController
            targetController?.initialDivers = self.getAvailableDivers()
            targetController?.selectionType = DiversSelectionType.CreateGroup
        }
        else if (segue.identifier == "AddDiversToGroup")
        {
            let targetController = targetNavController?.topViewController as? DiversTableViewController
            targetController?.initialDivers = self.getAvailableDivers()
            targetController?.selectionType = DiversSelectionType.AddDiversToGroup
        }
    }
}
