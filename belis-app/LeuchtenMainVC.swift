//
//  LeuchtenMainVC.swift
//  belis-app
//
//  Created by Thorsten Hell on 27/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import UIKit

class LeuchtenMainVC: UIViewController , UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lblTest: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        // Do any additional setup after loading the view.
        tableView.registerNib(UINib(nibName: "SingleTitledInfoCell", bundle: nil), forCellReuseIdentifier: "singleTitled")
        tableView.registerNib(UINib(nibName: "MemoTitledInfoCell", bundle: nil), forCellReuseIdentifier: "memoTitled")
        tableView.registerClass(SimpleInfoCell.self, forCellReuseIdentifier: "simple")

    }
    
    var data: [String: [CellData]] = ["main":[]]
    
    var leuchte: Leuchte?
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    func setLeuchte(leuchte:Leuchte){
        self.leuchte=leuchte
        
        data["main"]?.append(SimpleInfoCellData(data: "Trilux Seilleuchte 58W"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Strasse", data: "Bredde"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Energielieferant", data: "WSW"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Schaltstelle", data: "L4N"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Montagefirma", data: "SAG"))
        data["main"]?.append(MemoTitledInfoCellData(title: "Bemerkung", data: "Damit Ihr indess erkennt, woher dieser ganze Irrthum gekommen ist, und weshalb man die Lust anklagt und den Schmerz lobet, so will ich Euch Alles eröffnen und auseinander setzen, was jener Begründer der Wahrheit und gleichsam Baumeister des glücklichen Lebens selbst darüber gesagt hat. Niemand, sagt er, verschmähe, oder hasse, oder fliehe die Lust als solche, sondern weil grosse Schmerzen ihr folgen, wenn man nicht mit Vernunft ihr nachzugehen verstehe. Ebenso werde der Schmerz als solcher von Niemand geliebt, gesucht und verlangt, sondern weil mitunter solche Zeiten eintreten, dass man mittelst Arbeiten und Schmerzen eine grosse Lust sich zu verschaften suchen müsse. Um hier gleich bei dem Einfachsten stehen zu bleiben, so würde Niemand von uns anstrengende körperliche Uebungen vornehmen, wenn er nicht einen Vortheil davon erwartete. Wer dürfte aber wohl Den tadeln, der nach einer Lust verlangt, welcher keine Unannehmlichkeit folgt, oder der einem Schmerze ausweicht, aus dem keine Lust hervorgeht?"))
    
        
        data["Dokumente"]=[]
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Skizze"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Bild nach Montage"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan 2"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan 3"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan 4"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan 5"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan 6"))
        
    }
    
    
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
            return 10
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return data.keys.array.count
    }
    
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        
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
