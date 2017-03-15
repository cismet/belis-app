//
//  FileInstigationAction.swift
//  belis-app
//
//  Created by Thorsten Hell on 23.11.16.
//  Copyright © 2016 cismet. All rights reserved.
//

import Foundation
import SwiftForms

class AddIncidentAction : BaseEntityAction {
    enum PT:String {
        
        case DATUM
        case USER
        
        case AKTION
        case OBJEKT_ID
        case OBJEKT_TYP
        case BEZEICHNUNG
        case BESCHREIBUNG
        case BEMERKUNG
        case ARBEITSAUFTRAG_ZUGEWIESEN_AN
        case DOKUMENT_URLS
        
        case VERANLASSUNG
        case EINZELAUFTRAG
        case ADD2ARBEITSAUFTRAG
    }
    
    init(yourself: BaseEntity) {
        super.init(title: "Störung melden",style: UIAlertActionStyle.destructive, handler: {
            (action: UIAlertAction? , selfAction: BaseEntityAction, obj: BaseEntity, detailVC: UIViewController)->Void in
            let entity=yourself
            let formVC = CidsConnector.sharedInstance().mainVC!.storyboard!.instantiateViewController(withIdentifier: "formView") as! GenericFormViewController
            
            
            var optionsOpt: [String:String]=["VERANLASSUNG":"nur Veranlassung","EINZELAUFTRAG":"Einzelauftrag"]
            var optionsListKeysOpt: [String]=[PT.VERANLASSUNG.rawValue,PT.EINZELAUFTRAG.rawValue]
            if let selectedArbeitsauftrag=CidsConnector.sharedInstance().selectedArbeitsauftrag {
                optionsOpt=[PT.VERANLASSUNG.rawValue:"nur Veranlassung",PT.EINZELAUFTRAG.rawValue:"Einzelauftrag",PT.ADD2ARBEITSAUFTRAG.rawValue:"📥"+selectedArbeitsauftrag.nummer!]
                optionsListKeysOpt=[PT.VERANLASSUNG.rawValue,PT.EINZELAUFTRAG.rawValue,PT.ADD2ARBEITSAUFTRAG.rawValue]
                
            }
            
            let options: [String:String]=optionsOpt
            let optionsListKeys: [String]=optionsListKeysOpt
            
            
            let form = FormDescriptor()
            form.title = "Störung melden"
            
            let aktionsSection = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
            aktionsSection.headerTitle = "Aktion"
            var row: FormRowDescriptor! = FormRowDescriptor(tag: PT.AKTION.rawValue, type: .segmentedControl, title: "")
            row.configuration.selection.options = optionsListKeys as [AnyObject]
            row.configuration.selection.optionTitleClosure = { value in
                return options[value as! String] ?? "?"
            }
            
            //TeamRow for later usage
            let teamRow = FormRowDescriptor(tag: PT.ARBEITSAUFTRAG_ZUGEWIESEN_AN.rawValue, type: .multipleSelector, title: "Teams")
            let teamKeys=CidsConnector.sharedInstance().sortedTeamListKeys
            let teamList=CidsConnector.sharedInstance().teamList
            
            if let lastTeam=CidsConnector.sharedInstance().lastUsedTeamIdForIncident {
            
            }
            else {
                if let teamid=CidsConnector.sharedInstance().selectedTeam?.id {
                    CidsConnector.sharedInstance().lastUsedTeamIdForIncident="\(teamid)"
                }else {
                    CidsConnector.sharedInstance().lastUsedTeamIdForIncident="-1"
                }
            }
            
            teamRow.configuration.selection.options = teamKeys as [AnyObject]
            teamRow.configuration.selection.allowsMultipleSelection = false
            teamRow.configuration.selection.optionTitleClosure = { value in
                print(value)
                return teamList[value as! String]?.name ?? "Team ?"
            }
            teamRow.value=CidsConnector.sharedInstance().lastUsedTeamIdForIncident as AnyObject
            teamRow.configuration.cell.didUpdateClosure = {_ in
                let content = formVC.form.formValues()
                if let team=content[PT.ARBEITSAUFTRAG_ZUGEWIESEN_AN.rawValue] as? String{
                    CidsConnector.sharedInstance().lastUsedTeamIdForIncident=team
                }
            }

            row.configuration.cell.didUpdateClosure = { formRowDescriptor in
                let content = formVC.form.formValues()
                if let aktion=content[PT.AKTION.rawValue]{
                    if aktion as! String == PT.EINZELAUFTRAG.rawValue {
                        aktionsSection.rows.append(teamRow)
                    }
                    else {
                        if aktionsSection.rows.count>1 {
                            aktionsSection.rows.remove(at: 1)
                        }
                    }
                }
                formVC.refresh()
                
            }
            
            row.configuration.cell.appearance = ["segmentedControl.tintColor" : UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)]
//           // row.value=PT.VERANLASSUNG.rawValue as AnyObject
//            row.configuration.cell.appearance["segmentedControl.selectedSegmentIndex"]=PT.VERANLASSUNG.rawValue as AnyObject
            var content = formVC.form.formValues()
                        
            aktionsSection.rows.append(row)
            
            let section1 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
            
            row = FormRowDescriptor(tag: PT.BEZEICHNUNG.rawValue, type: .text, title: "Bezeichnung")
            row.configuration.cell.appearance = ["textField.placeholder" : "Bezeichnung eingeben" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
            
            
            section1.rows.append(row)
            
            
            
            row = FormRowDescriptor(tag: PT.USER.rawValue, type: .text, title: "User")
            row.configuration.cell.appearance = ["textField.placeholder" : "Monteurname" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
            
            row.value=CidsConnector.sharedInstance().login as AnyObject?
            
            section1.rows.append(row)
            row = FormRowDescriptor(tag: PT.DATUM.rawValue, type: .date, title: "Datum")
            
            row.value=Date() as AnyObject?
            
            section1.rows.append(row)
            let section2 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
            row = FormRowDescriptor(tag: PT.BESCHREIBUNG.rawValue, type: .multilineText, title: "")
            section2.headerTitle = "Beschreibung"
            
            section2.rows.append(row)
            let section3 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
            row = FormRowDescriptor(tag: PT.BEMERKUNG.rawValue, type: .multilineText, title: "")
            section3.headerTitle = "Bemerkungen"
            section3.rows.append(row)
            
            let section4 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
            row = FormRowDescriptor(tag: PT.DOKUMENT_URLS.rawValue, type: .button, title: "Foto erstellen")
            row.configuration.cell.appearance = ["titleLabel.textColor" : UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)]
            row.configuration.button.didSelectClosure = { (FormRowDescriptor) -> Void in
                print("Fotooooooo")
                let pdc=PureDocumentContainer()
                // let tfa=TakeFotoAction(yourself: pdc)
                // tfa.handler(,
                let picker = UIImagePickerController() //MainViewController.IMAGE_PICKER
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                picker.delegate = detailVC as! DetailVC
                (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: pdc,refreshable: formVC)
                picker.allowsEditing = true
                picker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
                //
                detailVC.present(picker, animated: true, completion: {})
            }
            
            section4.rows.append(row)
            row = FormRowDescriptor(tag: PT.BEMERKUNG.rawValue, type: .button, title: "Foto auswählen")
            row.configuration.cell.appearance = ["titleLabel.textColor" : UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)]
            row.configuration.button.didSelectClosure = { (FormRowDescriptor) -> Void in
                print("Mediaaaaa")
                let pdc=PureDocumentContainer()
                // let tfa=TakeFotoAction(yourself: pdc)
                // tfa.handler(,
                let picker = UIImagePickerController() //MainViewController.IMAGE_PICKER
                picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
                picker.delegate = detailVC as! DetailVC
                (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: pdc,refreshable: formVC)
                picker.allowsEditing = true
                picker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                //
                detailVC.present(picker, animated: true, completion: {})
            }
            
            
            section4.rows.append(row)
            form.sections=[section1,aktionsSection,section2,section3,section4]
            
            
            
            formVC.form=form
            
            let preSaveCheck: ()->CheckResult={
                let content = formVC.form.formValues()
                if (content[PT.AKTION.rawValue] as?  String) != nil {
                    if (content[PT.BEZEICHNUNG.rawValue] as?  String) != nil {
                        return CheckResult(passed: true)
                    }
                    else {
                        return CheckResult(passed:false, title: "Bezeichnung angeben", withMessage: "Bei einer Störungsmeldung muss die Bezeichnung angegeben werden.")
                    }
                }
                else {
                    return CheckResult(passed:false, title: "Aktion angeben", withMessage: "Bei einer Störungsmeldung muss die Aktion angegeben werden.")
                }
            }
            
            let preCancelCheck: ()->CheckResult={
                print("preCancelCheck")
                return CheckResult(passed: true)
            }

            
            let save: ()-> Void={
                let content = formVC.form.formValues()
                let params=ActionParameterContainer(params: [PT.AKTION.rawValue : content[PT.AKTION.rawValue]!,
                                                             PT.OBJEKT_ID.rawValue: entity.id as AnyObject,
                                                             PT.OBJEKT_TYP.rawValue: entity.getType().tableName() as AnyObject,
                                                             ])
                if let bezeichnung=content[PT.BEZEICHNUNG.rawValue] as? String {
                    params.append(PT.BEZEICHNUNG.rawValue, value: bezeichnung as AnyObject)
                }
                if let bemerkung=content[PT.BEMERKUNG.rawValue] as? String {
                    params.append(PT.BEMERKUNG.rawValue, value: bemerkung as AnyObject)
                }
                if let beschreibung=content[PT.BESCHREIBUNG.rawValue] as? String {
                    params.append(PT.BESCHREIBUNG.rawValue, value: beschreibung as AnyObject)
                }
                
                if let team=content[PT.ARBEITSAUFTRAG_ZUGEWIESEN_AN.rawValue]  as? String {
                    params.append(PT.ARBEITSAUFTRAG_ZUGEWIESEN_AN.rawValue, value: team as AnyObject)
                }

                
                print(params.toJSONString(prettyPrint: true) ?? "no json for you")
            }
            
            func cancel() {
                print("WHAAAAAT")
                
            }
            
            
            formVC.saveHandler=save
            formVC.cancelHandler=cancel
            formVC.preCancelCheck=preCancelCheck
            formVC.preSaveCheck=preSaveCheck
            
            detailVC.navigationController?.pushViewController(formVC, animated: true)
            
        } )
    }
    
    
    
}

