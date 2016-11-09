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
        tableView.register(UINib(nibName: "SingleTitledInfoCell", bundle: nil), forCellReuseIdentifier: "singleTitled")
        tableView.register(UINib(nibName: "DoubleTitledInfoCell", bundle: nil), forCellReuseIdentifier: "doubleTitled")
        tableView.register(UINib(nibName: "MemoTitledInfoCell", bundle: nil), forCellReuseIdentifier: "memoTitled")
        tableView.register(SimpleInfoCell.self, forCellReuseIdentifier: "simple")
        tableView.register(SimpleUrlPreviewInfoCell.self, forCellReuseIdentifier: "simpleUrl")
        tableView.rowHeight=UITableViewAutomaticDimension
    }
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setCellData(_ data:[String: [CellData]]){
        self.data=data
    }
    
    func moreAction() {
        
        if actions.count>0 {
            let optionMenu = UIAlertController(title: nil, message: "Aktion auswählen", preferredStyle: UIAlertControllerStyle.actionSheet)
            
            for action in actions {
                let alertAction = UIAlertAction(title: action.title, style: action.style, handler: {
                    (alert: UIAlertAction) -> Void in
                        print("Aktion: "+action.title)
                        action.handler(alert, action, self.objectToShow,self)
                    
                    
                })
                optionMenu.addAction(alertAction)
            }
            
            self.present(optionMenu, animated: true, completion: nil)
        }
        
    }
    
    func doIt (_ alert: UIAlertAction!) {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey: String = sections[section]
        return data[sectionKey]?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row=(indexPath as NSIndexPath).row
        let section = (indexPath as NSIndexPath).section
        let sectionKey: String = sections[section]
        let dataItem: CellData = data[sectionKey]![row]
        let cellReuseId=dataItem.getCellReuseIdentifier()
        let cell: UITableViewCell  = tableView.dequeueReusableCell(withIdentifier: cellReuseId)! as UITableViewCell
        if let filler = cell as? CellDataUI {
            filler.fillFromCellData(dataItem)
        }
        else {
            print("NO CELLDATAUI")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let row=(indexPath as NSIndexPath).row
        let section = (indexPath as NSIndexPath).section
        let sectionKey: String = sections[section]
        let dataItem: CellData = data[sectionKey]![row]
        let cellReuseId=dataItem.getCellReuseIdentifier()
        let cell: UITableViewCell  = tableView.dequeueReusableCell(withIdentifier: cellReuseId)! as UITableViewCell
        if let heightProvider = cell as? CellDataUI {
            return heightProvider.getPreferredCellHeight()
        }
        return 44
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let row=(indexPath as NSIndexPath).row
        let section = (indexPath as NSIndexPath).section
        let sectionKey: String = sections[section]
        let dataItem: CellData = data[sectionKey]![row]
        if let actionProvider = dataItem as? SimpleCellActionProvider {
            actionProvider.action(self)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    // MARK: UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("DetailVC FINISH")
        if let x = (callBacker as? UIImagePickerControllerDelegate) {
            x.imagePickerController!(picker, didFinishPickingMediaWithInfo: info)
        }
        //picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
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
