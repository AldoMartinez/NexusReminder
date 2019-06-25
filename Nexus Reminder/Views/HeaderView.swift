//
//  HeaderView.swift
//  Nexus Reminder
//
//  Created by Aldo Aram Martinez Mireles on 6/25/19.
//  Copyright © 2019 Aldo Aram Martinez Mireles. All rights reserved.
//

import UIKit

class HeaderView: UITableViewCell {

    @IBOutlet var matriculaTextField: UILabel!
    @IBOutlet var logoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
