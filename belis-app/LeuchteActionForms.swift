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
        //section0.headerTitle = "Informationen zu den durchgeführten Tätigkeiten"
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.LEUCHTENTYP.rawValue, rowType: .Picker, title: "Leuchtentyp")
        var leuchteTypenArrayById: [String:String]=["1":"L 1.1 AEG Umbau auf HSE","2":"L 1.4E Trilux Hängeleuchte 8771/70 HST EVG", "4":"L 1.5 Seilleuchte THorn 100W","56":"L 1.6 Seilleuchte Phillips 250W"]
        var keys : [String] = []
        for key in leuchteTypenArrayById.keys {
            keys.append(key)
        }
        
        row.configuration[FormRowDescriptor.Configuration.Options] = keys
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            return  leuchteTypenArrayById[value as! String]
            } as TitleFormatterClosure
        
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
    
    override func cancel(){
        print("HELL CANCEL")
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
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.ERDUNG_IN_ORDNUNG.rawValue, rowType: .BooleanSwitch, title: "Erdung in Ordnung")
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.WECHSELDATUM.rawValue, rowType: .Date, title: "Wechseldatum")
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.LEUCHTMITTEL.rawValue, rowType: .Picker, title: "eingesetztes Leuchtmittel")
        var leuchteTypenArrayById: [String:String]=["1":"L 1.1 AEG Umbau auf HSE","2":"L 1.4E Trilux Hängeleuchte 8771/70 HST EVG", "4":"L 1.5 Seilleuchte THorn 100W","56":"L 1.6 Seilleuchte Phillips 250W"]
        var keys : [String] = []
        for key in leuchteTypenArrayById.keys {
            keys.append(key)
        }
        
        row.configuration[FormRowDescriptor.Configuration.Options] = keys
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            return  leuchteTypenArrayById[value as! String]
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
        print("HELL SAVE")
        
    }
    
    override func cancel(){
        print("HELL CANCEL")
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
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.LEUCHTMITTEL.rawValue, rowType: .Picker, title: "eingesetztes Leuchtmittel")
        var leuchteTypenArrayById: [String:String]=["1":"L 1.1 AEG Umbau auf HSE","2":"L 1.4E Trilux Hängeleuchte 8771/70 HST EVG", "4":"L 1.5 Seilleuchte THorn 100W","56":"L 1.6 Seilleuchte Phillips 250W"]
        var keys : [String] = []
        for key in leuchteTypenArrayById.keys {
            keys.append(key)
        }
        row.configuration[FormRowDescriptor.Configuration.Options] = keys
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            return  leuchteTypenArrayById[value as! String]
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
        print("HELL SAVE")
        
    }
    
    override func cancel(){
        print("HELL CANCEL")
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
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.RUNDSTEUEREMPFAENGER.rawValue, rowType: .Picker, title: "Rundsteuerempfänger")
        var leuchteTypenArrayById: [String:String]=["1":"L 1.1 AEG Umbau auf HSE","2":"L 1.4E Trilux Hängeleuchte 8771/70 HST EVG", "4":"L 1.5 Seilleuchte THorn 100W","56":"L 1.6 Seilleuchte Phillips 250W"]
        var keys : [String] = []
        for key in leuchteTypenArrayById.keys {
            keys.append(key)
        }
        row.configuration[FormRowDescriptor.Configuration.Options] = keys
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            return  leuchteTypenArrayById[value as! String]
            } as TitleFormatterClosure
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
    
    override func cancel(){
        print("HELL CANCEL")
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
    
    override func cancel(){
        print("HELL CANCEL")
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
        section0.addRow(row)
        row = FormRowDescriptor(tag: PT.VORSCHALTGERAET.rawValue, rowType: .Picker, title: "Vorschaltgerät")
        var leuchteTypenArrayById: [String:String]=["1":"L 1.1 AEG Umbau auf HSE","2":"L 1.4E Trilux Hängeleuchte 8771/70 HST EVG", "4":"L 1.5 Seilleuchte THorn 100W","56":"L 1.6 Seilleuchte Phillips 250W"]
        var keys : [String] = []
        for key in leuchteTypenArrayById.keys {
            keys.append(key)
        }
        row.configuration[FormRowDescriptor.Configuration.Options] = keys
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            return  leuchteTypenArrayById[value as! String]
            } as TitleFormatterClosure
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
    
    override func cancel(){
        print("HELL CANCEL")
    }}