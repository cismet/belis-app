//
//  DokumenteVC.swift
//  belis-app
//
//  Created by Thorsten Hell on 25/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import UIKit
import QuickLook

class DokumenteVC: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var dmsUrls: [DMSUrl]=[]
    
    @IBOutlet weak var documentTV: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        documentTV.delegate=self
        documentTV.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        
        
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

    
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dmsUrls.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        let row=indexPath.row
        let dmsUrl=dmsUrls[row]

        cell.textLabel!.text=dmsUrl.getTitle()
        cell.accessoryType=UITableViewCellAccessoryType.DisclosureIndicator
        
        
        return cell
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
//        let previewVC=DokumentPreviewVC(nibName: "DokumentPreviewVC", bundle: nil)
//        previewVC.url="file:///Users/thorsten/Desktop/b.pdf"
//        self.navigationController?.pushViewController(previewVC, animated: true)
      
        //self.previewC.currentPreviewItemIndex=indexPath.row

        //navigationController?.tabBarController?.preferredContentSize=CGSizeMake(500,700)

        //navigationController?.pushViewController(previewC, animated: true)
        
        //Fullscreen
        //self.presentViewController(previewC, animated: true, completion: nil)
             
       
        let previewVC=DokumentPreviewVC(nibName: "DokumentPreviewVC", bundle: nil)
        
//        
//        var webView = UIWebView(frame: CGRectMake(10, 10, 100, 100))
//        var wvController=UIViewController()
//        let u = urls[indexPath.row]
//        
//
//        var request = NSURLRequest(URL: u!)
//
//        webView.scalesPageToFit=true
//
//        webView.contentMode=UIViewContentMode.ScaleAspectFit
//        
//        
//        
//        var w=CGFloat(200.0)
//        
//        webView.frame = CGRectMake(0, 0, 100, 100)
//        webView.loadRequest(request)
//
//
//        wvController.view = webView
//        navigationController?.pushViewController(wvController, animated: true)
        let row=indexPath.row
        let dmsUrl=dmsUrls[row]
        println(dmsUrl.getUrl())
        previewVC.nsUrlToLoad=NSURL(string: dmsUrl.getUrl())
        navigationController?.pushViewController(previewVC, animated: true)
      


    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    

        
    
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if (section==0){
//            return "Leuchten \(searchResults[LEUCHTEN].count)";
//        }
//        else if (section==1){
//            return "Mauerlaschen \(searchResults[MAUERLASCHEN].count)";
//        }else
//        {
//            return "Leitungen \(searchResults[LEITUNGEN].count)";
//        }
//    }


}


struct SessionProperties {
    static let identifier : String! = "url_session_background_download"
}