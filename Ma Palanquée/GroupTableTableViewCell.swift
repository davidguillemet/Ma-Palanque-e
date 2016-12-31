//
//  GroupTableTableViewCell.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 28/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class GroupTableTableViewCell: UITableViewCell {

    var collectionItem: GroupCollectionViewCell!
    
    @IBOutlet weak var diverLabel: UILabel!
    @IBOutlet weak var diverLevel: UILabel!
    @IBOutlet weak var guideButton: UIButton!

    private var diver: Diver?
    
    var diverId: String?
    {
        didSet
        {
            if diverId != nil
            {
                // Ge the diver from identifier
                self.diver = DiverManager.GetDiver(diverId!)
            
                // Write the diver name as attributed text
                self.diverLabel.attributedText = UIHelper.GetDiverNameAttributedString(forDiver: self.diver!)
            
                // Write the diver level in a circled Label
                IconHelper.WriteDiveLevel(self.diverLevel, (self.diver?.level)!)
            }
            else
            {
                self.diverLabel.attributedText = nil
                self.diverLevel.text = nil
            }
        }
    }
    
    var group: Group?
    {
        didSet
        {
            if (self.group?.guide != nil && self.group?.guide == self.diver?.id)
            {
                self.guideButton.isHidden = false
                self.guideButton.setTitleColor(ColorHelper.GuideIcon, for: UIControlState())
                self.guideButton.backgroundColor = ColorHelper.GuideIconBackground
                self.guideButton.layer.borderColor = ColorHelper.GuideIcon.cgColor
            }
            else if ((self.diver?.level.rawValue)! >= DiveLevel.n4.rawValue)
            {
                self.guideButton.isHidden = false
                self.guideButton.setTitleColor(UIColor.gray, for: UIControlState())
                self.guideButton.backgroundColor = UIColor.white
                self.guideButton.layer.borderColor = UIColor.lightGray.cgColor
            }
            else
            {
                self.guideButton.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        IconHelper.SetButtonIcon(self.guideButton, icon: Icon.Ribbon, fontSize: 18, center: true)
        self.guideButton.layer.cornerRadius = 15
        self.guideButton.layer.borderWidth = 1.0
        self.guideButton.clipsToBounds = true
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func clickGuideButton(_ sender: AnyObject)
    {
        if (self.group?.locked)!
        {
            return
        }
        
        // If diver is already the guide, do nothing
        if (self.group?.guide != nil && self.group?.guide == self.diverId)
        {
            return
        }
        
        // Set current idvere as guide
        self.group?.guide = self.diverId
        
        // Redraw table
        collectionItem.tableView.reloadData()
    }
}
