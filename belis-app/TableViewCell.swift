//
//  TableViewCell.swift
//  BelIS
//
//  Created by Thorsten Hell on 08/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var lblBezeichnung: UILabel!
    
    @IBOutlet weak var lblStrasse: UILabel!
    
    @IBOutlet weak var lblSubText: UILabel!
    
    @IBOutlet weak var lblZusatzinfo: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
