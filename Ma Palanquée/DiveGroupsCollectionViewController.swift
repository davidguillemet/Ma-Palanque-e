//
//  DiveGroupsCollectionViewController.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 26/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class DiveGroupsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout
{
    fileprivate let reuseIdentifier = "GroupCollectionViewCell"
    fileprivate let sectionInsets = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)
    fileprivate let rowSpacing = CGFloat(5.0)
    fileprivate let colSpacing = CGFloat(5.0)
    
    var trip: Trip!
    var dive: Dive!
    var groups: [Group]?
    var availableDivers: Set<String>!
    
    // divers which have been excluded from the groups
    // -> add to the dive once we save the groups
    var newExcludedDivers: Set<String> = Set<String>()
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        IconHelper.SetBarButtonIcon(cancelButton, icon: IconValue.IconClose, fontSize: nil, center: false)
        IconHelper.SetBarButtonIcon(saveButton, icon: IconValue.IconSave, fontSize: nil, center: false)

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
        layout.estimatedItemSize = CGSize(width: 250, height: 200);
        
        self.collectionView?.allowsSelection = false

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
            self.groups!.remove(at: indexPath.row)
            self.collectionView!.deleteItems(at: [indexPath])
        }
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
        cell.contentView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        let group = groups![indexPath.row]
        
        cell.dive = self.dive
        cell.viewController = self
        cell.group = group
        
        cell.backgroundColor = group.locked ? ColorHelper.LockedGroup : ColorHelper.PendingGroup
    
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
            diverCount = groupCell.group.diverCount
        }
        else
        {
           diverCount = groups![indexPath.row].diverCount
        }
        
        return CGSize(width: groupWidth, height: 40 + diverCount * 44)
    }
    
    //3
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
            return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return rowSpacing;
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
}
