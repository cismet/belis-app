//
//  DetailVC.swift
//  belis-app
//
//  Created by Thorsten Hell on 25/03/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import UIKit

class DetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var data: [String: [CellData]] = ["main":[]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        // Do any additional setup after loading the view.
        tableView.registerNib(UINib(nibName: "SingleTitledInfoCell", bundle: nil), forCellReuseIdentifier: "singleTitled")
        tableView.registerNib(UINib(nibName: "DoubleTitledInfoCell", bundle: nil), forCellReuseIdentifier: "doubleTitled")
        tableView.registerNib(UINib(nibName: "MemoTitledInfoCell", bundle: nil), forCellReuseIdentifier: "memoTitled")
        tableView.registerClass(SimpleInfoCell.self, forCellReuseIdentifier: "simple")
            tableView.registerClass(SimpleUrlPreviewInfoCell.self, forCellReuseIdentifier: "simpleUrl")
        tableView.rowHeight=UITableViewAutomaticDimension
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setData(data:[String: [CellData]]){
        self.data=data
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    //UITableViewDataSource
  
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey: String = data.keys.array[section]
        return data[sectionKey]!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row=indexPath.row
        let section = indexPath.section
        let sectionKey: String = data.keys.array[section]
        let dataItem: CellData = data[sectionKey]![row]
        let cellReuseId=dataItem.getCellReuseIdentifier()
        let cell: UITableViewCell  = tableView.dequeueReusableCellWithIdentifier(cellReuseId) as UITableViewCell
        if let filler = cell as? CellDataUI {
            filler.fillFromCellData(dataItem)
        }
        else {
            println("NO CELLDATAUI")
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section==0 {
            return 0
        }
        else {
            return 20
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let row=indexPath.row
        let section = indexPath.section
        let sectionKey: String = data.keys.array[section]
        let dataItem: CellData = data[sectionKey]![row]
        let cellReuseId=dataItem.getCellReuseIdentifier()
        let cell: UITableViewCell  = tableView.dequeueReusableCellWithIdentifier(cellReuseId) as UITableViewCell
        if let heightProvider = cell as? CellDataUI {
            return heightProvider.getPreferredCellHeight()
        }
        return 44
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.keys.array.count
    }
    
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let row=indexPath.row
        let section = indexPath.section
        let sectionKey: String = data.keys.array[section]
        let dataItem: CellData = data[sectionKey]![row]
        if let actionProvider = dataItem as? SimpleCellActionProvider {
            (dataItem as SimpleCellActionProvider).action(self)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data.keys.array[section]
    }
    
    
    
    
    
    
    
    //    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    //        if (section==0){
    //            return "Leuchten \(searchResults[LEUCHTEN].count)";
    //        }
    //        else if (section==1){
    //            return "Mauerlaschen \(searchResults[MAUERLASCHEN].count)";
    //        }else
    //        {
    //            return "Leitungen \(searchResults[LEITUNGEN].count)";
    //        }
    //    }
    
    

}
