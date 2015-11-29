//
//  TripTableViewCell.swift
//  Ma Palanquée
//
//  Created by David Guillemet on 09/11/2015.
//  Copyright © 2015 David Guillemet. All rights reserved.
//

import UIKit

class TripTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var tripDescLabel: UILabel!
    @IBOutlet weak var tripDateLabel: UILabel!
    
    @IBOutlet weak var tripIcon: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
