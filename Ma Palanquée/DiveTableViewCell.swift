//
//  DiveTableViewCell.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 23/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class DiveTableViewCell: UITableViewCell {

    @IBOutlet weak var diveSiteTextField: UILabel!
    @IBOutlet weak var diveTimeTextField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
