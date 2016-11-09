
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
        let section0 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        var row = FormRowDescriptor(tag: PT.INBETRIEBNAHMEDATUM.rawValue, type: .date, title: "Inbetriebnahme")
        row.value=Date() as AnyObject?
        //section0.headerTitle = "Informationen zu den durchgeführten Tätigkeiten"
        section0.rows.append(row)
        row = FormRowDescriptor(tag: PT.LEUCHTENTYP.rawValue, type: .picker, title: "Leuchtentyp")
        
        row.configuration.selection.options = CidsConnector.sharedInstance().sortedLeuchtenTypListKeys as [AnyObject]
        row.configuration.selection.optionTitleClosure = { value in
            let typ=CidsConnector.sharedInstance().leuchtentypList[value as! String]
            return "\(typ?.leuchtenTyp ?? "unbekannter Typ") - \(typ?.fabrikat ?? "unbekanntes Fabrikat")"
            }
        section0.rows.append(row)
        
        form.sections = [section0]
        return form
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 140)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() 
            showWaiting()
            let apc=getParameterContainer()
            let date=content[PT.INBETRIEBNAHMEDATUM.rawValue]!
            let nowDouble = date.timeIntervalSince1970
            let millis = Int64(nowDouble!*1000) + Int64(nowDouble!/1000)
            let param = "\(millis)"
            apc.append(PT.INBETRIEBNAHMEDATUM.rawValue, value: param as AnyObject)
            
            
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
        let section0 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        var row = FormRowDescriptor(tag: PT.PRUEFDATUM.rawValue, type: .date, title: "Elektrische Prüfung am Mast")
        row.value=Date() as AnyObject?
        section0.rows.append(row)
        row = FormRowDescriptor(tag: PT.ERDUNG_IN_ORDNUNG.rawValue, type: .booleanSwitch, title: "Erdung in Ordnung")
        section0.rows.append(row)
        row = FormRowDescriptor(tag: PT.WECHSELDATUM.rawValue, type: .date, title: "Wechseldatum")
        row.value=Date() as AnyObject?
        section0.rows.append(row)
        row = FormRowDescriptor(tag: PT.LEUCHTMITTEL.rawValue, type: .picker, title: "eingesetztes Leuchtmittel")
        row.configuration.selection.options=CidsConnector.sharedInstance().sortedLeuchtmittelListKeys as [AnyObject]
        row.configuration.selection.optionTitleClosure = { value in
            let lm=CidsConnector.sharedInstance().leuchtmittelList[value as! String]
            return  "\(lm?.hersteller ?? "ohne Hersteller") - \(lm?.lichtfarbe ?? "")"
            }
        
        section0.rows.append(row)
        row = FormRowDescriptor(tag: PT.LEBENSDAUER.rawValue, type: .name, title: "Lebensdauer des Leuchtmittels")
        row.configuration.cell.appearance = ["textField.placeholder" : "in Monaten" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
        section0.rows.append(row)
        form.sections = [section0]
        return form
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 290)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() 
            showWaiting()
            let apc=getParameterContainer()
            
            let datepd=content[PT.PRUEFDATUM.rawValue]!
            let nowDoublepd = datepd.timeIntervalSince1970
            let millispd = Int64(nowDoublepd!*1000) + Int64(nowDoublepd!/1000)
            let parampd = "\(millispd)"
            apc.append(PT.PRUEFDATUM.rawValue, value: parampd as AnyObject)
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
            apc.append(PT.ERDUNG_IN_ORDNUNG.rawValue, value: erdung as AnyObject)
            //------------------
            let datewd=content[PT.WECHSELDATUM.rawValue]!
            let nowDoublewd = datewd.timeIntervalSince1970
            let milliswd = Int64(nowDoublewd!*1000) + Int64(nowDoublewd!/1000)
            let paramwd = "\(milliswd)"
            apc.append(PT.WECHSELDATUM.rawValue, value: paramwd as AnyObject)
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
        let section0 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        var row = FormRowDescriptor(tag: PT.WECHSELDATUM.rawValue, type: .date, title: "Wechseldatum")
        row.value=Date() as AnyObject?
        section0.rows.append(row)
        row = FormRowDescriptor(tag: PT.LEUCHTMITTEL.rawValue, type: .picker, title: "eingesetztes Leuchtmittel")
        row.configuration.selection.options = CidsConnector.sharedInstance().sortedLeuchtmittelListKeys as [AnyObject]
        row.configuration.selection.optionTitleClosure = { value in
            let lm=CidsConnector.sharedInstance().leuchtmittelList[value as! String]
            return  "\(lm?.hersteller ?? "ohne Hersteller") - \(lm?.lichtfarbe ?? "")"
            }

        section0.rows.append(row)
        row = FormRowDescriptor(tag: PT.LEBENSDAUER.rawValue, type: .name, title: "Lebensdauer des Leuchtmittels")
        row.configuration.cell.appearance = ["textField.placeholder" : "in Monaten" as AnyObject, "textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
        section0.rows.append(row)
        form.sections = [section0]
        return form
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 190)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() 
            showWaiting()
            let apc=getParameterContainer()
           
            let datewd=content[PT.WECHSELDATUM.rawValue]!
            let nowDoublewd = datewd.timeIntervalSince1970
            let milliswd = Int64(nowDoublewd!*1000) + Int64(nowDoublewd!/1000)
            let paramwd = "\(milliswd)"
            apc.append(PT.WECHSELDATUM.rawValue, value: paramwd as AnyObject)
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
        let section0 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        var row = FormRowDescriptor(tag: PT.EINBAUDATUM.rawValue, type: .date, title: "Einbaudatum")
        row.value=Date() as AnyObject?
        section0.rows.append(row)
        row = FormRowDescriptor(tag: PT.RUNDSTEUEREMPFAENGER.rawValue, type: .picker, title: "Rundsteuerempfänger")
        row.configuration.selection.options = CidsConnector.sharedInstance().sortedRundsteuerempfaengerListKeys as [AnyObject]
        row.configuration.selection.optionTitleClosure = { value in
            let rse=CidsConnector.sharedInstance().rundsteuerempfaengerList[value as! String]
            return"\(rse?.herrsteller_rs ?? "ohne Hersteller") - \(rse?.rs_typ ?? "")"
            } 
        section0.rows.append(row)
        form.sections = [section0]
        return form
        
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 140)
    }
    
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() 
            showWaiting()
            let apc=getParameterContainer()
            
            let datewd=content[PT.EINBAUDATUM.rawValue]!
            let nowDoublewd = datewd.timeIntervalSince1970
            let milliswd = Int64(nowDoublewd!*1000) + Int64(nowDoublewd!/1000)
            let paramwd = "\(milliswd)"
            apc.append(PT.EINBAUDATUM.rawValue, value: paramwd as AnyObject)
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
        let section0 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        let row = FormRowDescriptor(tag: PT.DATUM.rawValue, type: .date, title: "Sonderturnus")
        row.value=Date() as AnyObject?
        section0.rows.append(row)
        form.sections = [section0]
        return form
        
        
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 100)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() 
            showWaiting()
            let apc=getParameterContainer()
            
            let datewd=content[PT.DATUM.rawValue]!
            let nowDoublewd = datewd.timeIntervalSince1970
            let milliswd = Int64(nowDoublewd!*1000) + Int64(nowDoublewd!/1000)
            let paramwd = "\(milliswd)"
            apc.append(PT.DATUM.rawValue, value: paramwd as AnyObject)
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
        let section0 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        var row = FormRowDescriptor(tag: PT.WECHSELDATUM.rawValue, type: .date, title: "Einbaudatum")
        row.value=Date() as AnyObject?
        section0.rows.append(row)
        row = FormRowDescriptor(tag: PT.VORSCHALTGERAET.rawValue, type: .name, title: "Vorschaltgerät")
        row.configuration.cell.appearance = ["textField.textAlignment" : NSTextAlignment.right.rawValue as AnyObject]
        section0.rows.append(row)
        form.sections = [section0]
        return form
    }
    
    override func getPreferredSize()->CGSize {
        return CGSize(width: 500, height: 140)
    }
    
    override func save(){
        if arbeitsprotokoll_id != -1 {
            let content = formVC.form.formValues() 
            showWaiting()
            let apc=getParameterContainer()
            
            let datewd=content[PT.WECHSELDATUM.rawValue]!
            let nowDoublewd = datewd.timeIntervalSince1970
            let milliswd = Int64(nowDoublewd!*1000) + Int64(nowDoublewd!/1000)
            let paramwd = "\(milliswd)"
            apc.append(PT.WECHSELDATUM.rawValue, value: paramwd as AnyObject)
            //------------------
            if let vid=content[PT.VORSCHALTGERAET.rawValue]{
                apc.append(PT.VORSCHALTGERAET.rawValue, value: vid)
            }
            
            CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "ProtokollLeuchteVorschaltgeraetwechsel", params: apc, handler: defaultAfterSaveHandler)
        }
    }
}
