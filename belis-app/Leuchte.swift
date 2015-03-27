//
//  Leuchte.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Leuchte : GeoBaseEntity, MapperProtocol,CallOutInformationProviderProtocol, CellInformationProviderProtocol {
    var strasse: Strasse?
    var energielieferant: Energielieferant?
    var rundsteuerempfaenger: Rundsteuerempfaenger?
    var typ: LeuchtenTyp?
    var unterhaltspflicht_leuchte: Unterhaltspflicht?
    var zaehler: Bool?
    var dk1: Doppelkommando?
    var dk2: Doppelkommando?
    var inbetriebnahme_leuchte: NSDate?
    var lfd_nummer: Int?
    var standort : Standort?;
    var kennziffer: Kennziffer?
    var leuchtennummer: Int?
    var montagefirma_leuchte: String?
    var schaltstelle: String?
    var anzahl_1dk: Int?
    var anzahl_2dk: Int?
    var stadtbezirk: Bezirk?
    var bemerkungen: String?
    var dokumente: [DMSUrl] = []
    var anschlussleistung_1dk: Float?
    var anschlussleistung_2dk: Float?
    var kabeluebergangskasten_sk_ii: Bool?
    var leuchtmittel: Leuchtmittel?
    var lebensdauer: Float?
    var wechseldatum: NSDate?
    var wartungszyklus: NSDate?
    var wechselvorschaltgeraet: NSDate?
    var naechster_wechsel: NSDate?
    var vorschaltgeraet: String?
    var monteur: String?
    var einbaudatum: NSDate?
    
    override func map(mapper: Mapper) {
        id <= mapper["id"];
        strasse <= mapper["fk_strassenschluessel"]
        energielieferant <= mapper["fk_energielieferant"]
        rundsteuerempfaenger <= mapper["rundsteuerempfaenger"]
        typ <= mapper["fk_leuchttyp"]
        unterhaltspflicht_leuchte <= mapper["fk_unterhaltspflicht_leuchte"]
        zaehler <= mapper["zaehler"]
        dk1 <= mapper["fk_dk1"]
        dk2 <= mapper["fk_dk2"]
        inbetriebnahme_leuchte <= mapper["inbetriebnahme_leuchte"]
        lfd_nummer <= mapper["lfd_nummer"]
        standort  <= mapper["fk_standort"]
        kennziffer <= mapper["fk_kennziffer"]
        leuchtennummer <= mapper["leuchtennummer"]
        montagefirma_leuchte <= mapper["montagefirma_leuchte"]
        schaltstelle <= mapper["schaltstelle"]
        anzahl_1dk <= mapper["anzahl_1dk"]
        anzahl_2dk <= mapper["anzahl_2dk"]
        stadtbezirk <= mapper["fk_stadtbezirk"]
        bemerkungen <= mapper["bemerkungen"]
        dokumente <= mapper["dokumente"]
        anschlussleistung_1dk <= mapper["anschlussleistung_1dk"]
        anschlussleistung_2dk <= mapper["anschlussleistung_2dk"]
        kabeluebergangskasten_sk_ii <= mapper["kabeluebergangskasten_sk_ii"]
        leuchtmittel <= mapper["leuchtmittel"]
        lebensdauer <= mapper["lebensdauer"]
        wechseldatum <= mapper["wechseldatum"]
        wartungszyklus <= mapper["wartungszyklus"]
        wechselvorschaltgeraet <= mapper["wechselvorschaltgeraet"]
        naechster_wechsel <= mapper["naechster_wechsel"]
        vorschaltgeraet <= mapper["vorschaltgeraet"]
        monteur <= mapper["monteur"]
        einbaudatum <= mapper["einbaudatum"]

        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <= mapper["fk_standort.fk_geom.wgs84_wkt"]
        
        //fill GUI Cell Data 
        data["main"]?.append(SimpleInfoCellData(data: "Trilux Seilleuchte 58W"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Strasse", data: "Bredde"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Energielieferant", data: "WSW"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Schaltstelle", data: "L4N"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Montagefirma", data: "SAG"))
        data["main"]?.append(MemoTitledInfoCellData(title: "Bemerkung", data: "Damit Ihr indess erkennt, woher dieser ganze Irrthum gekommen ist, und weshalb man die Lust anklagt und den Schmerz lobet, so will ich Euch Alles eröffnen und auseinander setzen, was jener Begründer der Wahrheit und gleichsam Baumeister des glücklichen Lebens selbst darüber gesagt hat. Niemand, sagt er, verschmähe, oder hasse, oder fliehe die Lust als solche, sondern weil grosse Schmerzen ihr folgen, wenn man nicht mit Vernunft ihr nachzugehen verstehe. Ebenso werde der Schmerz als solcher von Niemand geliebt, gesucht und verlangt, sondern weil mitunter solche Zeiten eintreten, dass man mittelst Arbeiten und Schmerzen eine grosse Lust sich zu verschaften suchen müsse. Um hier gleich bei dem Einfachsten stehen zu bleiben, so würde Niemand von uns anstrengende körperliche Uebungen vornehmen, wenn er nicht einen Vortheil davon erwartete. Wer dürfte aber wohl Den tadeln, der nach einer Lust verlangt, welcher keine Unannehmlichkeit folgt, oder der einem Schmerze ausweicht, aus dem keine Lust hervorgeht?"))
        
        data["Dokumente"]=[]
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Skizze"))
        data["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: "Testbild", url: "http://lorempixel.com/300/400/sports/"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan 2"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan 3"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan 4"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan 5"))
        data["Dokumente"]?.append(SimpleInfoCellData(data: "Schaltplan 6"))
    }
    
    
    
    required init(){
        super.init();
    }
    
    override func getAnnotationImageName() -> String{
        return "leuchte.png";
    }
    
    override func getAnnotationTitle() -> String{
        return getMainTitle();
    }
    
    override func canShowCallout() -> Bool{
        return true
    }
    override func getAnnotationCalloutGlyphIconName() -> String {
        return "icon-ceilinglight"
    }

    
    func getTitle() -> String {
        return getAnnotationTitle()
    }
    func getGlyphIconName() -> String {
         return "icon-ceilinglight"
    }
    
    func getDetailViewID() -> String{
         return "LeuchtenDetails"
    }

    func canShowDetailInformation() -> Bool{
        return true
    }
    
    
    // CellInformationProviderProtocol
    
    func getMainTitle() -> String{
        var typPart:String
        if let typKey = typ?.leuchtenTyp {
            typPart = typKey
        } else {
            typPart = "Leuchte"
        }
        var nrPart:String
        if let lnInt = leuchtennummer? {
            nrPart = "-\(lnInt)"
        }
        else {
            nrPart = "-0"
        }
        var standortPart:String
        if let snrInt = standort?.laufendeNummer {
            standortPart=", \(snrInt)"
        }
        else {
            standortPart=""
        }
        
        return "\(typPart)\(nrPart)\(standortPart)"
    }
    func getSubTitle() -> String{
        if let typBez = typ?.fabrikat? {
            return typBez
        }
        else {
            return "-ohne Fabrikat-"
        }
    }
    func getTertiaryInfo() -> String{
        if let str = strasse?.name {
            return str
        }
        return "-"
    }
    func getQuaternaryInfo() -> String{
        return ""
    }

    
}

class Strasse : BaseEntity, MapperProtocol{
    var name: String?
    var key: String?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        name <= mapper["strasse"]
        key <= mapper["pk"]
    }
}

class Energielieferant : BaseEntity, MapperProtocol{
    var energielieferant: String?
    var key: Int?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        energielieferant <= mapper["energielieferant"]
        key <= mapper["pk"]
    }
}

class Rundsteuerempfaenger : BaseEntity, MapperProtocol{
    var herrsteller_rs: String?
    var rs_typ: String?
    var anschlusswert: Float?
    var programm: String?
    var foto: DMSUrl?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        herrsteller_rs <= mapper["herrsteller_rs"]
        rs_typ <= mapper["rs_typ"]
        anschlusswert <= mapper["anschlusswert"]
        programm <= mapper["programm"]
        foto <= mapper["foto"]
    }
}

class LeuchtenTyp : BaseEntity, MapperProtocol{
    var leuchtenTyp: String?
    var bestueckung: Float?
    var leistung: Float?
    var leistung_brutto: Float?
    var fabrikat: String?
    var lampe: String?
    var leistung2stufe: Float?
    var vorschaltgeraet: String?
    var einbau_vorschaltgeraet: NSDate?
    var leistung_reduziert: Float?
    var leistung_brutto_reduziert: Float?
    var foto: DMSUrl?
    var dokumente: [DMSUrl] = []
    var typenbezeichnung: String?
    
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        leuchtenTyp <= mapper["leuchtentyp"]
        bestueckung <= mapper["bestueckung"]
        leistung <= mapper["leistung"]
        leistung_brutto <= mapper["leistung_brutto"]
        fabrikat <= mapper["fabrikat"]
        lampe <= mapper["lampe"]
        leistung2stufe <= mapper["leistung2stufe"]
        vorschaltgeraet <= mapper["vorschaltgeraet"]
        einbau_vorschaltgeraet <= mapper["einbau_vorschaltgeraet"]
        leistung_reduziert <= mapper["leistung_reduziert"]
        leistung_brutto_reduziert <= mapper["leistung_brutto_reduziert"]
        foto <= mapper["foto"]
        dokumente <= mapper["dokumente"]
        typenbezeichnung <= mapper["typenbezeichnung"]
    }
}

class Unterhaltspflicht : BaseEntity, MapperProtocol{
    var unterhaltspflichtiger: String?
    var key: Int?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        unterhaltspflichtiger <= mapper["unterhaltspflichtiger_leuchte"]
        key <= mapper["pk"]
    }
}

class Doppelkommando : BaseEntity, MapperProtocol{
    var key: String?
    var beschreibung: String?
    
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        beschreibung <= mapper["beschreibung"]
        key <= mapper["pk"]
    }
}

class Kennziffer : BaseEntity, MapperProtocol{
    var beschreibung: String?
    var kennziffer: Int?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        beschreibung <= mapper["beschreibung"]
        kennziffer <= mapper["kennziffer"]
    }
}


class Leuchtmittel : BaseEntity, MapperProtocol{
    var hersteller: String?
    var lichtfarbe: String?
    
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        hersteller <= mapper["hersteller"]
        lichtfarbe <= mapper["lichtfarbe"]
    }
}


