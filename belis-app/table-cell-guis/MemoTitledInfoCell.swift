//
//  MemoTitledInfoCell.swift
//  belis-app
//
//  Created by Thorsten Hell on 13/03/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import UIKit

class MemoTitledInfoCell: UITableViewCell,CellDataUI {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblData: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblData.isEditable=false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fillFromCellData(_ cellData :CellData){
        if let d=cellData as? MemoTitledInfoCellData {
            lblTitle.text=d.title
            lblData.text=d.data
            lblData.scrollRangeToVisible(NSMakeRange(0,0))
        }
    }
    func getPreferredCellHeight() -> CGFloat {
        return CGFloat(90)
    }

    
}

class MemoTitledInfoCellData : CellData{
    var title: String
    var data: String
    
    init(title: String,data: String) {
        self.title=title
        self.data=data
    }
    @objc func getCellReuseIdentifier() -> String {
        return "memoTitled"
    }

}
