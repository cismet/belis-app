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
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Protokoll Details"
        let section0 = FormSectionDescriptor()
        section0.headerTitle = "Status"
        var row: FormRowDescriptor! = FormRowDescriptor(tag: PT.STATUS.rawValue, rowType: .SegmentedControl, title: "")
        row.configuration[FormRowDescriptor.Configuration.Options] = CidsConnector.sharedInstance().sortedArbeitsprotokollStatusListKeys
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            let s=CidsConnector.sharedInstance().arbeitsprotokollStatusList[value as! String]
            return "\(s?.bezeichnung ?? "???")"
            } as TitleFormatterClosure
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["segmentedControl.tintColor" : UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)]
        if let statid=protokoll.status?.id {
            row.value="\(statid)"
        }
        section0.addRow(row)
        
        let section1 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: PT.MONTEUR.rawValue, rowType: .Text, title: "Monteur")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "Monteurname", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        if let mont=protokoll.monteur {
            row.value=mont
        } else {
            row.value=CidsConnector.sharedInstance().lastMonteur
        }
        section1.addRow(row)
        row = FormRowDescriptor(tag: PT.DATUM.rawValue, rowType: .Date, title: "Datum")
        if let dat=protokoll.datum {
            row.value=dat
        }
        else {
            row.value=NSDate()
        }
        section1.addRow(row)
        let section2 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: PT.BEMERKUNG.rawValue, rowType: .MultilineText, title: "")
        section2.headerTitle = "Bemerkung"
        row.value=protokoll.bemerkung
        section2.addRow(row)
        let section3 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: PT.MATERIAL.rawValue, rowType: .MultilineText, title: "")
        section3.headerTitle = "Material"
        section3.addRow(row)
        row.value=protokoll.material
        
        form.sections=[section1,section0,section2,section3]
        return form
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 500)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() as!  [String : AnyObject]
            showWaiting()

            let apc=getParameterContainer()
            //------------------
            if let mont=content[PT.MONTEUR.rawValue] as?  String {
                apc.append(PT.MONTEUR.rawValue, value: mont)
                CidsConnector.sharedInstance().lastMonteur=mont
                NSUserDefaults.standardUserDefaults().setObject(mont, forKey: "lastMonteur")
            }

            //------------------
            let date=content[PT.DATUM.rawValue]!
            let nowDouble = date.timeIntervalSince1970
            let millis = Int64(nowDouble*1000) + Int64(nowDouble/1000)
            let param = "\(millis)"
            apc.append(PT.DATUM.rawValue, value: param)
            //------------------
            let sid=content[PT.STATUS.rawValue]
            apc.append(PT.STATUS.rawValue, value: sid!)
            //------------------
            apc.append(PT.BEMERKUNG.rawValue, value: content[PT.BEMERKUNG.rawValue]!)
            //------------------
            apc.append(PT.MATERIAL.rawValue, value: content[PT.MATERIAL.rawValue]!)
            //------------------
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollStatusAenderung", params: apc, handler: defaultAfterSaveHandler)
           
        }
    }
}