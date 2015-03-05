//
//  LeitungenVC.swift
//  belis-app
//
//  Created by Thorsten Hell on 25/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import UIKit

class LeitungenVC: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMaterial: UILabel!  
    @IBOutlet weak var lblQuerschnitt: UILabel!
    
    var leitung :Leitung?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblTitle.text=leitung?.leitungstyp?.bezeichnung ?? "Leitung"
        if let a = leitung?.querschnitt?.groesse? {
           // if let a = leitung?.id {
            lblQuerschnitt.text = "\(a)mm²"
        }
        else {
            lblQuerschnitt.text = "-"
        }

        lblMaterial.text=leitung?.material?.bezeichnung? ?? "-"
        // Do any additional setup after loading the view.
        
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
