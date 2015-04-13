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
        } else if let d=cellData as? SingleTitledInfoCellDataWithDetails {
            lblTitle.text=d.title
            lblData.text=d.data
            
        }
    }

}

class SingleTitledInfoCellData:CellData {
    var title: String
    var data: String
    
    init(title: String,data: String) {
        self.title=title
        self.data=data
    }
    
    func getCellReuseIdentifier() -> String {
        return "singleTitled"
    }
    
}

class SingleTitledInfoCellDataWithDetails:CellData, SimpleCellActionProvider {
    var title: String
    var data: String
    var details: [String: [CellData]] = ["main":[]]

    
    init(title: String,data: String, details:[String: [CellData]]) {
        self.title=title
        self.data=data
        self.details=details
    }
    
    func getCellReuseIdentifier() -> String {
        return "singleTitled"
    }
    
    func action(vc:UIViewController) {
        let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
        detailVC.setData(details)
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}