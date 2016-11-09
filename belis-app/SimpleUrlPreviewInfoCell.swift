//
//  SimpleUrlPreviewInfoCell.swift
//  belis-app
//
//  Created by Thorsten Hell on 25/03/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation

class SimpleUrlPreviewInfoCell : UITableViewCell, CellDataUI {
    
    func fillFromCellData(_ cellData: CellData) {
        if let d=cellData as? SimpleUrlPreviewInfoCellData{
            super.textLabel!.text=d.title
        }
    }
    func getPreferredCellHeight() -> CGFloat {
        return CGFloat(44)
    }

}

class SimpleUrlPreviewInfoCellData : CellData, SimpleCellActionProvider {
    var title: String
    var url: String
    
    init(title:String, url:String){
        self.title=title
        self.url=url
    }
    
    @objc func getCellReuseIdentifier() -> String {
        return "simpleUrl"
    }
    
    @objc func action(_ vc:UIViewController) {
        let previewVC=DokumentPreviewVC(nibName: "DokumentPreviewVC", bundle: nil)
        previewVC.nsUrlToLoad=URL(string: self.url )
        vc.navigationController?.pushViewController(previewVC, animated: true)
    }

    
}
