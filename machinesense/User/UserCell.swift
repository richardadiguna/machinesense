//
//  UserCell.swift
//  machinesense
//
//  Created by Richard Adiguna on 19/01/18.
//  Copyright © 2018 Richard Adiguna. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var userCellTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
