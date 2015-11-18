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
class MauerlaschenPruefungAction : ObjectAction, UIImagePickerControllerDelegate, UINavigationControllerDelegate, Refreshable {
    enum ParamterType:String {
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
        var row = FormRowDescriptor(tag: ParamterType.PRUEFDATUM.rawValue, rowType: .Date, title: "Prüfdatum")
        //section2.headerTitle = "Informationen zu den durchgeführten Tätigkeiten"
        section2.addRow(row)
        row = FormRowDescriptor(tag: "", rowType: .Button, title: "Foto erstellen")
        row.configuration[FormRowDescriptor.Configuration.DidSelectClosure] = {
            super.formVC.view.endEditing(true)
            
            let picker = MainViewController.IMAGE_PICKER
            picker.sourceType = UIImagePickerControllerSourceType.Camera
            picker.delegate = self
            self.callBacker=FotoPickerCallBacker(yourself: self.entity ,refreshable: self)
            
            picker.allowsEditing = true
            //picker.showsCameraControls=true
            picker.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
            super.formVC.presentViewController(picker, animated: true, completion: { () -> Void in  })
            
            } as DidSelectClosure
        section2.addRow(row)
        row = FormRowDescriptor(tag: "", rowType: .Button, title: "Foto auswählen")
        row.configuration[FormRowDescriptor.Configuration.DidSelectClosure] = {
            super.formVC.view.endEditing(true)
            
            let picker = MainViewController.IMAGE_PICKER
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
            picker.delegate = self
            self.callBacker=FotoPickerCallBacker(yourself: self.entity ,refreshable: self)
            
            picker.allowsEditing = true
            //picker.showsCameraControls=true
            picker.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            super.formVC.presentViewController(picker, animated: true, completion: { () -> Void in  })
            
            } as DidSelectClosure
        section2.addRow(row)
        form.sections = [section2]
        return form
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("DetailVC FINISH")
        if let x = (callBacker as? UIImagePickerControllerDelegate) {
            x.imagePickerController!(picker, didFinishPickingMediaWithInfo: info)
        }
        //picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("DetailVC CANCEL")
        if let x = (callBacker as? UIImagePickerControllerDelegate) {
            x.imagePickerControllerDidCancel!(picker)
        }
        //picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }

    func refresh() {
    
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
class SchaltstellenRevisionAction : ObjectAction {
    enum ParamterType:String {
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
        let row = FormRowDescriptor(tag: ParamterType.PRUEFDATUM.rawValue, rowType: .Date, title: "Prüfdatum")
        section2.addRow(row)
        form.sections = [section2]
        return form
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 100)
    }
    
    override func save(){
        print("HELL SAVE")
        
    }
    
    override func cancel(){
        print("HELL CANCEL")
    }
    
}