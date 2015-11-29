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
    private let reuseIdentifier = "GroupCollectionViewCell"
    private let sectionInsets = UIEdgeInsets(top: 3.0, left: 3.0, bottom: 3.0, right: 3.0)
    private let rowSpacing = CGFloat(5.0)
    private let colSpacing = CGFloat(5.0)
    
    var trip: Trip!
    var dive: Dive!
    var groups: [Group]!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        IconHelper.SetBarButtonIcon(cancelButton, icon: IconValue.IconClose, fontSize: nil, center: false)
        IconHelper.SetBarButtonIcon(saveButton, icon: IconValue.IconSave, fontSize: nil, center: false)

        dive.generateGroups(trip)
        groups = dive.groups
        
        let layout: UICollectionViewFlowLayout = self.collectionViewLayout as! UICollectionViewFlowLayout
        layout.estimatedItemSize = CGSize(width: 250, height: 200);
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(GroupCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func groupForIndexPath(indexPath: NSIndexPath) -> Group
    {
        return groups[indexPath.row]
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groups.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! GroupCollectionViewCell
    
        cell.contentView.frame = cell.bounds
        cell.contentView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        
        let group = groups[indexPath.row]
        cell.group = group
        
        cell.backgroundColor = group.locked ? ColorHelper.LockedGroup : ColorHelper.PendingGroup
    
        return cell
    }

    override func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath)
    {
            // move your data order
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
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
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
            
        let group =  groupForIndexPath(indexPath)
        return CGSize(width: groupWidth, height: (group.divers!.count  + 1) * 60)
    }
    
    //3
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets
    {
            return sectionInsets
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return rowSpacing;
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat
    {
        return colSpacing
    }
    
    // MARK: Actions
    @IBAction func cancelAction(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
