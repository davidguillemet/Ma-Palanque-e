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
    var group: Group!
    var diverId: String!
    
    @IBOutlet weak var diverLabel: UILabel!
    @IBOutlet weak var diverLevel: UILabel!
    @IBOutlet weak var guideButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func clickGuideButton(sender: AnyObject)
    {
        // If diver is already the guide, do nothing
        if (group.guide != nil && group.guide == diverId)
        {
            return
        }
        
        // Set current idvere as guide
        group.guide = diverId
        
        // Redraw table
        collectionItem.tableView.reloadData()
    }
}
