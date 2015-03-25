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
        }
    }
    
}

class SimpleInfoCellData : CellData {
    var data: String
    
    init(data:String){
        self.data=data
    }
    
    func getCellReuseIdentifier() -> String {
        return "simple"
    }
}