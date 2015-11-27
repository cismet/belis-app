//
//  DetailVC.swift
//  belis-app
//
//  Created by Thorsten Hell on 25/03/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import UIKit

class DetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, Refreshable{

    @IBOutlet weak var tableView: UITableView!
    var data: [String: [CellData]] = ["main":[]]
    var sections: [String]=[]

    var actions: [BaseEntityAction] = []
    var objectToShow: BaseEntity!
    var callBacker: AnyObject?

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
    
    func setCellData(data:[String: [CellData]]){
        self.data=data
    }
    
    func moreAction() {
        
        if actions.count>0 {
            let optionMenu = UIAlertController(title: nil, message: "Aktion auswählen", preferredStyle: UIAlertControllerStyle.ActionSheet)
            
            for action in actions {
                let alertAction = UIAlertAction(title: action.title, style: action.style, handler: {
                    (alert: UIAlertAction) -> Void in
                        print("Aktion: "+action.title)
                        action.handler(alert, action, self.objectToShow,self)
                    
                    
                })
                optionMenu.addAction(alertAction)
            }
            
            self.presentViewController(optionMenu, animated: true, completion: nil)
        }
        
    }
    
    func doIt (alert: UIAlertAction!) {
        print("mine")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey: String = sections[section]
        return data[sectionKey]?.count ?? 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row=indexPath.row
        let section = indexPath.section
        let sectionKey: String = sections[section]
        let dataItem: CellData = data[sectionKey]![row]
        let cellReuseId=dataItem.getCellReuseIdentifier()
        let cell: UITableViewCell  = tableView.dequeueReusableCellWithIdentifier(cellReuseId)! as UITableViewCell
        if let filler = cell as? CellDataUI {
            filler.fillFromCellData(dataItem)
        }
        else {
            print("NO CELLDATAUI")
        }
        return cell
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if  sections.count>section{
            let sectionKey: String = sections[section]
            if section==0 || (data[sectionKey]?.count ?? 0)==0 {
                return 0
            }
            else {
                return 20
            }
        }
        else {
            return 0
        }
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let row=indexPath.row
        let section = indexPath.section
        let sectionKey: String = sections[section]
        let dataItem: CellData = data[sectionKey]![row]
        let cellReuseId=dataItem.getCellReuseIdentifier()
        let cell: UITableViewCell  = tableView.dequeueReusableCellWithIdentifier(cellReuseId)! as UITableViewCell
        if let heightProvider = cell as? CellDataUI {
            return heightProvider.getPreferredCellHeight()
        }
        return 44
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let row=indexPath.row
        let section = indexPath.section
        let sectionKey: String = sections[section]
        let dataItem: CellData = data[sectionKey]![row]
        if let actionProvider = dataItem as? SimpleCellActionProvider {
            actionProvider.action(self)
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("DetailVC FINISH")
        if let x = (callBacker as? UIImagePickerControllerDelegate) {
            x.imagePickerController!(picker, didFinishPickingMediaWithInfo: info)
        }
        //picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("DetailVC CANCEL")
        if let x = (callBacker as? UIImagePickerControllerDelegate) {
            x.imagePickerControllerDidCancel!(picker)
        }
        //picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }

    // MARK: - Refreshable Impl
    func refresh() {
        if let provider=objectToShow as? CellDataProvider{
            sections=provider.getDataSectionKeys()
            setCellData(provider.getAllData())
            lazyMainQueueDispatch({ () -> () in
                self.tableView.reloadData()
            })
        }
    }

}
