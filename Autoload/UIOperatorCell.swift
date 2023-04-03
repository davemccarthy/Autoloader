//
//  UIOperatorCell.swift
//  Autoload
//
//  Created by David McCarthy on 19/11/2021.
//  Copyright © 2021 David McCarthy. All rights reserved.
//

import UIKit

class UIOperatorCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var centreLable: UILabel!
    @IBOutlet weak var dialcodeLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var mobileLabel: UILabel!
}
