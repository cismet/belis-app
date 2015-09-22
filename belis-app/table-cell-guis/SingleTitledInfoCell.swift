//
//  SingleTitledInfoCell.swift
//  belis-app
//
//  Created by Thorsten Hell on 13/03/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import UIKit

class SingleTitledInfoCell: UITableViewCell, CellDataUI{
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblData: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillFromCellData(cellData :CellData){
        if let d=cellData as? SingleTitledInfoCellData {
            lblTitle.text=d.title
            lblData.text=d.data
            accessoryType=UITableViewCellAccessoryType.None
        } else if let d=cellData as? SingleTitledInfoCellDataWithDetails {
            lblTitle.text=d.title
            lblData.text=d.data
            accessoryType=UITableViewCellAccessoryType.DisclosureIndicator
        }
        
    }
    
    func getPreferredCellHeight() -> CGFloat {
        return CGFloat(56)
    }

}

class SingleTitledInfoCellData:CellData {
    var title: String
    var data: String
    
    init(title: String,data: String) {
        self.title=title
        self.data=data
    }
    
    @objc func getCellReuseIdentifier() -> String {
        return "singleTitled"
    }
    
}

class SingleTitledInfoCellDataWithDetails:CellData, SimpleCellActionProvider {
    var title: String
    var data: String
    var details: [String: [CellData]] = ["main":[]]
    var sections: [String]

    
    init(title: String,data: String, details:[String: [CellData]], sections: [String]) {
        self.title=title
        self.data=data
        self.details=details
        self.sections=sections
    }
    
    @objc func getCellReuseIdentifier() -> String {
        return "singleTitled"
    }
    
    @objc func action(vc:UIViewController) {
        let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
        detailVC.sections=sections
        detailVC.setCellData(details)
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}