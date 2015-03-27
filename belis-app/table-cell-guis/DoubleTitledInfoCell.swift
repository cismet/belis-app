//
//  DoubleTitledInfoCell.swift
//  belis-app
//
//  Created by Thorsten Hell on 13/03/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import UIKit

class DoubleTitledInfoCell: UITableViewCell,CellDataUI {

    @IBOutlet weak var lblLeftTitle: UILabel!
    @IBOutlet weak var lblRightTitle: UILabel!
    @IBOutlet weak var lblLeftData: UILabel!
    @IBOutlet weak var lblRightData: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func fillFromCellData(cellData :CellData){
        if let d=cellData as? DoubleTitledInfoCellData {
            lblLeftTitle.text=d.titleLeft
            lblRightTitle.text=d.titleRight
            lblLeftData.text=d.dataLeft
            lblRightData.text=d.dataRight
        }
        
    }
}
class DoubleTitledInfoCellData: CellData {
    var titleLeft: String
    var dataLeft: String
    var titleRight: String
    var dataRight: String
    
    init(titleLeft: String,dataLeft: String,titleRight: String,dataRight: String) {
        self.titleLeft=titleLeft
        self.dataLeft=dataLeft
        self.titleRight=titleRight
        self.dataRight=dataRight
    }
    func getCellReuseIdentifier() -> String {
        return "doubleTitled"
    }

}