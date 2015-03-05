//
//  DokumentPreviewVC.swift
//  belis-app
//
//  Created by Thorsten Hell on 03/03/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import UIKit
 
class DokumentPreviewVC: UIViewController , UIWebViewDelegate {

    var nsUrlToLoad: NSURL?
    var urlToLoad: String?
    
    @IBOutlet weak var webview: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
//        var b = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action:"someAction")
//        var a = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: self, action: "showInFullscreen")
////        self.navigationItem.rightBarButtonItem = b
//        self.navigationItem.setRightBarButtonItems([a,b], animated: true)
        
        webview.scalesPageToFit=true
        webview.contentMode=UIViewContentMode.ScaleAspectFit
        webview.delegate=self
        
        if let nsu=nsUrlToLoad {
            urlToLoad=nsu.absoluteString
            loadUrl(nsu)
            
        }
        else if let url=urlToLoad{
            if let nsu=NSURL(string: url){
                nsUrlToLoad=nsu
                loadUrl(nsu)
            }
        }

 
        // Do any additional setup after loading the view.
    }
    func showInFullscreen() {

//        self.navigationController?.popViewControllerAnimated(false)
//        self.navigationController?.
//        self.navigationController?.pushViewController(self, animated: true)
//        

//        UIApplication.sharedApplication().openURL(nsUrlToLoad!)

    }
    
    
    func someAction() {
        // 1
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .ActionSheet)
        
        // 2
        let deleteAction = UIAlertAction(title: "Delete", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("File Deleted")
        })
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("File Saved")
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            println("Cancelled")
        })
        
        
        // 4
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(cancelAction)
        
        // 5
        self.presentViewController(optionMenu, animated: true, completion: nil)
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
    
    func loadUrl(url: NSURL){
        var request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 100)
       
        let loginString = NSString(format: "%@", Secrets.getWebDavAuthString())
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions(nil)
//        var defaultCredentials: NSURLCredential = NSURLCredential(user: login, password: password, persistence: NSURLCredentialPersistence.ForSession);
        
     //   request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        NSURLConnection(request: request, delegate: self)

        webview.loadRequest(request)

    }
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        var headerIsPresent = request.allHTTPHeaderFields
        
        return true
    }
    func webViewDidStartLoad(webView: UIWebView) {
        println("start")
        
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        println("finished")
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
            println("Failed with error:\(error.localizedDescription)")
    }

    
    
}
