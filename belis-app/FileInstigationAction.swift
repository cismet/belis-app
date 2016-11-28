//
//  FileInstigationAction.swift
//  belis-app
//
//  Created by Thorsten Hell on 23.11.16.
//  Copyright © 2016 cismet. All rights reserved.
//

import Foundation
import SwiftForms

class FileInstigationAction : BaseEntityAction {
    enum PT:String {
        case MONTEUR
        case DATUM
        case STATUS
        case BEMERKUNG
        case MATERIAL
    }
    
    init(yourself: BaseEntity) {
        super.init(title: "Störung melden",style: UIAlertActionStyle.destructive, handler: {
            (action: UIAlertAction? , selfAction: BaseEntityAction, obj: BaseEntity, detailVC: UIViewController)->Void in
            let optionsListKeys: [String]=["nothing","singleAA","add2Current"]
            let options: [String:String]=["nothing":"nur Veranlassung","singleAA":"Einzelauftrag","add2Current":"📥6488"]
            

            let form = FormDescriptor()
            form.title = "Störung melden"
            
            let section0 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
            section0.headerTitle = "Aktion"
            var row: FormRowDescriptor! = FormRowDescriptor(tag: PT.STATUS.rawValue, type: .segmentedControl, title: "")
            row.configuration.selection.options = optionsListKeys as [AnyObject]
            row.configuration.selection.optionTitleClosure = { value in
                let s=options[value as! String]
                return "\(s ?? "???")"
            }
            row.configuration.cell.appearance = ["segmentedControl.tintColor" : UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)]

            section0.rows.append(row)
            
            let section1 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
            
            row = FormRowDescriptor(tag: PT.MONTEUR.rawValue, type: .text, title: "Bezeichnung")
            row.configuration.cell.appearance = ["textField.placeholder" : "Bezeichnung eingeben" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
            
            
            section1.rows.append(row)
            
            
            
            row = FormRowDescriptor(tag: PT.MONTEUR.rawValue, type: .text, title: "User")
            row.configuration.cell.appearance = ["textField.placeholder" : "Monteurname" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
           
            row.value=CidsConnector.sharedInstance().login as AnyObject?
           
            section1.rows.append(row)
            row = FormRowDescriptor(tag: PT.DATUM.rawValue, type: .date, title: "Datum")
          
            row.value=Date() as AnyObject?
            
            section1.rows.append(row)
            let section2 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
            row = FormRowDescriptor(tag: PT.BEMERKUNG.rawValue, type: .multilineText, title: "")
            section2.headerTitle = "Beschreibung"

            section2.rows.append(row)
            let section3 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
            row = FormRowDescriptor(tag: PT.MATERIAL.rawValue, type: .multilineText, title: "")
            section3.headerTitle = "Bemerkungen"
            section3.rows.append(row)
            
            let section4 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
            row = FormRowDescriptor(tag: PT.BEMERKUNG.rawValue, type: .button, title: "Foto erstellen")
            section4.rows.append(row)
            row = FormRowDescriptor(tag: PT.BEMERKUNG.rawValue, type: .button, title: "Foto auswählen")
            section4.rows.append(row)
            
            
            form.sections=[section1,section0,section2,section3,section4]

            let formVC = CidsConnector.sharedInstance().mainVC!.storyboard!.instantiateViewController(withIdentifier: "formView") as! GenericFormViewController
            
            formVC.form=form
            
            formVC.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
            
            let formNC=UINavigationController(rootViewController: formVC)
            formNC.modalPresentationStyle=UIModalPresentationStyle.overCurrentContext
            
            detailVC.present(formNC, animated: true, completion: {})
          
        } )
    }
}

class InnerViewController: GenericFormViewController {
    


}
