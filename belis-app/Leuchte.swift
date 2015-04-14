//
//  Leuchte.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper
class Leuchte : GeoBaseEntity, MapperProtocol,CallOutInformationProviderProtocol, CellInformationProviderProtocol, CellDataProvider {
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
        
    }
    
    func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        data["main"]?.append(SimpleInfoCellData(data: getSubTitle()))
        if let inbetriebnahme=inbetriebnahme_leuchte {
            data["main"]?.append(SingleTitledInfoCellData(title: "Inbetriebnahme", data: "\(inbetriebnahme)"))
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
            
            
            
            if let hausnr=standort?.hausnummer {
                data["main"]?.append(DoubleTitledInfoCellDataWithDetails(titleLeft: "Strasse", dataLeft: strName, titleRight: "Hausnummer", dataRight: "\(hausnr)",details:strDetails))
            }
            else {
                data["main"]?.append(SingleTitledInfoCellDataWithDetails(title: "Strasse", data: strName,details:strDetails))
                
            }
            
        }
        
        var mastVorhanden=true //wenn virtueller Standort nil ist, dann bleibt true gesetzt
        if let isVirtStandort=standort?.istVirtuellerStandort? {
            mastVorhanden = !isVirtStandort
        }
        
        //Mast
        if mastVorhanden {
            var mastDetails: [String: [CellData]] = ["main":[]]
            
            if let ueberschrift=standort?.mastart?.name {
                mastDetails["main"]?.append(SimpleInfoCellData(data: ueberschrift))
            }
            
            if let typ=standort?.typ?.typ {
                var mastTypDetails: [String: [CellData]] = ["main":[]]
                mastTypDetails["main"]?.append(SimpleInfoCellData(data: typ))
                if let bezeichnung=standort?.typ?.bezeichnung {
                    mastTypDetails["main"]?.append(SimpleInfoCellData(data: bezeichnung))
                    
                }
                
                if let hersteller=standort?.typ?.hersteller {
                    mastTypDetails["main"]?.append(SingleTitledInfoCellData(title: "Hersteller", data: hersteller))
                    
                }
                if let lph=standort?.typ?.lph {
                    mastTypDetails["main"]?.append(SingleTitledInfoCellData(title: "Lph", data: "\(lph)"))
                    
                }
                if let wandstaerke=standort?.typ?.wandstaerke {
                    mastTypDetails["main"]?.append(SingleTitledInfoCellData(title: "Wandstärke", data: "\(wandstaerke)"))
                    
                }
                if let foto=standort?.typ?.foto {
                    mastTypDetails["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: "Foto", url: foto.getUrl()))
                }
                
                if let urls=standort?.typ?.dokumente {
                    for url in urls {
                        mastTypDetails["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: url.description ?? "Dokument", url: url.getUrl()))
                    }
                }
                if mastDetails["main"]?.count>1 {
                    mastDetails["main"]?.append(SingleTitledInfoCellDataWithDetails(title: "Masttyp", data: typ,details:mastTypDetails))
                }
                else {
                    mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Masttyp", data: typ))
                }
            }
            
            if let klassifizierung=standort?.klassifizierung?.name {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Klassifizierung", data: klassifizierung))
            }
            if let anlagengruppe=standort?.anlagengruppe?.bezeichnung {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Anlagengruppe", data: anlagengruppe))
            }
            if let unterhalt=standort?.unterhaltspflicht?.name {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Unterhalt", data: unterhalt))
            }
            if let mastschutz=standort?.mastschutz {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Mastschutz erneuert am", data: "\(mastschutz)"))
            }
            if let inbetriebnahme=standort?.inbetriebnahme {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Inbetriebnahme am", data: "\(inbetriebnahme)"))
            }
            if let lae=standort?.letzteAenderung {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Letzte Änderung am", data: "\(lae)"))
            }
            if let rev=standort?.revision {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Letzte Revision am", data: "\(rev)"))
            }
            if let ma=standort?.mastanstrich {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Letzter Mastanstrich am", data: "\(ma)"))
            }
            if let farbe=standort?.anstrichfrabe {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Anstrichfarbe", data: "\(farbe)"))
            }
            if let fa=standort?.montagefirma {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Montagefirma", data: "\(fa)"))
            }
            if let ve=standort?.verrechnungseinheit {
                if ve {
                    mastDetails["main"]?.append(SimpleInfoCellData(data: "Verrechnungseinheit"))
                }
            }
            if let gruendung=standort?.gruendung {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Gründung", data: gruendung))
            }
            
            //Prüfungen
            var pruefDetails: [String: [CellData]] = ["main":[]]
            if let eP=standort?.elektrischePruefung {
                var erdStr="nein"
                if let erdung=standort?.erdung {
                    if erdung {
                        erdStr="ja"
                    }
                }
                pruefDetails["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Elektrische Pruefung", dataLeft: "\(eP)", titleRight: "Erdung", dataRight: erdStr))
            }
            if let pruefer=standort?.monteur {
                pruefDetails["main"]?.append(SingleTitledInfoCellData(title: "Elektrische Pruefung durchgeführt von", data: pruefer))
            }
            if let ssp=standort?.standsicherheitspruefung {
                if let np=standort?.naechstesPruefdatum {
                    pruefDetails["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Standsicherheitsprüfung", dataLeft: "\(ssp)", titleRight: "Nächster Prüftermin", dataRight: "\(np)"))
                }
                else {
                    pruefDetails["main"]?.append(SingleTitledInfoCellData(title: "Standsicherheitsprüfung", data: "\(ssp)"))
                }
            }
            else if let np=standort?.naechstesPruefdatum {
                pruefDetails["main"]?.append(SingleTitledInfoCellData(title: "Nächster Prüftermin", data: "\(np)"))
            }
            if let vf=standort?.verfahrenSHP {
                pruefDetails["main"]?.append(SingleTitledInfoCellData(title: "Verfahren", data: vf))
                
            }
            
            if pruefDetails["main"]?.count>0 {
                data["main"]?.append(SimpleInfoCellDataWithDetails(data: "Prüfungen",details: pruefDetails))
                
            }
            //------------------------(PR)
            
            if let anbauten=standort?.anbauten {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Anbauten", data: anbauten))
            }
            if let bem=standort?.bemerkung {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Bemerkung", data: bem))
            }
            
            if let foto=standort?.foto {
                data["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: "Foto", url: foto.getUrl()))
            }
            
            if let urls=standort?.dokumente {
                for url in urls {
                    data["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: url.description ?? "Dokument", url: url.getUrl()))
                }
            }
            
            data["main"]?.append(SimpleInfoCellDataWithDetails(data: "Mast",details: mastDetails))
        }
        //------------------------(M)
        
        if let energieprov=energielieferant?.name {
            data["main"]?.append(SingleTitledInfoCellData(title: "Energielieferant", data: energieprov))
            
        }
        
        if let schaltS=schaltstelle {
            data["main"]?.append(SingleTitledInfoCellData(title: "Schaltstelle", data: schaltS))
            
        }
        
        if let rse=rundsteuerempfaenger?.rs_typ {
            if let ebd=einbaudatum? {
                data["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Rundsteuerempfänger", dataLeft: rse, titleRight: "Einbaudatum", dataRight: "\(ebd)"))
            }
            else {
                data["main"]?.append(SingleTitledInfoCellData(title: "Rundsteuerempfänger", data: rse))
            }
        }
        else {
            if let ebd=einbaudatum? {
                data["main"]?.append(SingleTitledInfoCellData(title: "Einbaudatum", data: "\(ebd)"))
            }
        }
        
        if let uhalt=unterhaltspflicht_leuchte?.unterhaltspflichtiger {
            data["main"]?.append(SingleTitledInfoCellData(title: "Unterhalt", data: uhalt))
        }
        if let zaehler=zaehler? {
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
        if let pdk1=anschlussleistung_1dk? {
            dkDetails["main"]?.append(SingleTitledInfoCellData(title: "Anschlussleistung DK1", data: "\(pdk1)"))
        }
        if let dk2=dk2?.beschreibung {
            dkDetails["main"]?.append(SingleTitledInfoCellData(title: "Doppelkommando 2", data: dk2))
        }
        if let pdk2=anschlussleistung_2dk? {
            dkDetails["main"]?.append(SingleTitledInfoCellData(title: "Anschlussleistung DK2", data: "\(pdk2)"))
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
        if let ld=lebensdauer? {
            leuchtmittelDetails["main"]?.append(SingleTitledInfoCellData(title: "Lebensdauer", data: "\(ld)"))
        }
        if let wd=wechseldatum? {
            if let nw=naechster_wechsel? {
                leuchtmittelDetails["main"]?.append(DoubleTitledInfoCellData(titleLeft: "letzter Leuchtmittelwechsel", dataLeft: "\(wd)", titleRight: "nächster Wechsel", dataRight:  "\(nw)"))
            }
            else {
                leuchtmittelDetails["main"]?.append(SingleTitledInfoCellData(title: "letzter Leuchtmittelwechsel", data: "\(wd)"))
            }
        } else if let nw=naechster_wechsel? {
            leuchtmittelDetails["main"]?.append(SingleTitledInfoCellData(title: "nächster Wechsel", data: "\(nw)"))
        }
        
        if let sonderturnus=wartungszyklus? {
            leuchtmittelDetails["main"]?.append(SingleTitledInfoCellData(title: "Sonderturnus", data: "\(sonderturnus)"))
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
        if let vsg=vorschaltgeraet? {
            vsgDetails["main"]?.append(SingleTitledInfoCellData(title: "Vorschaltgerät", data: vsg))
            if let vsgWe=wechselvorschaltgeraet? {
                vsgDetails["main"]?.append(SingleTitledInfoCellData(title: "Erneuerung Vorschaltgerät", data: "\(vsgWe)"))
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
        
        
        for url in dokumente {
            data["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: url.description ?? "Dokument", url: url.getUrl()))
        }
        
        
        return data
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
        if let snrInt = standort?.lfdNummer {
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


class Energielieferant : BaseEntity, MapperProtocol{
    var name: String?
    var key: Int?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        name <= mapper["energielieferant"]
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


