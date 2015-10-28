//
//  AdditionalFunctionalityPopoverViewController.swift
//  belis-app
//
//  Created by Thorsten Hell on 26.10.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import UIKit

class AdditionalFunctionalityPopoverViewController: UIViewController {

    var mainVC: MainViewController!;

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
