//
//  ObjectActions.swift
//  belis-app
//
//  Created by Thorsten Hell on 18.11.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import Foundation
import SwiftForms

 class ObjectAction: NSObject {
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
    
    
   
}


class SonstigesAction : ObjectAction {
    override init(){
        super.init()
        title="Sonstiges"
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Sonstiges"
        let section2 = FormSectionDescriptor()
        let row = FormRowDescriptor(tag: "bemerkung", rowType: .MultilineText, title: "")
        section2.headerTitle = "Informationen zu den durchgeführten Tätigkeiten"
        section2.addRow(row)
        form.sections = [section2]
        return form

    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 200)
    }
    
    override func save(){
        print("HELL SAVE")
        
    }
    
    override func cancel(){
        print("HELL CANCEL")
    }
    
}