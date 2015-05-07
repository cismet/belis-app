//
//  SelectionPopoverViewController.swift
//  TaskIt
//
//  Created by Thorsten Hell on 09/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import UIKit

class SelectionPopoverViewController: UIViewController {

    var mainVC: MainViewController!;
    
    @IBOutlet weak var switchLeuchten: UISwitch!
    @IBOutlet weak var switchMauerlaschen: UISwitch!
    @IBOutlet weak var switchLeitungen: UISwitch!
    @IBOutlet weak var switchMasten: UISwitch!
    
    
    @IBAction func leuchtenSwitchToggled(sender: AnyObject) {

        mainVC.isLeuchtenEnabled=switchLeuchten.on
    }
    
    @IBAction func mastenSwitchToggled(sender: AnyObject) {
        mainVC.isMastenEnabled=switchMasten.on
    }
    
    @IBAction func mauerlaschenSwitchToggled(sender: AnyObject) {
        mainVC.isMauerlaschenEnabled=switchMauerlaschen.on
    }
    
    
    @IBAction func leitungenSwitchToggled(sender: AnyObject) {
        mainVC.isleitungenEnabled=switchLeitungen.on
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switchLeitungen.setOn(mainVC.isleitungenEnabled,animated:false)
        switchMauerlaschen.setOn(mainVC.isMauerlaschenEnabled,animated:false)
        switchLeuchten.setOn(mainVC.isLeuchtenEnabled,animated:false)
    }

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

}
