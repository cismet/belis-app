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

    init(data:String,details:[String: [CellData]]){
        self.data=data
        self.details=details

    }
    
    @objc func getCellReuseIdentifier() -> String {
        return "simple"
    }
    
    
    @objc func action(vc:UIViewController) {
        let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
        detailVC.setCellData(details)
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}