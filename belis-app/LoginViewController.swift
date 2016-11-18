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

    // MARK: Outlets
    @IBOutlet weak var txtLogin: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    
    // MARK: - Default functions
    override func viewDidLoad() {
        super.viewDidLoad()
        let storedLogin: AnyObject? = UserDefaults.standard.object(forKey: "login") as AnyObject?
        if let storedUserString=storedLogin as? String {
            txtLogin.text=storedUserString
        }
        
        let storedTeam: AnyObject? = UserDefaults.standard.object(forKey: "teamid") as AnyObject?
        if let st = storedTeam as? String {
            CidsConnector.sharedInstance().selectedTeamId=st
        }
        
        let storedMonteur: AnyObject? = UserDefaults.standard.object(forKey: "lastMonteur") as AnyObject?
        if let storedMonteurString=storedMonteur as? String {
            CidsConnector.sharedInstance().lastMonteur=storedMonteurString
        }

        // Do any additional setup after loading the view, typically from a nib.
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    }
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBActions
    @IBAction func loginButtonTabbed(_ sender: AnyObject) {
        UserDefaults.standard.set(txtLogin.text!, forKey: "login")
        
        let waiting = UIAlertController(title: "Anmeldung", message: "Sie werden am System angemeldet ...", preferredStyle: UIAlertControllerStyle.alert)
        self.present(waiting, animated: true, completion: nil)
        
        func loginhandler(_ success: Bool) {
            if (success) {
                let mainView = self.storyboard?.instantiateViewController(withIdentifier: "mainView") as! MainViewController;
                mainView.loginViewController=self
                lazyMainQueueDispatch({ () -> () in
                    waiting.dismiss(animated: true, completion: {
                        self.present(mainView, animated: true, completion: {} );
                    })
                })
                
            }
            else {
                lazyMainQueueDispatch({ () -> () in
                    self.txtPass.text="";
                    waiting.dismiss(animated: true, completion: {
                        
                        let alert = UIAlertController(title: "Login fehlgeschlagen", message: "Oh, die Anmeldung hat nicht funktioniert. Probieren Sie es einfach nocheinmal.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (ACTION :UIAlertAction)in
                        }))
                        
                        self.present(alert, animated: true, completion: nil)
                        
                        
                    })
                    
                })
                
                
            }
        }
        if let pass=txtPass.text {
            if pass.length>0 {
                CidsConnector.sharedInstance().login(txtLogin.text!, password: pass,handler: loginhandler)
            }
            else {
                CidsConnector.sharedInstance().login(txtLogin.text!, password: "devdb",handler: loginhandler)
            }
        }
    
    }
}
