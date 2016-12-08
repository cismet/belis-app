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
    var protokoll: Arbeitsprotokoll?
    var title:String = ""
    var style: UIAlertActionStyle = UIAlertActionStyle.default
    var mainVC: UIViewController?
    var sender: UIView?
    var formVC: GenericFormViewController!
    
    enum STATUSPT:String {
        case MONTEUR
        case DATUM
        case STATUS
    }
    
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
    
    func getStatusManagingSections() -> [FormSectionDescriptor] {
        
        let sectionStatus = FormSectionDescriptor(headerTitle: "Statusupdate", footerTitle: nil)
        sectionStatus.headerTitle = "Status"
        var row = FormRowDescriptor(tag: STATUSPT.STATUS.rawValue, type: .segmentedControl, title: "")
        var appearance: [String : AnyObject]=["segmentedControl.tintColor" : UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)]
        
        row.configuration.selection.options = CidsConnector.sharedInstance().sortedArbeitsprotokollStatusListKeys as [AnyObject]
        row.configuration.selection.optionTitleClosure = { value in
            let s=CidsConnector.sharedInstance().arbeitsprotokollStatusList[value as! String]
            return "\(s?.bezeichnung ?? "???")"
        }
        
        var idx=0
        if let statid=protokoll?.status?.id {
            row.value="\(statid)" as AnyObject
            idx = 0
            if let statusIndex=Int((protokoll?.status?.schluessel)!) {
                idx=statusIndex
            }
            else {
                idx = -1
            }
        }
        else {
            row.value="\(CidsConnector.sharedInstance().arbeitsprotokollStatusList[CidsConnector.sharedInstance().sortedArbeitsprotokollStatusListKeys[0]]!.id)" as AnyObject
        }
        if (idx != -1) {
            appearance["segmentedControl.selectedSegmentIndex"]=idx as AnyObject
        }
        
        row.configuration.cell.appearance = appearance
        sectionStatus.rows.append(row)
        
        let sectionStatus1 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        row = FormRowDescriptor(tag: STATUSPT.MONTEUR.rawValue, type: .text, title: "Monteur")
        row.configuration.cell.appearance = ["textField.placeholder" : "Monteurname" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
        if let mont=protokoll?.monteur {
            row.value=mont as AnyObject?
        } else {
            row.value=CidsConnector.sharedInstance().lastMonteur as AnyObject?
        }
        sectionStatus1.rows.append(row)
        row = FormRowDescriptor(tag: STATUSPT.DATUM.rawValue, type: .date, title: "Datum")
        
        // Hier wird jetzt immer das aktuelle Datum als Voreinstellung genommen
        row.value=Date() as AnyObject?
        
        sectionStatus1.rows.append(row)
        
        return [sectionStatus,sectionStatus1]


    }
    
    func saveStatus(apc:ActionParameterContainer) {
        let content = formVC.form.formValues()
        //STATUSÄnderung
        if let mont=content[STATUSPT.MONTEUR.rawValue] as?  String {
            apc.append(STATUSPT.MONTEUR.rawValue, value: mont as AnyObject)
            CidsConnector.sharedInstance().lastMonteur=mont
            UserDefaults.standard.set(mont, forKey: "lastMonteur")
        }
        //------------------
        let statusDate=content[STATUSPT.DATUM.rawValue]!
        let statusNowDouble = statusDate.timeIntervalSince1970
        let statusMillis = Int64(statusNowDouble!*1000) + Int64(statusNowDouble!/1000)
        let statusParam = "\(statusMillis)"
        apc.append(STATUSPT.DATUM.rawValue, value: statusParam as AnyObject)
        //------------------
        if let sid=content[STATUSPT.STATUS.rawValue]{
            apc.append(STATUSPT.STATUS.rawValue, value: sid)
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
