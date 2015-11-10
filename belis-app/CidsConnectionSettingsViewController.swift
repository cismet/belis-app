//
//  CidsConnectionSettingsViewController.swift
//  belis-app
//
//  Created by Thorsten Hell on 31/08/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import UIKit

class CidsConnectionSettingsViewController: UIViewController {
    
    @IBOutlet weak var serverCertIconLabel: UILabel!
    @IBOutlet weak var clientCertIconLabel: UILabel!
    @IBOutlet weak var serverCertTextLabel: UILabel!
    @IBOutlet weak var clientCertTextLabel: UILabel!
    @IBOutlet weak var cmdServerCertRemove: UIButton!
    @IBOutlet weak var cmdClientCertRemove: UIButton!
    @IBOutlet weak var chkTLS: UISwitch!
    @IBOutlet weak var certPassTextField: UITextField!
    @IBOutlet weak var txtServerURL: UITextField!
    
    let gray=UIColor.grayColor()
    let black=UIColor.blackColor()
    let green=UIColor(red: 0.568, green: 0.91, blue: 0.486, alpha: 1.0)
    let orange=UIColor(red: 250/255, green: 105/255, blue: 0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGlyphLabel(serverCertIconLabel, glyphName: "icon-certificatealt")
        setGlyphLabel(clientCertIconLabel, glyphName: "icon-certificatealt")
        clientCertIconLabel.textColor=gray
        serverCertIconLabel.textColor=orange
        clientCertTextLabel.textColor=green
        certPassTextField.text=CidsConnector.sharedInstance().clientCertContainerPass
        txtServerURL.text=CidsConnector.sharedInstance().pureBaseUrl
        chkTLS.on=CidsConnector.sharedInstance().tlsEnabled
        if (chkTLS.on && CidsConnector.sharedInstance().baseUrlport=="443")||(chkTLS.on==false && CidsConnector.sharedInstance().baseUrlport=="80"){
            txtServerURL.text=CidsConnector.sharedInstance().pureBaseUrl
        }
        else {
            txtServerURL.text="\(CidsConnector.sharedInstance().pureBaseUrl):\(CidsConnector.sharedInstance().baseUrlport)"
        }
        checkAndColor()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkAndColor() {
        if CidsConnector.sharedInstance().serverCertPath != "" {
            serverCertIconLabel.textColor=black
            serverCertTextLabel.textColor=black
            serverCertTextLabel.text="Serverzertifikat"
            cmdServerCertRemove.hidden=false
            chkTLS.enabled=true
            
        }
        else {
            serverCertIconLabel.textColor=gray
            serverCertTextLabel.textColor=gray
            serverCertTextLabel.text="kein Serverzertifikat"
            cmdServerCertRemove.hidden=true
            chkTLS.enabled=false
            chkTLS.on=false
            
        }
        if CidsConnector.sharedInstance().clientCertPath != "" {
            clientCertIconLabel.textColor=black
            clientCertTextLabel.textColor=black
            clientCertTextLabel.text="Clientzertifikat"
            cmdClientCertRemove.hidden=false
        }
        else {
            clientCertIconLabel.textColor=gray
            clientCertTextLabel.textColor=gray
            clientCertTextLabel.text="kein Clientzertifikat"
            cmdClientCertRemove.hidden=true
        }
        
        
    }
    
    @IBAction func checkTabbed(sender: AnyObject) {
        let serverCertData = NSData(contentsOfFile: CidsConnector.sharedInstance().serverCertPath)
        let clientCertData = NSData(contentsOfFile: CidsConnector.sharedInstance().clientCertPath)
        
        print("ServerCert: \(CidsConnector.sharedInstance().serverCertPath) \(serverCertData)")
        print("ClientCert: \(CidsConnector.sharedInstance().clientCertPath) \(clientCertData)")

        

        print("connect to: \(CidsConnector.sharedInstance().baseUrl)")

        
        
    }
    @IBAction func passwordChanged(sender: AnyObject) {
        CidsConnector.sharedInstance().clientCertContainerPass=certPassTextField.text!
        checkAndColor()
    }
    @IBAction func tlsEnabledChanged(sender: AnyObject) {
        serverUrlChanged(sender)
    }
    @IBAction func serverUrlChanged(sender: AnyObject) {
        var defaultport="80"
        if chkTLS.on {
            defaultport="443"
        }
        if txtServerURL.text!.contains(":") {
            var urlAndPort = txtServerURL.text!.characters.split {$0 == ":"}.map { String($0) }
            let url=urlAndPort[0]
            CidsConnector.sharedInstance().pureBaseUrl=url
            if urlAndPort.count>1 {
                CidsConnector.sharedInstance().baseUrlport=urlAndPort[1]
            }
            else {
                CidsConnector.sharedInstance().baseUrlport=defaultport
            }
        }
        else {
            CidsConnector.sharedInstance().pureBaseUrl=txtServerURL.text!
            CidsConnector.sharedInstance().baseUrlport=defaultport
        }
        CidsConnector.sharedInstance().tlsEnabled=chkTLS.on
    }
    @IBAction func removeServerCertTabbed(sender: AnyObject) {
        
        var error:NSError?
        let ok:Bool
        do {
            try NSFileManager().removeItemAtPath(CidsConnector.sharedInstance().serverCertPath)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        if error != nil {
            print(error)
        }
        if (ok) {
            CidsConnector.sharedInstance().serverCert=nil
        }
        checkAndColor()
    }
    @IBAction func removeClientCertTabbed(sender: AnyObject) {
        var error:NSError?
        let ok:Bool
        do {
            try NSFileManager().removeItemAtPath(CidsConnector.sharedInstance().clientCertPath)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        if error != nil {
            print(error)
        }
        if (ok) {
            CidsConnector.sharedInstance().clientCert=nil
        }
        checkAndColor()
        
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    
    func setGlyphLabel(label: UILabel, glyphName: String) {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {
            label.font = UIFont(name: "WebHostingHub-Glyphs", size: 20)
            label.textAlignment=NSTextAlignment.Center
            label.text=glyph
            label.sizeToFit()
        }
    }
    
}
