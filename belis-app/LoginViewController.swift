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
        
        
        
        
        setBackground();
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
    }
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        setBackground();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setBackground() {
        //        var background:CAGradientLayer = CAGradientLayer();
        //        background.frame = view.bounds
        //        let cor1 = UIColor.blackColor().CGColor
        //        let cor2 = UIColor.whiteColor().CGColor
        //        let arrayColors = [cor1, cor2]
        //        background.colors = arrayColors
        //        view.layer.insertSublayer(background, atIndex: 0)
        //        println(view.layer.sublayers)
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
        
        //        CidsConnector.sharedInstance().login(txtLogin.text, password: txtPass.text,handler: loginhandler)
        CidsConnector.sharedInstance().login(txtLogin.text, password: "wmbelis",handler: loginhandler)
        
    }
    
    @IBAction func moreButtonTabbed(sender: AnyObject) {
        //        func completionHandler(operation:GetEntityOperation, data: NSData!, response: NSURLResponse!, error: NSError!, queue: NSOperationQueue) -> (){
        //            if (error == nil) {
        //                // Success
        //                let statusCode = (response as! NSHTTPURLResponse).statusCode
        //                println("URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
        //                var err: NSError?
        //                if let json: [String : AnyObject]=NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err) as? [String: AnyObject] {
        //
        //                    var l = Mapper<Leitung>().map(json)!
        //                    println(l.wgs84WKT)
        //                }else {
        //                    println("no json data for \(operation.url)")
        //                    //self.searchResults[0].append(Leuchte())
        //
        //                }
        //            }else {
        //                // Failure
        //                println("URL Session Task Failed: %@", error.localizedDescription);
        //            }
        //        }
        //        var op=GetEntityOperation(baseUrl: "https://localhost:8890", domain: "BELIS2", entityName: "LEITUNG", id: 11439, user: "WendlingM@BELIS2", pass: "wmbelis", queue: queue, completionHandler: completionHandler)
        //        queue.addOperation(op)
        
        //
        //        var paramString="{\"parameters\":{\"OBJEKT_ID\":\"6605\",\"OBJEKT_TYP\":\"mauerlasche\",\"DOKUMENT_URL\":\"http://board.cismet.de/belis/iostestupload1436853189014.png\ncismettest-ignore\"}}"
        //        var params=Mapper<ActionParameterContainer>().map(paramString)!
        //
        
        //        let params=ActionParameterContainer(params: [   "OBJEKT_ID":"6605",
        //            "OBJEKT_TYP":"mauerlasche",
        //            "DOKUMENT_URL":"http://board.cismet.de/belis/iostestupload1436853189014.png\ncismettest-ignore112"])
        //        var op=ServerActionOperation(baseUrl: "https://localhost:8890", user: "WendlingM@BELIS2", pass: "wmbelis", actionName: "AddDokument",params:params)
        //        op.enqueue()
        var image=UIImage(named: "testbild.png")
        
        var thumb = image!.resizeToWidth(100.0)
        
        
        var op=WebDavUploadImageOperation(baseUrl: "http://board.cismet.de/belis", user: Secrets.getWebDavUser(), pass: Secrets.getWebDavPass(), fileName: "uploadTestomat.jpg", image:image!) {
            (data, response, error) -> Void in
            
            
            
        }
        op.enqueue()
        
    }
    
    var queue=NSOperationQueue()
}
