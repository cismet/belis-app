//
//  SimpleInfoCell.swift
//  belis-app
//
//  Created by Thorsten Hell on 16/03/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation

class SimpleInfoCell : UITableViewCell, CellDataUI {
    func fillFromCellData(cellData: CellData) {
        if let d=cellData as? SimpleInfoCellData{
            super.textLabel!.text=d.data
            accessoryType=UITableViewCellAccessoryType.None

        }else if let d=cellData as? SimpleInfoCellDataWithDetails{
            super.textLabel!.text=d.data
            accessoryType=UITableViewCellAccessoryType.DisclosureIndicator

        }
    }
    func getPreferredCellHeight() -> CGFloat {
        return CGFloat(44)
    }

    
}

class SimpleInfoCellData : CellData {
    var data: String
    
    init(data:String){
        self.data=data
    }
    
    @objc func getCellReuseIdentifier() -> String {
        return "simple"
    }
}

class SimpleInfoCellDataWithDetails : CellData,SimpleCellActionProvider {
    var data: String
    var details: [String: [CellData]] = ["main":[]]
    var sections: [String]
    var actions: [BaseEntityAction]?
    
    init(data:String,details:[String: [CellData]], sections: [String]){
        self.data=data
        self.details=details
        self.sections=sections
    }
    init(data:String,details:[String: [CellData]], sections: [String], actions: [BaseEntityAction]){
        self.data=data
        self.details=details
        self.sections=sections
        self.actions=actions
    }
    
    @objc func getCellReuseIdentifier() -> String {
        return "simple"
    }
    
    
    @objc func action(vc:UIViewController) {
        let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
        detailVC.sections=sections
        detailVC.setCellData(details)
        if let detailActions=actions {
            let action = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: detailVC, action:"moreAction")
            detailVC.navigationItem.rightBarButtonItem = action
            detailVC.actions=detailActions
        }
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}