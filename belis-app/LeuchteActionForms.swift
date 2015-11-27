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
    enum PT:String {
        case INBETRIEBNAHMEDATUM
        case LEUCHTENTYP
    }
    override init(){
        super.init()
        title="Leuchtenerneuerung"
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Leuchtenerneuerung"
        let section0 = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: PT.INBETRIEBNAHMEDATUM.rawValue, rowType: .Date, title: "Inbetriebnahme")
        row.value=NSDate()
        //section0.headerTitle = "Informationen zu den durchgeführten Tätigkeiten"
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.LEUCHTENTYP.rawValue, rowType: .Picker, title: "Leuchtentyp")
        
        
        
        row.configuration[FormRowDescriptor.Configuration.Options] = CidsConnector.sharedInstance().sortedLeuchtenTypListKeys
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            let typ=CidsConnector.sharedInstance().leuchtentypList[value as! String]
            return "\(typ!.leuchtenTyp!) - \(typ!.fabrikat!)"
            } as TitleFormatterClosure
        
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
            
            
            if let x=content[PT.LEUCHTENTYP.rawValue] {
                apc.append(PT.LEUCHTENTYP.rawValue, value: x)
            }

            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollLeuchteLeuchtenerneuerung", params: apc, handler: defaultAfterSaveHandler)
        }
    }
    
}

class LeuchtmittelwechselEPAction : ObjectAction {
    enum PT:String {
        case WECHSELDATUM
        case LEBENSDAUER
        case LEUCHTMITTEL
        case PRUEFDATUM
        case ERDUNG_IN_ORDNUNG
    }
    
    override init(){
        super.init()
        title="Leuchtmittelwechsel (mit EP)"
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Leuchtmittelwechsel (mit EP)"
        let section0 = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: PT.PRUEFDATUM.rawValue, rowType: .Date, title: "Elektrische Prüfung am Mast")
        row.value=NSDate()
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.ERDUNG_IN_ORDNUNG.rawValue, rowType: .BooleanSwitch, title: "Erdung in Ordnung")
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.WECHSELDATUM.rawValue, rowType: .Date, title: "Wechseldatum")
        row.value=NSDate()
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.LEUCHTMITTEL.rawValue, rowType: .Picker, title: "eingesetztes Leuchtmittel")
        row.configuration[FormRowDescriptor.Configuration.Options] = CidsConnector.sharedInstance().sortedLeuchtmittelListKeys
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            let lm=CidsConnector.sharedInstance().leuchtmittelList[value as! String]
            return  "\(lm?.hersteller ?? "ohne Hersteller") - \(lm?.lichtfarbe ?? "")"
            } as TitleFormatterClosure
        
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.LEBENSDAUER.rawValue, rowType: .Name, title: "Lebensdauer des Leuchtmittels")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "in Monaten", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section0.addRow(row)
        form.sections = [section0]
        return form
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 290)
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
            apc.append(PT.PRUEFDATUM.rawValue, value: parampd)
            //------------------
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
            //------------------
            let datewd=content[PT.WECHSELDATUM.rawValue]!
            let nowDoublewd = datewd.timeIntervalSince1970
            let milliswd = Int64(nowDoublewd*1000) + Int64(nowDoublewd/1000)
            let paramwd = "\(milliswd)"
            apc.append(PT.WECHSELDATUM.rawValue, value: paramwd)
            //------------------
            if let lid=content[PT.LEUCHTMITTEL.rawValue] {
                apc.append(PT.LEUCHTMITTEL.rawValue, value: lid)
            }
            //------------------
            if let lebensdauer=content[PT.LEBENSDAUER.rawValue] {
                apc.append(PT.LEBENSDAUER.rawValue, value: lebensdauer)
            }

            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollLeuchteLeuchtmittelwechselElekpruefung", params: apc, handler: defaultAfterSaveHandler)
        }
    }
}
class LeuchtmittelwechselAction : ObjectAction {
    enum PT:String {
        case WECHSELDATUM
        case LEBENSDAUER
        case LEUCHTMITTEL
    }
    
    override init(){
        super.init()
        title="Leuchtmittelwechsel"
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Leuchtmittelwechsel"
        let section0 = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: PT.WECHSELDATUM.rawValue, rowType: .Date, title: "Wechseldatum")
        row.value=NSDate()
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.LEUCHTMITTEL.rawValue, rowType: .Picker, title: "eingesetztes Leuchtmittel")
        row.configuration[FormRowDescriptor.Configuration.Options] = CidsConnector.sharedInstance().sortedLeuchtmittelListKeys
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            let lm=CidsConnector.sharedInstance().leuchtmittelList[value as! String]
            return  "\(lm?.hersteller ?? "ohne Hersteller") - \(lm?.lichtfarbe ?? "")"
            } as TitleFormatterClosure

        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.LEBENSDAUER.rawValue, rowType: .Name, title: "Lebensdauer des Leuchtmittels")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "in Monaten", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
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
           
            let datewd=content[PT.WECHSELDATUM.rawValue]!
            let nowDoublewd = datewd.timeIntervalSince1970
            let milliswd = Int64(nowDoublewd*1000) + Int64(nowDoublewd/1000)
            let paramwd = "\(milliswd)"
            apc.append(PT.WECHSELDATUM.rawValue, value: paramwd)
            //------------------
            if let lid=content[PT.LEUCHTMITTEL.rawValue] {
                apc.append(PT.LEUCHTMITTEL.rawValue, value: lid)
            }
            //------------------
            if let lebensdauer=content[PT.LEBENSDAUER.rawValue] {
                apc.append(PT.LEBENSDAUER.rawValue, value: lebensdauer)
            }
            
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollLeuchteLeuchtmittelwechsel", params: apc, handler: defaultAfterSaveHandler)
        }
    }
}
class RundsteuerempfaengerwechselAction : ObjectAction {
    enum PT:String {
        case EINBAUDATUM
        case RUNDSTEUEREMPFAENGER
    }
    override init(){
        super.init()
        title="Rundsteuerempfängerwechsel"
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Rundsteuerempfängerwechsel"
        let section0 = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: PT.EINBAUDATUM.rawValue, rowType: .Date, title: "Einbaudatum")
        row.value=NSDate()
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.RUNDSTEUEREMPFAENGER.rawValue, rowType: .Picker, title: "Rundsteuerempfänger")
        row.configuration[FormRowDescriptor.Configuration.Options] = CidsConnector.sharedInstance().sortedRundsteuerempfaengerListKeys
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            let rse=CidsConnector.sharedInstance().rundsteuerempfaengerList[value as! String]
            return"\(rse?.herrsteller_rs ?? "ohne Hersteller") - \(rse?.rs_typ ?? "")"
            } as TitleFormatterClosure
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
            
            let datewd=content[PT.EINBAUDATUM.rawValue]!
            let nowDoublewd = datewd.timeIntervalSince1970
            let milliswd = Int64(nowDoublewd*1000) + Int64(nowDoublewd/1000)
            let paramwd = "\(milliswd)"
            apc.append(PT.EINBAUDATUM.rawValue, value: paramwd)
            //------------------
            if let rid=content[PT.RUNDSTEUEREMPFAENGER.rawValue]{
                apc.append(PT.RUNDSTEUEREMPFAENGER.rawValue, value: rid)
            }
            
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollLeuchteRundsteuerempfaengerwechsel", params: apc, handler: defaultAfterSaveHandler)
        }
    }
    
}
class SonderturnusAction : ObjectAction {
    enum PT:String {
        case DATUM
    }
    override init(){
        super.init()
        title="Sonderturnus"
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Rundsteuerempfängerwechsel"
        let section0 = FormSectionDescriptor()
        let row = FormRowDescriptor(tag: PT.DATUM.rawValue, rowType: .Date, title: "Sonderturnus")
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
            
            let datewd=content[PT.DATUM.rawValue]!
            let nowDoublewd = datewd.timeIntervalSince1970
            let milliswd = Int64(nowDoublewd*1000) + Int64(nowDoublewd/1000)
            let paramwd = "\(milliswd)"
            apc.append(PT.DATUM.rawValue, value: paramwd)
            //------------------
            
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollLeuchteSonderturnus", params: apc, handler: defaultAfterSaveHandler)
        }
    }
    
}
class VorschaltgeraetwechselAction : ObjectAction {
    enum PT:String {
        case WECHSELDATUM
        case VORSCHALTGERAET
    }
    override init(){
        super.init()
        title="Vorschaltgerätwechsel"
    }
    override func getFormDescriptor()->FormDescriptor {
        let form = FormDescriptor()
        form.title = "Vorschaltgerätwechsel"
        let section0 = FormSectionDescriptor()
        var row = FormRowDescriptor(tag: PT.WECHSELDATUM.rawValue, rowType: .Date, title: "Einbaudatum")
        row.value=NSDate()
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.VORSCHALTGERAET.rawValue, rowType: .Name, title: "Vorschaltgerät")
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
            
            let datewd=content[PT.WECHSELDATUM.rawValue]!
            let nowDoublewd = datewd.timeIntervalSince1970
            let milliswd = Int64(nowDoublewd*1000) + Int64(nowDoublewd/1000)
            let paramwd = "\(milliswd)"
            apc.append(PT.WECHSELDATUM.rawValue, value: paramwd)
            //------------------
            if let vid=content[PT.VORSCHALTGERAET.rawValue]{
                apc.append(PT.VORSCHALTGERAET.rawValue, value: vid)
            }
            
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollLeuchteVorschaltgeraetwechsel", params: apc, handler: defaultAfterSaveHandler)
        }
    }
}