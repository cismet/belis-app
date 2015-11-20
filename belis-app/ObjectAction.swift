//
//  ObjectActions.swift
//  belis-app
//
//  Created by Thorsten Hell on 18.11.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import Foundation
import SwiftForms
import JGProgressHUD

public class ObjectAction: NSObject {
    let PROTOKOLL_ID="PROTOKOLL_ID"
    var arbeitsprotokoll_id = -1
    
    var title:String = ""
    var style: UIAlertActionStyle = UIAlertActionStyle.Default
    var mainVC: UIViewController?
    var sender: UIView?
    var formVC: GenericFormViewController!
    
    override init() {
        super.init()
        formVC = CidsConnector.sharedInstance().mainVC!.storyboard!.instantiateViewControllerWithIdentifier("formView") as! GenericFormViewController
        formVC.saveHandler=save
        formVC.cancelHandler=cancel
    }
    func handler(action: UIAlertAction) {
        if let senderView=sender {
            formVC.form=getFormDescriptor()
            let detailNC=UINavigationController(rootViewController: formVC)
            detailNC.modalInPopover=true
            let popC=UIPopoverController(contentViewController: detailNC)
            popC.setPopoverContentSize(getPreferredSize(), animated: false)
            popC.presentPopoverFromRect(senderView.bounds, inView: senderView, permittedArrowDirections: .Left, animated: true)
        } else {
            assertionFailure("sender was Null, therefore Boom")
        }
        
    }
    
    func getFormDescriptor()->FormDescriptor {
        assertionFailure("getFormDescriptor Method not overridden in ObjectAction-SubClass")
        return FormDescriptor()
    }
    
    func save(){
        assertionFailure("save Method not overridden in ObjectAction-SubClass")

    }
    
    func cancel(){
        //no assertion Failure because sometimes it's better to just do nothing ;-)
    }
    
    func getPreferredSize()->CGSize {
        return CGSize(width: 400, height: 500)
    }
   
    func defaultAfterSaveHandler(success: Bool){
        if !success {
            showError()
        }
        else {
            //refresh
            CidsConnector.sharedInstance().refreshArbeitsauftrag(CidsConnector.sharedInstance().selectedArbeitsauftrag, handler: { (success) -> () in
                if success {
                    dispatch_async(dispatch_get_main_queue()) {
                        CidsConnector.sharedInstance().mainVC?.tableView.reloadData()
                        self.showSuccess()
                    }
                }
            })
            
        }
    }
    
    func getParameterContainer()->ActionParameterContainer{
        return ActionParameterContainer(params: [PROTOKOLL_ID:"\(arbeitsprotokoll_id)"])
    }
    
    func showWaiting(){
        lazyMainQueueDispatch() {
            CidsConnector.sharedInstance().mainVC?.progressHUD.showInView(CidsConnector.sharedInstance().mainVC!.view)
        }
    }
    func showError() {
        lazyMainQueueDispatch() {
            CidsConnector.sharedInstance().mainVC?.progressHUD.dismissAnimated(false)
            let errorHUD=JGProgressHUD(style: JGProgressHUDStyle.Dark)
            errorHUD.indicatorView=JGProgressHUDErrorIndicatorView()
            errorHUD.showInView(CidsConnector.sharedInstance().mainVC!.view, animated: false)
            errorHUD.dismissAfterDelay(NSTimeInterval(2), animated: true)
        }
    }
    func showSuccess() {
        lazyMainQueueDispatch(){
            CidsConnector.sharedInstance().mainVC?.progressHUD.dismissAnimated(false)
            let successHUD=JGProgressHUD(style: JGProgressHUDStyle.Dark)
            successHUD.indicatorView=JGProgressHUDSuccessIndicatorView()
            successHUD.showInView(CidsConnector.sharedInstance().mainVC!.view, animated: false)
            successHUD.dismissAfterDelay(NSTimeInterval(1), animated: true)
        }
    }
    
}
