//
//  GroupCollectionViewCell.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 27/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class GroupCollectionViewCell: UICollectionViewCell, UITableViewDataSource, UITableViewDelegate
{
    private var cellIdentifier: String = "GroupTableViewCell"
    var group: Group!
    {
            didSet
            {
                self.divers = DiverManager.GetSortedDivers(group.divers)
                SetLockIconState()
            }
    }
    
    var divers: [Diver]!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var lockButton: UIButton!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()

        tableView.delegate = self
        tableView.dataSource = self
        
        IconHelper.SetButtonIcon(deleteButton, icon: IconValue.IconTrash, fontSize: 20, center: false)
    }

    func diverLabel(diver: Diver) -> String
    {
        return "\(diver.firstName) \(diver.lastName)"
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        var diversCount = group.divers != nil ? group.divers!.count : 0
        if (group.guide != nil)
        {
            diversCount += 1
        }
        return diversCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! GroupTableTableViewCell
        
        var diver: Diver
        if (indexPath.row == 0 && group.guide != nil)
        {
            diver = DiverManager.GetDiver(group.guide!)
        }
        else
        {
            var diverIndex = indexPath.row
            if (group.guide != nil)
            {
                diverIndex--
            }
            diver = self.divers[diverIndex]
        }
        
        cell.diverLabel.text = diverLabel(diver)
        
        cell.diverLevel.adjustsFontSizeToFitWidth = true
        cell.diverLevel.text = diver.level.stringValue
        
        let colors = PreferencesHelper.GetDiveLevelColors(diver.level)
        cell.diverLevel.backgroundColor = colors.color
        cell.diverLevel.textColor = colors.reversedColor
        cell.diverLevel.layer.cornerRadius = cell.diverLevel.layer.frame.width / 2
        cell.diverLevel.clipsToBounds = true
        
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
        IconHelper.SetButtonIcon(lockButton, icon: group.locked ? IconValue.IconLocked : IconValue.IconUnlocked, fontSize: 20, center: false)
    }
}
