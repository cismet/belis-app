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
        row.value=NSDate()
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
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() as!  [String : AnyObject]
            showWaiting()
            let apc=getParameterContainer()
            let date=content[PT.ANSTRICHDATUM.rawValue]!
            let nowDouble = date.timeIntervalSince1970
            let millis = Int64(nowDouble*1000) + Int64(nowDouble/1000)
            let param = "\(millis)"
            apc.append(PT.ANSTRICHDATUM.rawValue, value: param)
            apc.append(PT.ANSTRICHFARBE.rawValue, value: content[PT.ANSTRICHFARBE.rawValue]!)
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollStandortAnstricharbeiten", params: apc, handler: defaultAfterSaveHandler)
        }
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
        row.value=NSDate()
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
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() as!  [String : AnyObject]
            showWaiting()
            let apc=getParameterContainer()
            let date=content[PT.PRUEFDATUM.rawValue]!
            let nowDouble = date.timeIntervalSince1970
            let millis = Int64(nowDouble*1000) + Int64(nowDouble/1000)
            let param = "\(millis)"
            apc.append(PT.PRUEFDATUM.rawValue, value: param)
            var erdung=""
            if let erdInOrdnung=content[PT.ERDUNG_IN_ORDNUNG.rawValue] as? Bool{
                if erdInOrdnung{
                    erdung="ja"
                }
                else {
                    erdung="nein"
                }
            }
            else {
                erdung="nein"
            }
            
            apc.append(PT.ERDUNG_IN_ORDNUNG.rawValue, value: erdung)
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollStandortElektrischePruefung", params: apc, handler: defaultAfterSaveHandler)
        }
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
        row.value=NSDate()
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
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() as!  [String : AnyObject]
            showWaiting()
            let apc=getParameterContainer()
            let date=content[PT.INBETRIEBNAHMEDATUM.rawValue]!
            let nowDouble = date.timeIntervalSince1970
            let millis = Int64(nowDouble*1000) + Int64(nowDouble/1000)
            let param = "\(millis)"
            apc.append(PT.INBETRIEBNAHMEDATUM.rawValue, value: param)
            apc.append(PT.MONTAGEFIRMA.rawValue, value: content[PT.MONTAGEFIRMA.rawValue]!)
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollStandortMasterneuerung", params: apc, handler: defaultAfterSaveHandler)
        }
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
        row.value=NSDate()
        section0.addRow(row)
        form.sections = [section0]
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
            let date=content[PT.REVISIONSDATUM.rawValue]!
            let nowDouble = date.timeIntervalSince1970
            let millis = Int64(nowDouble*1000) + Int64(nowDouble/1000)
            let param = "\(millis)"
            apc.append(PT.REVISIONSDATUM.rawValue, value: param)
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollStandortRevision", params: apc, handler: defaultAfterSaveHandler)
        }
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
        row.value=NSDate()
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.VERFAHREN.rawValue, rowType: .Name, title: "Verfahren")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.NAECHSTES_PRUEFDATUM.rawValue, rowType: .Date, title: "Nächstes Prüfdatum")
        row.value=NSDate()
        section0.addRow(row)
        form.sections = [section0]
        return form
    }
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 190)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() as!  [String : AnyObject]
            showWaiting()
            let apc=getParameterContainer()
            let datepd=content[PT.PRUEFDATUM.rawValue]!
            let nowDoublepd = datepd.timeIntervalSince1970
            let millispd = Int64(nowDoublepd*1000) + Int64(nowDoublepd/1000)
            let parampd = "\(millispd)"

            let datepdn=content[PT.NAECHSTES_PRUEFDATUM.rawValue]!
            let nowDoublepdn = datepdn.timeIntervalSince1970
            let millispdn = Int64(nowDoublepdn*1000) + Int64(nowDoublepdn/1000)
            let parampdn = "\(millispdn)"
            
            apc.append(PT.PRUEFDATUM.rawValue, value: parampd)
            apc.append(PT.VERFAHREN.rawValue, value: content[PT.VERFAHREN.rawValue]!)
            apc.append(PT.NAECHSTES_PRUEFDATUM.rawValue, value: parampdn)

            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollStandortStandsicherheitspruefung", params: apc, handler: defaultAfterSaveHandler)
        }
    }
    
}
