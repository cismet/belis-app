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
            (alert: UIAlertAction) -> Void in
            print("File Deleted")
        })
        let saveAction = UIAlertAction(title: "Save", style: .Default, handler: {
            (alert: UIAlertAction) -> Void in
            print("File Saved")
        })
        
        //
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction) -> Void in
            print("Cancelled")
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
        
        if url.path!.endsWith(".jpg", caseSensitive: false) || url.path!.endsWith(".png", caseSensitive: false) {
            var imageUrl="http://\(Secrets.getWebDavAuthString())@\(url.host!)\(url.path!)"
            //        imageUrl=test
            if imageUrl.endsWith(".jpg", caseSensitive: false) {
                imageUrl=imageUrl+".thumbnail.jpg"
            }
            if imageUrl.endsWith(".png", caseSensitive: false) {
                imageUrl=imageUrl+".thumbnail.png"
            }
            let body="<html><body><center><img src='\(imageUrl)' width='950'></center></body></html>"
            print(body)
            //NSURLConnection(request: request, delegate: self)
            webview.loadHTMLString(body, baseURL: nil)
        }
        else {
            let request = NSMutableURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 100)

        let loginString = NSString(format: "%@", Secrets.getWebDavAuthString())
        let loginData: NSData = loginString.dataUsingEncoding(NSUTF8StringEncoding)!
        let base64LoginString = loginData.base64EncodedStringWithOptions([])
//        var defaultCredentials: NSURLCredential = NSURLCredential(user: login, password: password, persistence: NSURLCredentialPersistence.ForSession);
        
       request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
            //NSURLConnection(request: request, delegate: self)
            webview.loadRequest(request)
        }
    }
    
//    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
////        var headerIsPresent = request.allHTTPHeaderFields
//        
//        return true
//    }
    func webViewDidStartLoad(webView: UIWebView) {
        print("start")
        
    }
    func webViewDidFinishLoad(webView: UIWebView) {
        print("finished")
    }
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        if let err=error {
        print("Failed with error:\(err.localizedDescription)")
        }
    }

    
    
}
//
//struct SessionProperties {
//    static let identifier : String! = "url_session_background_download"
//}