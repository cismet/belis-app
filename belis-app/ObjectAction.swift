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

open class ObjectAction: NSObject {
    let PROTOKOLL_ID="PROTOKOLL_ID"
    var arbeitsprotokoll_id = -1
    
    var title:String = ""
    var style: UIAlertActionStyle = UIAlertActionStyle.default
    var mainVC: UIViewController?
    var sender: UIView?
    var formVC: GenericFormViewController!
    
    override init() {
        super.init()
        formVC = CidsConnector.sharedInstance().mainVC!.storyboard!.instantiateViewController(withIdentifier: "formView") as! GenericFormViewController
        formVC.saveHandler=save
        formVC.cancelHandler=cancel
    }
    func handler(_ action: UIAlertAction) {
        if let senderView=sender {
            formVC.form=getFormDescriptor()
            let detailNC=UINavigationController(rootViewController: formVC)
            detailNC.isModalInPopover=true
            
            detailNC.modalPresentationStyle = UIModalPresentationStyle.popover
            detailNC.popoverPresentationController?.sourceView = senderView
            detailNC.popoverPresentationController?.sourceRect = senderView.bounds
            detailNC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.left
            detailNC.preferredContentSize = getPreferredSize()
            
            mainVC?.present(detailNC, animated: true, completion: nil)

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
   
    func defaultAfterSaveHandler(_ success: Bool){
        if !success {
            showError()
        }
        else {
            //refresh
            CidsConnector.sharedInstance().refreshArbeitsauftrag(CidsConnector.sharedInstance().selectedArbeitsauftrag, handler: { (success) -> () in
                if success {
                    lazyMainQueueDispatch({ () -> () in
                        CidsConnector.sharedInstance().mainVC?.tableView.reloadData()
                        self.showSuccess()
                    })
                }
            })
            
        }
    }
    
    func getParameterContainer()->ActionParameterContainer{
        return ActionParameterContainer(params: [PROTOKOLL_ID:"\(arbeitsprotokoll_id)" as AnyObject])
    }
    
    func showWaiting(){
        lazyMainQueueDispatch() {
            CidsConnector.sharedInstance().mainVC?.progressHUD?.show(in: CidsConnector.sharedInstance().mainVC!.view)
        }
    }
    func showError() {
        lazyMainQueueDispatch() {
            CidsConnector.sharedInstance().mainVC?.progressHUD?.dismiss(animated: false)
            let errorHUD=JGProgressHUD(style: JGProgressHUDStyle.dark)
            errorHUD?.indicatorView=JGProgressHUDErrorIndicatorView()
            errorHUD?.show(in: CidsConnector.sharedInstance().mainVC!.view, animated: false)
            errorHUD?.dismiss(afterDelay: TimeInterval(2), animated: true)
        }
    }
    func showSuccess() {
        lazyMainQueueDispatch(){
            CidsConnector.sharedInstance().mainVC?.progressHUD?.dismiss(animated: false)
            let successHUD=JGProgressHUD(style: JGProgressHUDStyle.dark)
            successHUD?.indicatorView=JGProgressHUDSuccessIndicatorView()
            successHUD?.show(in: CidsConnector.sharedInstance().mainVC!.view, animated: false)
            successHUD?.dismiss(afterDelay: TimeInterval(1), animated: true)
        }
    }
    
}
