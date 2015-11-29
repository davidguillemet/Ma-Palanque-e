//
//  GroupTableTableViewCell.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 28/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class GroupTableTableViewCell: UITableViewCell {

    @IBOutlet weak var diverLabel: UILabel!
    @IBOutlet weak var diverLevel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
