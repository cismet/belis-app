//
//  AdditionalFunctionalityPopoverViewController.swift
//  belis-app
//
//  Created by Thorsten Hell on 26.10.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import UIKit
import SwiftForms

class AdditionalFunctionalityPopoverViewController: UIViewController {

    var mainVC: MainViewController!;

    @IBOutlet weak var teamChooserButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutButtonTabbed(sender: AnyObject) {
        if let lvc=mainVC.loginViewController {
            self.dismissViewControllerAnimated(true, completion: {
                self.mainVC.dismissViewControllerAnimated(true, completion: {
                    lvc.txtPass.text=""
                })
                
            })

        }
    }

    @IBAction func chooseTeamTapped(sender: AnyObject) {    
        self.dismissViewControllerAnimated(true) { () -> Void in
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            for teamKey in CidsConnector.sharedInstance().sortedTeamListKeys {
                let team=CidsConnector.sharedInstance().teamList[teamKey]!
                alertController.addAction(UIAlertAction(title:team.name ?? "-", style: .Default, handler: {
                    (alert: UIAlertAction) -> Void in
                    CidsConnector.sharedInstance().selectedTeam=team
                    NSUserDefaults.standardUserDefaults().setObject("\(team.id)", forKey: "teamid")
                    CidsConnector.sharedInstance().mainVC?.clearAll()
                    CidsConnector.sharedInstance().mainVC?.itemArbeitsauftrag.title="Kein Arbeitsauftrag ausgewählt (\(CidsConnector.sharedInstance().selectedTeam?.name ?? "-"))"
                }))
                
            }
            //alertController.modalPresentationStyle = UIModalPresentationStyle.Popover
//            let popover = alertController.popoverPresentationController!
//            popover.permittedArrowDirections = .Left
//            popover.sourceView = self.teamChooserButton
//            popover.sourceRect = self.teamChooserButton.bounds
            self.mainVC.presentViewController(alertController, animated: true, completion: nil)
        }
        

    
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

