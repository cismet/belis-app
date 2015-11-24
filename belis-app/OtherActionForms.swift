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
        let section2 = FormSectionDescriptor()
        let row = FormRowDescriptor(tag: PT.BEMERKUNG.rawValue, rowType: .MultilineText, title: "")
        section2.headerTitle = "Informationen zu den durchgeführten Tätigkeiten"
        section2.addRow(row)
        form.sections = [section2]
        return form
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 200)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() as!  [String : AnyObject]
            showWaiting()
            let apc=getParameterContainer()
            apc.append(PT.BEMERKUNG.rawValue, value: content[PT.BEMERKUNG.rawValue]!)
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollFortfuehrungsantrag", params: apc, handler: defaultAfterSaveHandler)
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
        let section2 = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: PT.PRUEFDATUM.rawValue, rowType: .Date, title: "Prüfdatum")
        row.value=NSDate()
        
        section2.addRow(row)
        row = FormRowDescriptor(tag: PT.DOKUMENT.rawValue, rowType: .BooleanSwitch, title: "inkl. Foto")
        section2.addRow(row)
//
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("DetailVC FINISH")
//        if let x = (callBacker as? UIImagePickerControllerDelegate) {
//            x.imagePickerController!(picker, didFinishPickingMediaWithInfo: info)
//        }
        //picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
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
        return CGSize(width: 500, height: 200)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() as!  [String : AnyObject]
            showWaiting()
            let apc=getParameterContainer()
            let date=content[PT.PRUEFDATUM.rawValue]!
            let nowDouble = date.timeIntervalSince1970
            let millis = Int64(nowDouble*1000) + Int64(nowDouble/1000)
            let param = "\(millis)"
            apc.append(PT.PRUEFDATUM.rawValue, value: param)
            
            
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
        let section2 = FormSectionDescriptor()
        let row = FormRowDescriptor(tag: PT.PRUEFDATUM.rawValue, rowType: .Date, title: "Prüfdatum")
        row.value=NSDate()
        section2.addRow(row)
        form.sections = [section2]
        return form
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 100)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() as!  [String : AnyObject]
            showWaiting()
            let apc=getParameterContainer()
            let date=content[PT.PRUEFDATUM.rawValue]!
            let nowDouble = date.timeIntervalSince1970
            let millis = Int64(nowDouble*1000) + Int64(nowDouble/1000)
            let param = "\(millis)"
            apc.append(PT.PRUEFDATUM.rawValue, value: param)
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollSchaltstelleRevision", params: apc, handler: defaultAfterSaveHandler)
        }
    }
}