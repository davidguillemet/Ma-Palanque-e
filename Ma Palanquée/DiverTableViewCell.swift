//
//  DiverTableViewCell.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 13/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class DiverTableViewCell: UITableViewCell {

    var viewcontroller : DiversTableViewController!
    var id: String!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var selectionSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switchChanged(sender: AnyObject)
    {
        viewcontroller.selectDiver(self, selected: selectionSwitch.on)
    }
}
