//
//  LeuchteActionForms.swift
//  belis-app
//
//  Created by Thorsten Hell on 12.11.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import Foundation
import SwiftForms


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