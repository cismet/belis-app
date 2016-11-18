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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func fillFromCellData(_ cellData :CellData){
        if let d=cellData as? DoubleTitledInfoCellData {
            lblLeftTitle.text=d.titleLeft
            lblRightTitle.text=d.titleRight
            lblLeftData.text=d.dataLeft
            lblRightData.text=d.dataRight
            accessoryType=UITableViewCellAccessoryType.none
            
        } else if let d=cellData as? DoubleTitledInfoCellDataWithDetails {
            lblLeftTitle.text=d.titleLeft
            lblRightTitle.text=d.titleRight
            lblLeftData.text=d.dataLeft
            lblRightData.text=d.dataRight
            accessoryType=UITableViewCellAccessoryType.disclosureIndicator

        }
        
    }
    func getPreferredCellHeight() -> CGFloat {
        return CGFloat(54)
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
    @objc func getCellReuseIdentifier() -> String {
        return "doubleTitled"
    }

}

class DoubleTitledInfoCellDataWithDetails:CellData, SimpleCellActionProvider {
    var titleLeft: String
    var dataLeft: String
    var titleRight: String
    var dataRight: String
    var details: [String: [CellData]] = ["main":[]]
    var sections: [String]
    
    init(titleLeft: String,dataLeft: String,titleRight: String,dataRight: String, details:[String: [CellData]], sections: [String]) {
        self.titleLeft=titleLeft
        self.dataLeft=dataLeft
        self.titleRight=titleRight
        self.dataRight=dataRight
        self.details=details
        self.sections=sections
    }
   @objc  
    func getCellReuseIdentifier() -> String {
        return "doubleTitled"
    }
    
    @objc func action(_ vc:UIViewController) {
        let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
        detailVC.sections=sections
        detailVC.setCellData(details)
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
