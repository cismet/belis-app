//
//  LeuchteActionForms.swift
//  belis-app
//
//  Created by Thorsten Hell on 12.11.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import Foundation
import SwiftForms

//                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//                alertController.addAction(UIAlertAction(title: "Leuchtenerneuerung", style: .Default, handler: { alertAction in
//                    // Handle Take Photo here
//                }))
//                alertController.addAction(UIAlertAction(title: "Leuchtmittelwechsel (mit EP)", style: .Default, handler: { alertAction in
//                    // Handle Choose Existing Photo
//                }))
//                alertController.addAction(UIAlertAction(title: "Leuchtmittelwechsel", style: .Default, handler: { alertAction in
//                    // Handle Choose Existing Photo
//                }))
//                alertController.addAction(UIAlertAction(title: "Rundsteuerempfängerwechsel", style: .Default, handler: { alertAction in
//                    // Handle Choose Existing Photo
//                }))
//                alertController.addAction(UIAlertAction(title: "Sonderturnus", style: .Default, handler: { alertAction in
//                    // Handle Choose Existing Photo
//                }))
//                alertController.addAction(UIAlertAction(title: "Vorschaltgerätwechsel", style: .Default, handler: { alertAction in
//                    // Handle Choose Existing Photo
//                }))
//                alertController.addAction(UIAlertAction(title: "Sonstiges", style: .Default, handler: { alertAction in
//                    if let formVC = mainVC.storyboard?.instantiateViewControllerWithIdentifier("formView") as? GenericFormViewController {
//                        let form = FormDescriptor()
//                        form.title = "Sonstiges"
//
//                        let section2 = FormSectionDescriptor()
//                        let row = FormRowDescriptor(tag: "bemerkung", rowType: .MultilineText, title: "")
//                        section2.headerTitle = "Informationen zu den durchgeführten Tätigkeiten"
//                        section2.addRow(row)
//                        form.sections = [section2]
//                        formVC.form=form
//
//                        let detailNC=UINavigationController(rootViewController: formVC)
//                        detailNC.modalInPopover=true
//                        let popC=UIPopoverController(contentViewController: detailNC)
//                        popC.setPopoverContentSize(CGSize(width: 500, height: 200), animated: false)
//                        popC.presentPopoverFromRect(sender.bounds, inView: sender, permittedArrowDirections: .Left, animated: true)
//                    }
//                }))




class LeuchtenerneuerungAction : ObjectAction {
    override init(){
        super.init()
        title="Leuchtenerneuerung"
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

class LeuchtmittelwechselEPAction : ObjectAction {
    override init(){
        super.init()
        title="Leuchtmittelwechsel (mit EP)"
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
class LeuchtmittelwechselAction : ObjectAction {
    override init(){
        super.init()
        title="Leuchtmittelwechsel"
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
class RundsteuerempfaengerwechselAction : ObjectAction {
    override init(){
        super.init()
        title="Rundsteuerempfängerwechsel"
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
class SonderturnusAction : ObjectAction {
    override init(){
        super.init()
        title="Sonderturnus"
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
class VorschaltgeraetwechselAction : ObjectAction {
    override init(){
        super.init()
        title="Vorschaltgerätwechsel"
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