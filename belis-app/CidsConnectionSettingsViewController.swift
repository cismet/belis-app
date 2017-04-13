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
    
    let gray=UIColor.gray
    let black=UIColor.black
    let green=UIColor(red: 0.568, green: 0.91, blue: 0.486, alpha: 1.0)
    let orange=UIColor(red: 250/255, green: 105/255, blue: 0, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GlyphTools.sharedInstance().setGlyphLabel(serverCertIconLabel, glyphName: "icon-certificatealt")
        GlyphTools.sharedInstance().setGlyphLabel(clientCertIconLabel, glyphName: "icon-certificatealt")
        clientCertIconLabel.textColor=gray
        serverCertIconLabel.textColor=orange
        clientCertTextLabel.textColor=green
        certPassTextField.text=CidsConnector.sharedInstance().clientCertContainerPass
        txtServerURL.text=CidsConnector.sharedInstance().pureBaseUrl
        chkTLS.isOn=CidsConnector.sharedInstance().tlsEnabled
        if (chkTLS.isOn && CidsConnector.sharedInstance().baseUrlport=="443")||(chkTLS.isOn==false && CidsConnector.sharedInstance().baseUrlport=="80"){
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
            cmdServerCertRemove.isHidden=false
            chkTLS.isEnabled=true
            
        }
        else {
            serverCertIconLabel.textColor=gray
            serverCertTextLabel.textColor=gray
            serverCertTextLabel.text="kein Serverzertifikat"
            cmdServerCertRemove.isHidden=true
            chkTLS.isEnabled=false
            chkTLS.isOn=false
            
        }
        if CidsConnector.sharedInstance().clientCertPath != "" {
            clientCertIconLabel.textColor=black
            clientCertTextLabel.textColor=black
            clientCertTextLabel.text="Clientzertifikat"
            cmdClientCertRemove.isHidden=false
        }
        else {
            clientCertIconLabel.textColor=gray
            clientCertTextLabel.textColor=gray
            clientCertTextLabel.text="kein Clientzertifikat"
            cmdClientCertRemove.isHidden=true
        }
        
        
    }
    
    @IBAction func checkTabbed(_ sender: AnyObject) {
        let serverCertData = try? Data(contentsOf: URL(fileURLWithPath: CidsConnector.sharedInstance().serverCertPath))
        let clientCertData = try? Data(contentsOf: URL(fileURLWithPath: CidsConnector.sharedInstance().clientCertPath))
        
        log.info("ServerCert: \(CidsConnector.sharedInstance().serverCertPath) \(String(describing: serverCertData))")
        log.info("ClientCert: \(CidsConnector.sharedInstance().clientCertPath) \(String(describing: clientCertData))")
        log.info("connect to: \(CidsConnector.sharedInstance().baseUrl)")
    }
    @IBAction func passwordChanged(_ sender: AnyObject) {
        CidsConnector.sharedInstance().clientCertContainerPass=certPassTextField.text!
        checkAndColor()
    }
    @IBAction func tlsEnabledChanged(_ sender: AnyObject) {
        serverUrlChanged(sender)
    }
    @IBAction func serverUrlChanged(_ sender: AnyObject) {
        var defaultport="80"
        if chkTLS.isOn {
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
        CidsConnector.sharedInstance().tlsEnabled=chkTLS.isOn
    }
    @IBAction func removeServerCertTabbed(_ sender: AnyObject) {
        
        var error:NSError?
        let ok:Bool
        do {
            try FileManager().removeItem(atPath: CidsConnector.sharedInstance().serverCertPath)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        if error != nil {
            log.error(error ?? "no detailed errormessage available")
        }
        if (ok) {
            CidsConnector.sharedInstance().serverCert=nil
        }
        checkAndColor()
    }
    @IBAction func removeClientCertTabbed(_ sender: AnyObject) {
        var error:NSError?
        let ok:Bool
        do {
            try FileManager().removeItem(atPath: CidsConnector.sharedInstance().clientCertPath)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        if error != nil {
            log.error(error ?? "no detailed error message available")
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
    
}
