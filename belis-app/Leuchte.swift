//
//  Leuchte.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper
class Leuchte : GeoBaseEntity, Mappable,CallOutInformationProviderProtocol, CellInformationProviderProtocol, CellDataProvider {
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
    var stadtbezirk: Stadtbezirk?
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
    
 
    override func mapping(map: Map) {
        id <- map["id"];
        strasse <- map["fk_strassenschluessel"]
        energielieferant <- map["fk_energielieferant"]
        rundsteuerempfaenger <- map["rundsteuerempfaenger"]
        typ <- map["fk_leuchttyp"]
        unterhaltspflicht_leuchte <- map["fk_unterhaltspflicht_leuchte"]
        zaehler <- map["zaehler"]
        dk1 <- map["fk_dk1"]
        dk2 <- map["fk_dk2"]
        inbetriebnahme_leuchte <- (map["inbetriebnahme_leuchte"], DateTransformFromMillisecondsTimestamp())
        lfd_nummer <- map["lfd_nummer"]
        standort  <- map["fk_standort"]
        kennziffer <- map["fk_kennziffer"]
        leuchtennummer <- map["leuchtennummer"]
        montagefirma_leuchte <- map["montagefirma_leuchte"]
        schaltstelle <- map["schaltstelle"]
        anzahl_1dk <- map["anzahl_1dk"]
        anzahl_2dk <- map["anzahl_2dk"]
        stadtbezirk <- map["fk_stadtbezirk"]
        bemerkungen <- map["bemerkungen"]
        dokumente <- map["dokumente"]
        anschlussleistung_1dk <- map["anschlussleistung_1dk"]
        anschlussleistung_2dk <- map["anschlussleistung_2dk"]
        kabeluebergangskasten_sk_ii <- map["kabeluebergangskasten_sk_ii"]
        leuchtmittel <- map["leuchtmittel"]
        lebensdauer <- map["lebensdauer"]
        wechseldatum <- (map["wechseldatum"], DateTransformFromMillisecondsTimestamp())
        wartungszyklus <- (map["wartungszyklus"], DateTransformFromMillisecondsTimestamp())
        wechselvorschaltgeraet <- (map["wechselvorschaltgeraet"], DateTransformFromMillisecondsTimestamp())
        naechster_wechsel <- (map["naechster_wechsel"], DateTransformFromMillisecondsTimestamp())
        vorschaltgeraet <- map["vorschaltgeraet"]
        monteur <- map["monteur"]
        einbaudatum <- (map["einbaudatum"], DateTransformFromMillisecondsTimestamp())
        
        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <- map["fk_standort.fk_geom.wgs84_wkt"]
        
    }
    override func getType() -> Entity {
        return Entity.LEUCHTEN
    }
    
    //CellDataProvider
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        data["main"]?.append(SimpleInfoCellData(data: getSubTitle()))
        if let inbetriebnahme=inbetriebnahme_leuchte {
            data["main"]?.append(SingleTitledInfoCellData(title: "Inbetriebnahme", data: "\(inbetriebnahme.toDateString())"))
        }
        
        if let strName=standort?.strasse?.name {
            var strDetails: [String: [CellData]] = ["main":[]]
            if let hausnr=standort?.hausnummer {
                strDetails["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Strasse", dataLeft: strName, titleRight: "Hausnummer", dataRight: "\(hausnr)"))
            }
            else {
                strDetails["main"]?.append(SingleTitledInfoCellData(title: "Strasse", data: strName))
                
            }
            
            if let schluessel=standort?.strasse?.key {
                strDetails["main"]?.append(SingleTitledInfoCellData(title: "Schlüssel", data: schluessel))
            }
            if let bez = standort?.bezirk?.name {
                strDetails["main"]?.append(SingleTitledInfoCellData(title: "Stadtbezirk", data: bez))
            }
            if let standortangabe=standort?.standortangabe {
                strDetails["main"]?.append(SingleTitledInfoCellData(title: "Standortangabe", data: standortangabe))
            }

            
            
            if let hausnr=standort?.hausnummer {
                data["main"]?.append(DoubleTitledInfoCellDataWithDetails(titleLeft: "Strasse", dataLeft: strName, titleRight: "Hausnummer", dataRight: "\(hausnr)",details:strDetails))
            }
            else {
                data["main"]?.append(SingleTitledInfoCellDataWithDetails(title: "Strasse", data: strName,details:strDetails))
                
            }
            
            
        }
        
        var mastVorhanden=true //wenn virtueller Standort nil ist, dann bleibt true gesetzt
        if let isVirtStandort=standort?.istVirtuellerStandort {
            mastVorhanden = !isVirtStandort
        }
        
        //Mast
        if mastVorhanden {
            if let s=standort {
                var mastDetails: [String: [CellData]] = s.getAllData()
                data["main"]?.append(SimpleInfoCellDataWithDetails(data: "Mast",details: mastDetails))
            }
            else {
                //serious error
            }
            

        }
        //------------------------(M)
        
        if let energieprov=energielieferant?.name {
            data["main"]?.append(SingleTitledInfoCellData(title: "Energielieferant", data: energieprov))
            
        }
        
        if let schaltS=schaltstelle {
            data["main"]?.append(SingleTitledInfoCellData(title: "Schaltstelle", data: schaltS))
            
        }
        
        if let rse=rundsteuerempfaenger?.rs_typ {
            if let ebd=einbaudatum {
                data["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Rundsteuerempfänger", dataLeft: rse, titleRight: "Einbaudatum", dataRight: "\(ebd.toDateString())"))
            }
            else {
                data["main"]?.append(SingleTitledInfoCellData(title: "Rundsteuerempfänger", data: rse))
            }
        }
        else {
            if let ebd=einbaudatum {
                data["main"]?.append(SingleTitledInfoCellData(title: "Einbaudatum", data: "\(ebd.toDateString())"))
            }
        }
        
        if let uhalt=unterhaltspflicht_leuchte?.unterhaltspflichtiger {
            data["main"]?.append(SingleTitledInfoCellData(title: "Unterhalt", data: uhalt))
        }
        if let zaehler=zaehler {
            if zaehler {
                data["main"]?.append(SimpleInfoCellData(data: "Zähler vorhanden"))
            }
            else {
                data["main"]?.append(SimpleInfoCellData(data: "kein Zähler vorhanden"))
            }
        }
        //Doppelkommandos
        var dkDetails: [String: [CellData]] = ["main":[]]
        if let dk1=dk1?.beschreibung {
            dkDetails["main"]?.append(SingleTitledInfoCellData(title: "Doppelkommando 1", data: dk1))
        }
        if let anzahldk1=anzahl_1dk {
            dkDetails["main"]?.append(SingleTitledInfoCellData(title: "Anzahl Doppelkommando 1", data: "\(anzahldk1)"))
        }
        if let pdk1=anschlussleistung_1dk {
            dkDetails["main"]?.append(SingleTitledInfoCellData(title: "Anschlussleistung DK1", data: "\(pdk1)"))
        }
        if let dk2=dk2?.beschreibung {
            dkDetails["main"]?.append(SingleTitledInfoCellData(title: "Doppelkommando 2", data: dk2))
        }
        if let pdk2=anschlussleistung_2dk {
            dkDetails["main"]?.append(SingleTitledInfoCellData(title: "Anschlussleistung DK2", data: "\(pdk2)"))
        }
        if let anzahldk2=anzahl_2dk {
            dkDetails["main"]?.append(SingleTitledInfoCellData(title: "Anzahl Doppelkommando 2", data: "\(anzahldk2)"))
        }
        if dkDetails["main"]?.count>0 {
            data["main"]?.append(SimpleInfoCellDataWithDetails(data: "Doppelkommandos",details: dkDetails))
        }
        //------------------------(DK)
        
        //Leuchtmittel
        var leuchtmittelDetails: [String: [CellData]] = ["main":[]]
        
        if let lm=leuchtmittel?.hersteller {
            leuchtmittelDetails["main"]?.append(SingleTitledInfoCellData(title: "Leuchtmittel", data: lm))
        }
        if let lichtfarbe=leuchtmittel?.lichtfarbe {
            leuchtmittelDetails["main"]?.append(SingleTitledInfoCellData(title: "Lichtfarbe", data: lichtfarbe))
        }
        if let ld=lebensdauer {
            leuchtmittelDetails["main"]?.append(SingleTitledInfoCellData(title: "Lebensdauer", data: "\(ld)"))
        }
        if let wd=wechseldatum {
            if let nw=naechster_wechsel {
                leuchtmittelDetails["main"]?.append(DoubleTitledInfoCellData(titleLeft: "letzter Leuchtmittelwechsel", dataLeft: "\(wd.toDateString())", titleRight: "nächster Wechsel", dataRight:  "\(nw.toDateString())"))
            }
            else {
                leuchtmittelDetails["main"]?.append(SingleTitledInfoCellData(title: "letzter Leuchtmittelwechsel", data: "\(wd.toDateString())"))
            }
        } else if let nw=naechster_wechsel {
            leuchtmittelDetails["main"]?.append(SingleTitledInfoCellData(title: "nächster Wechsel", data: "\(nw.toDateString())"))
        }
        
        if let sonderturnus=wartungszyklus {
            leuchtmittelDetails["main"]?.append(SingleTitledInfoCellData(title: "Sonderturnus", data: "\(sonderturnus.toDateString())"))
        }
        if leuchtmittelDetails["main"]?.count>0 {
            if let lm=leuchtmittel?.hersteller {
                data["main"]?.append(SingleTitledInfoCellDataWithDetails(title: "Leuchtmittel", data: lm, details: leuchtmittelDetails))
            }
            else {
                data["main"]?.append(SimpleInfoCellDataWithDetails(data: "Leuchtmittel",details: leuchtmittelDetails))
            }
        }
        //------------------------(LM)
        
        //Vorschaltgerät
        var vsgDetails: [String: [CellData]] = ["main":[]]
        if let vsg=vorschaltgeraet {
            vsgDetails["main"]?.append(SingleTitledInfoCellData(title: "Vorschaltgerät", data: vsg))
            if let vsgWe=wechselvorschaltgeraet {
                vsgDetails["main"]?.append(SingleTitledInfoCellData(title: "Erneuerung Vorschaltgerät", data: "\(vsgWe.toDateString())"))
            }
            if vsgDetails["main"]?.count>1 {
                data["main"]?.append(SingleTitledInfoCellDataWithDetails(title: "Vorschaltgerät", data: vsg, details: vsgDetails))
            }
            else {
                data["main"]?.append(SingleTitledInfoCellData(title: "Vorschaltgerät", data: vsg))
            }
            
        }
        //------------------------(VSG)
        if let montagefirma=montagefirma_leuchte {
            data["main"]?.append(SingleTitledInfoCellData(title: "Montagefirma", data: montagefirma))
        }
        if let bem=bemerkungen {
            data["main"]?.append(SingleTitledInfoCellData(title: "Bemerkungen", data: bem))
        }
        
        if dokumente.count>0 {
            data["Dokumente"]=[]
            for url in dokumente {
                data["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: url.description ?? "Dokument", url: url.getUrl()))
            }
        }
        
        
        return data
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
        if let lnInt = leuchtennummer {
            nrPart = "-\(lnInt)"
        }
        else {
            nrPart = "-0"
        }
        var standortPart:String
        if let snrInt = standort?.lfdNummer {
            standortPart=", \(snrInt)"
        }
        else {
            standortPart=""
        }
        
        return "\(typPart)\(nrPart)\(standortPart)"
    }
    func getSubTitle() -> String{
        if let typBez = typ?.fabrikat {
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


class Energielieferant : BaseEntity, Mappable{
    var name: String?
    var key: Int?
    
    override func mapping(map: Map) {
        super.id <- map["id"]
        name <- map["energielieferant"]
        key <- map["pk"]
    }
}

class Rundsteuerempfaenger : BaseEntity, Mappable{
    var herrsteller_rs: String?
    var rs_typ: String?
    var anschlusswert: Float?
    var programm: String?
    var foto: DMSUrl?
    
    override func mapping(map: Map) {
        super.id <- map["id"]
        herrsteller_rs <- map["herrsteller_rs"]
        rs_typ <- map["rs_typ"]
        anschlusswert <- map["anschlusswert"]
        programm <- map["programm"]
        foto <- map["foto"]
    }
}

class LeuchtenTyp : BaseEntity, Mappable{
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

    override func mapping(map: Map) {
        super.id <- map["id"]
        leuchtenTyp <- map["leuchtentyp"]
        bestueckung <- map["bestueckung"]
        leistung <- map["leistung"]
        leistung_brutto <- map["leistung_brutto"]
        fabrikat <- map["fabrikat"]
        lampe <- map["lampe"]
        leistung2stufe <- map["leistung2stufe"]
        vorschaltgeraet <- map["vorschaltgeraet"]
        einbau_vorschaltgeraet <- map["einbau_vorschaltgeraet"]
        leistung_reduziert <- map["leistung_reduziert"]
        leistung_brutto_reduziert <- map["leistung_brutto_reduziert"]
        foto <- map["foto"]
        dokumente <- map["dokumente"]
        typenbezeichnung <- map["typenbezeichnung"]
    }
}

class Unterhaltspflicht : BaseEntity, Mappable{
    var unterhaltspflichtiger: String?
    var key: Int?
    override func mapping(map: Map) {
        super.id <- map["id"]
        unterhaltspflichtiger <- map["unterhaltspflichtiger_leuchte"]
        key <- map["pk"]
    }
}

class Doppelkommando : BaseEntity, Mappable{
    var key: String?
    var beschreibung: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        beschreibung <- map["beschreibung"]
        key <- map["pk"]
    }
}

class Kennziffer : BaseEntity, Mappable{
    var beschreibung: String?
    var kennziffer: Int?
    override func mapping(map: Map) {
        super.id <- map["id"]
        beschreibung <- map["beschreibung"]
        kennziffer <- map["kennziffer"]
    }
}


class Leuchtmittel : BaseEntity, Mappable{
    var hersteller: String?
    var lichtfarbe: String?
    
    override func mapping(map: Map) {
        super.id <- map["id"]
        hersteller <- map["hersteller"]
        lichtfarbe <- map["lichtfarbe"]
    }
}


