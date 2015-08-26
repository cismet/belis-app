//
//  ViewController.swift
//  BelIS
//
//  Created by Thorsten Hell on 01/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import UIKit
import QuartzCore
import ObjectMapper


class LoginViewController: UIViewController {
    
    @IBOutlet weak var txtLogin: UITextField!
    
    @IBOutlet weak var txtPass: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var storedLogin: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("login")
        if let storedUserString=storedLogin as? String {
            txtLogin.text=storedUserString
        }

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
    }
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    @IBAction func loginButtonTabbed(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(txtLogin.text, forKey: "login")
        let waiting = UIAlertController(title: "Anmeldung", message: "Sie werden am System angemeldet...", preferredStyle: UIAlertControllerStyle.Alert)
        self.presentViewController(waiting, animated: true, completion: nil)
        
        func loginhandler(success: Bool) {
            if (success) {
                let mainView = self.storyboard?.instantiateViewControllerWithIdentifier("mainView") as! MainViewController;
                dispatch_async(dispatch_get_main_queue(),{
                    waiting.dismissViewControllerAnimated(true, completion: {
                        self.presentViewController(mainView, animated: true, completion: {} );
                    })
                    
                })
                
            }
            else {
                dispatch_async(dispatch_get_main_queue(),{
                    self.txtPass.text="";
                    waiting.dismissViewControllerAnimated(true, completion: {
                        
                        var alert = UIAlertController(title: "Login fehlgeschlagen", message: "Oh, die Anmeldung hat nicht funktioniert. Probieren Sie es einfach nocheinmal.", preferredStyle: UIAlertControllerStyle.Alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (ACTION :UIAlertAction!)in
                        }))
                        
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        
                    })
                    
                })
                
                
            }
        }
        CidsConnector.sharedInstance().login(txtLogin.text, password: "wmbelis",handler: loginhandler)
        
    }
    
    @IBAction func moreButtonTabbed(sender: AnyObject) {

        
    }
    
    var queue=NSOperationQueue()
}
