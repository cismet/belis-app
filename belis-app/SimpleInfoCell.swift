//
//  SimpleInfoCell.swift
//  belis-app
//
//  Created by Thorsten Hell on 16/03/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation

class SimpleInfoCell : UITableViewCell, CellDataUI {
    func fillFromCellData(_ cellData: CellData) {
        if let d=cellData as? SimpleInfoCellData{
            super.textLabel!.text=d.data
            accessoryType=UITableViewCellAccessoryType.none

        }else if let d=cellData as? SimpleInfoCellDataWithDetails{
            super.textLabel!.text=d.data
            accessoryType=UITableViewCellAccessoryType.disclosureIndicator

        }else if let d=cellData as? SimpleInfoCellDataWithDetailsDrivenByWholeObject{
            super.textLabel!.text=d.data
            accessoryType=UITableViewCellAccessoryType.disclosureIndicator
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
    
    @objc func getCellReuseIdentifier() -> String {
        return "simple"
    }
    
    
    @objc func action(_ vc:UIViewController) {
        let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
        detailVC.sections=sections
        detailVC.setCellData(details)
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}

class SimpleInfoCellDataWithDetailsDrivenByWholeObject : CellData,SimpleCellActionProvider {
    var detailObject: BaseEntity?
    var data: String
    var showSubActions: Bool
    //var mvc: MainViewController
    init(data:String,detailObject: BaseEntity, showSubActions:Bool){
        assert(detailObject is CellDataProvider)
        self.data=data
        self.detailObject=detailObject
        self.showSubActions=showSubActions
    }
    
    @objc func getCellReuseIdentifier() -> String {
        return "simple"
    }
    
    
    @objc func action(_ vc:UIViewController) {
        let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
        detailVC.sections=(detailObject as! CellDataProvider).getDataSectionKeys()
        detailVC.setCellData((detailObject as! CellDataProvider).getAllData())


        detailVC.objectToShow=detailObject
        if showSubActions {
            if let actionProvider = detailObject as? ActionProvider  {
                let action = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: detailVC, action:Selector(("moreAction")))
                detailVC.navigationItem.rightBarButtonItem = action
                detailVC.actions=actionProvider.getAllActions()
            }
        }
        vc.navigationController?.pushViewController(detailVC, animated: true)
    }
    
}







