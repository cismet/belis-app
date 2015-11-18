//
//  MastActionForms.swift
//  belis-app
//
//  Created by Thorsten Hell on 12.11.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import Foundation
import SwiftForms

class AnstricharbeitenAction : ObjectAction {
    override init(){
        super.init()
        title="Anstricharbeiten"
    }
    enum PT:String {
        case ANSTRICHDATUM
        case ANSTRICHFARBE
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Anstricharbeiten"
        let section0 = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: PT.ANSTRICHDATUM.rawValue, rowType: .Date, title: "Mastanstrich")
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.ANSTRICHFARBE.rawValue, rowType: .Name, title: "Anstrichfarbe")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section0.addRow(row)
        form.sections = [section0]
        return form
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 140)
    }
    
    override func save(){
        print("HELL SAVE")
        
    }
    
    
    
}

class ElektrischePruefungAction : ObjectAction {
    override init(){
        super.init()
        title="Elektrische Prüfung"
    }
    enum PT:String {
        case PRUEFDATUM
        case ERDUNG_IN_ORDNUNG
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Elektrische Prüfung"
        let section0 = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: PT.PRUEFDATUM.rawValue, rowType: .Date, title: "Elektrische Prüfung am Mast")
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.ERDUNG_IN_ORDNUNG.rawValue, rowType: .BooleanSwitch, title: "Erdung in Ordnung")
        section0.addRow(row)
        form.sections = [section0]
        return form
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 140)
    }
    
    override func save(){
        print("HELL SAVE")
        
    }
    
    
}
class MasterneuerungAction : ObjectAction {
    override init(){
        super.init()
        title="Masterneuerung"
    }
    enum PT:String {
        case INBETRIEBNAHMEDATUM
        case MONTAGEFIRMA
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Masterneuerung"
        let section0 = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: PT.INBETRIEBNAHMEDATUM.rawValue, rowType: .Date, title: "Inbetriebnahme")
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.MONTAGEFIRMA.rawValue, rowType: .Name, title: "Montagefirma")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section0.addRow(row)
        form.sections = [section0]
        return form
        
    }
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 140)
    }
    
    override func save(){
        print("HELL SAVE")
        
    }
    
}
class MastRevisionAction : ObjectAction {
    override init(){
        super.init()
        title="Revision"
    }
    enum PT:String {
        case REVISIONSDATUM
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Revision"
        let section0 = FormSectionDescriptor()
        let row = FormRowDescriptor(tag: PT.REVISIONSDATUM.rawValue, rowType: .Date, title: "Revision")
        section0.addRow(row)
        form.sections = [section0]
        return form
    }
    
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 100)
    }
    
    override func save(){
        print("HELL SAVE")
        
    }
    
}
class StandsicherheitspruefungAction : ObjectAction {
    override init(){
        super.init()
        title="Standsicherheitsprüfung"
    }
    enum PT:String {
        case PRUEFDATUM
        case VERFAHREN
        case NAECHSTES_PRUEFDATUM
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Standsicherheitsprüfung"
        let section0 = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: PT.PRUEFDATUM.rawValue, rowType: .Date, title: "Standsicherheitsprüfung")
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.VERFAHREN.rawValue, rowType: .Name, title: "Verfahren")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.NAECHSTES_PRUEFDATUM.rawValue, rowType: .Date, title: "Nächstes Prüfdatum")
        section0.addRow(row)
        form.sections = [section0]
        return form
    }
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 190)
    }
    
    override func save(){
        print("HELL SAVE")
        
    }
    
}
