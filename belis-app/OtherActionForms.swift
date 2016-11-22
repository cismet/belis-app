//
//  OtherActionForms.swift
//  belis-app
//
//  Created by Thorsten Hell on 18.11.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import Foundation
import SwiftForms


class SonstigesAction : ObjectAction {
    override init(){
        super.init()
        title="Sonstiges"
    }
    enum PT:String {
        case BEMERKUNG
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Sonstiges"
        let section2 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        let row = FormRowDescriptor(tag: PT.BEMERKUNG.rawValue, type: .multilineText, title: "")
        section2.headerTitle = "Informationen zu den durchgeführten Tätigkeiten"
        section2.rows.append(row)
        form.sections = [section2]
        return form
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 160)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() 
            showWaiting()
            let apc=getParameterContainer()
            if let bemerkung=content[PT.BEMERKUNG.rawValue] {
                apc.append(PT.BEMERKUNG.rawValue, value: bemerkung)
                CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollFortfuehrungsantrag", params: apc, handler: defaultAfterSaveHandler)
            }
            else {
                showSuccess()
            }
        }
    }
}
class MauerlaschenPruefungAction : ObjectAction, UIImagePickerControllerDelegate, UINavigationControllerDelegate, Refreshable {
    enum PT:String {
        case PRUEFDATUM
        case DOKUMENT
    }
    var entity: Mauerlasche!
    var actions: [BaseEntityAction]=[]
    var callBacker: AnyObject?
    
    init(entity: Mauerlasche){
        super.init()
        title="Prüfung"
        self.entity=entity
        actions=[ChooseFotoAction(yourself: entity), TakeFotoAction(yourself: entity)]
    }
    
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Prüfung"
        let section2 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        var row = FormRowDescriptor(tag: PT.PRUEFDATUM.rawValue, type: .date, title: "Prüfdatum")
        row.value=Date() as AnyObject?
        
        section2.rows.append(row)
        row = FormRowDescriptor(tag: PT.DOKUMENT.rawValue, type: .booleanSwitch, title: "inkl. Foto")
        section2.rows.append(row)

        
        //vorher schon auskommentiert
//        row = FormRowDescriptor(tag: "", rowType: .Button, title: "Foto erstellen")
//        row.configuration[FormRowDescriptor.Configuration.DidSelectClosure] = {
//            super.formVC.view.endEditing(true)
//            
//            let picker = MainViewController.IMAGE_PICKER
//            picker.sourceType = UIImagePickerControllerSourceType.Camera
//            picker.delegate = self
//            self.callBacker=FotoPickerCallBacker(yourself: self.entity ,refreshable: self)
//            
//            picker.allowsEditing = true
//            //picker.showsCameraControls=true
//            picker.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
//            super.formVC.presentViewController(picker, animated: true, completion: { () -> Void in  })
//            
//            } as DidSelectClosure
//        section2.addRow(row)
//        row = FormRowDescriptor(tag: "", rowType: .Button, title: "Foto auswählen")
//        row.configuration[FormRowDescriptor.Configuration.DidSelectClosure] = {
//            super.formVC.view.endEditing(true)
//            
//            let picker = MainViewController.IMAGE_PICKER
//            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
//            picker.delegate = self
//            self.callBacker=FotoPickerCallBacker(yourself: self.entity ,refreshable: self)
//            
//            picker.allowsEditing = true
//            //picker.showsCameraControls=true
//            picker.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
//            super.formVC.presentViewController(picker, animated: true, completion: { () -> Void in  })
//            
//            } as DidSelectClosure
//        section2.addRow(row)
        form.sections = [section2]
        return form
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("DetailVC FINISH")
//        if let x = (callBacker as? UIImagePickerControllerDelegate) {
//            x.imagePickerController!(picker, didFinishPickingMediaWithInfo: info)
//        }
        //picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("DetailVC CANCEL")
//        if let x = (callBacker as? UIImagePickerControllerDelegate) {
//            x.imagePickerControllerDidCancel!(picker)
//        }
        //picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }
    
    func refresh() {
        print("refresh")
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 160)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() 
            showWaiting()
            let apc=getParameterContainer()
            let date=content[PT.PRUEFDATUM.rawValue]!
            let nowDouble = date.timeIntervalSince1970
            let millis = Int64(nowDouble!*1000) + Int64(nowDouble!/1000)
            let param = "\(millis)"
            apc.append(PT.PRUEFDATUM.rawValue, value: param as AnyObject)
            
            
//            if let mitFoto=content[PT.DOKUMENT.rawValue] as? Bool{
//                if mitFoto{
//                    let picker = MainViewController.IMAGE_PICKER
//                    picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//                    picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
//                    picker.delegate = self
//                    self.callBacker=FotoPickerCallBacker(yourself: self.entity ,refreshable: self)
//                    
//                    picker.allowsEditing = true
//                    //picker.showsCameraControls=true
//                    picker.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
//                    super.formVC.presentViewController(picker, animated: true, completion: { () -> Void in  })
//                }
//            }
            
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollMauerlaschePruefung", params: apc, handler: defaultAfterSaveHandler)
        }
    }
    
}
class SchaltstellenRevisionAction : ObjectAction {
    enum PT:String {
        case PRUEFDATUM
    }
    override init(){
        super.init()
        title="Revision"
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Revision"
        let section2 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        let row = FormRowDescriptor(tag: PT.PRUEFDATUM.rawValue, type: .date, title: "Prüfdatum")
        row.value=Date() as AnyObject?
        section2.rows.append(row)
        form.sections = [section2]
        return form
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 60)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() 
            showWaiting()
            let apc=getParameterContainer()
            let date=content[PT.PRUEFDATUM.rawValue]!
            let nowDouble = date.timeIntervalSince1970
            let millis = Int64(nowDouble!*1000) + Int64(nowDouble!/1000)
            let param = "\(millis)"
            apc.append(PT.PRUEFDATUM.rawValue, value: param as AnyObject)
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollSchaltstelleRevision", params: apc, handler: defaultAfterSaveHandler)
        }
    }
}


class ProtokollStatusUpdateAction : ObjectAction {
     var protokoll: Arbeitsprotokoll!
    enum PT:String {
        case MONTEUR
        case DATUM
        case STATUS
        case BEMERKUNG
        case MATERIAL
    }
    init(protokoll: Arbeitsprotokoll){
        super.init()
        self.protokoll=protokoll
        formVC.preSaveCheck=preSaveCheck
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Protokoll Details"
        let section0 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        section0.headerTitle = "Status"
        var row: FormRowDescriptor! = FormRowDescriptor(tag: PT.STATUS.rawValue, type: .segmentedControl, title: "")
        row.configuration.selection.options = CidsConnector.sharedInstance().sortedArbeitsprotokollStatusListKeys as [AnyObject]
        row.configuration.selection.optionTitleClosure = { value in
            let s=CidsConnector.sharedInstance().arbeitsprotokollStatusList[value as! String]
            return "\(s?.bezeichnung ?? "???")"
            }
        row.configuration.cell.appearance = ["segmentedControl.tintColor" : UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)]
        if let statid=protokoll.status?.id {
            row.value="\(statid)" as AnyObject?
        }
        section0.rows.append(row)
        
        let section1 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        row = FormRowDescriptor(tag: PT.MONTEUR.rawValue, type: .text, title: "Monteur")
        row.configuration.cell.appearance = ["textField.placeholder" : "Monteurname" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
        if let mont=protokoll.monteur {
            row.value=mont as AnyObject?
        } else {
            row.value=CidsConnector.sharedInstance().lastMonteur as AnyObject?
        }
        section1.rows.append(row)
        row = FormRowDescriptor(tag: PT.DATUM.rawValue, type: .date, title: "Datum")
        if let dat=protokoll.datum {
            row.value=dat as AnyObject?
        }
        else {
            row.value=Date() as AnyObject?
        }
        section1.rows.append(row)
        let section2 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        row = FormRowDescriptor(tag: PT.BEMERKUNG.rawValue, type: .multilineText, title: "")
        section2.headerTitle = "Bemerkung"
        row.value=protokoll.bemerkung as AnyObject?
        section2.rows.append(row)
        let section3 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        row = FormRowDescriptor(tag: PT.MATERIAL.rawValue, type: .multilineText, title: "")
        section3.headerTitle = "Material"
        section3.rows.append(row)
        row.value=protokoll.material as AnyObject?
        
        form.sections=[section1,section0,section2,section3]
        return form
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 460)
    }
    
    func preSaveCheck() -> CheckResult {
        let content = formVC.form.formValues()
        if (content[PT.MONTEUR.rawValue] as?  String) != nil {
            return CheckResult(passed: true)
        }
        else {
            return CheckResult(passed:false, title: "Monteur angeben", withMessage: "Bei einer Statusänderung muss der Namen des Monteurs angegeben werden.")
        }
    }
    
   
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues()
            
            let apc=getParameterContainer()
            //------------------
            if let mont=content[PT.MONTEUR.rawValue] as?  String {
                showWaiting()

                apc.append(PT.MONTEUR.rawValue, value: mont as AnyObject)
                CidsConnector.sharedInstance().lastMonteur=mont
                UserDefaults.standard.set(mont, forKey: "lastMonteur")
                //------------------
                let date=content[PT.DATUM.rawValue]!
                let nowDouble = date.timeIntervalSince1970
                let millis = Int64(nowDouble!*1000) + Int64(nowDouble!/1000)
                let param = "\(millis)"
                apc.append(PT.DATUM.rawValue, value: param as AnyObject)
                //------------------
                if let sid=content[PT.STATUS.rawValue]{
                    apc.append(PT.STATUS.rawValue, value: sid)
                }
                //------------------
                if let bem=content[PT.BEMERKUNG.rawValue] {
                    apc.append(PT.BEMERKUNG.rawValue, value: bem)
                }
                //------------------
                if let mat=content[PT.MATERIAL.rawValue] {
                    apc.append(PT.MATERIAL.rawValue, value: mat)
                }
                //------------------
                CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollStatusAenderung", params: apc, handler: defaultAfterSaveHandler)
            } 
        }
    }
}
