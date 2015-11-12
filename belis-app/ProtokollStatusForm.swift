//
//  ProtokollStatusForm.swift
//  belis-app
//
//  Created by Thorsten Hell on 12.11.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import Foundation
import SwiftForms


class ProtokollStatusForm : FormDescriptor{
    var protokoll: Arbeitsprotokoll!
    var viewController: GenericFormViewController!
    init(protokoll: Arbeitsprotokoll!, vc: GenericFormViewController! ) {
        super.init()
        self.protokoll=protokoll
        self.viewController=vc
        title = "Protokoll Details"
        let section0 = FormSectionDescriptor()
        section0.headerTitle = "Status"
        var row: FormRowDescriptor! = FormRowDescriptor(tag: "status", rowType: .SegmentedControl, title: "")
        row.configuration[FormRowDescriptor.Configuration.Options] = [0, 1, 2]
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            switch( value ) {
            case 0:
                return "in Bearbeitung"
            case 1:
                return "erledigt"
            case 2:
                return "Fehlmeldung"
            default:
                return nil
            }
            } as TitleFormatterClosure
        
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["segmentedControl.tintColor" : UIColor.blueColor()]
        section0.addRow(row)
        
        let section1 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: "monteur", rowType: .Text, title: "Monteur")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "Monteurname", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        row.value=protokoll.monteur
        section1.addRow(row)
        row = FormRowDescriptor(tag: "datum", rowType: .Date, title: "Datum")
        row.value=protokoll.datum
        section1.addRow(row)
        let section2 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: "bemerkung", rowType: .MultilineText, title: "")
        section2.headerTitle = "Bemerkung"
        row.value=protokoll.bemerkung
        section2.addRow(row)
        let section3 = FormSectionDescriptor()
        row = FormRowDescriptor(tag: "material", rowType: .MultilineText, title: "")
        section3.headerTitle = "Material"
        section3.addRow(row)
        row.value=protokoll.material
        
//        let section8 = FormSectionDescriptor()
//        
//        row = FormRowDescriptor(tag: "dismiss", rowType: .Button, title: "---")
//        row.configuration[FormRowDescriptor.Configuration.DidSelectClosure] = {
//            vc.view.endEditing(true)
//            } as DidSelectClosure
//        section8.addRow(row)
        
        
        sections = [section1,section0,section2,section3]//,section8]
    }
    
    
}