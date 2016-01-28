//
//  Standort.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class Standort: GeoBaseEntity ,  CellInformationProviderProtocol, CellDataProvider,ActionProvider, DocumentContainer, ObjectActionProvider{
    var plz : String?
    var strasse : Strasse?
    var bezirk : Stadtbezirk?
    var mastart : Mastart?
    var klassifizierung: Mastklassifizierung?
    var mastanstrich: NSDate?
    var mastschutz: NSDate?
    var unterhaltspflicht: MastUnterhaltspflicht?
    var typ: Masttyp?
    var inbetriebnahme: NSDate?
    var verrechnungseinheit: Bool?
    var letzteAenderung: NSDate?
    var istVirtuellerStandort: Bool?
    var bemerkung: String?
    var montagefirma: String?
    var standortangabe: String?
    var kennziffer: MastKennziffer?
    var lfdNummer: Int?
    var hausnummer: String?
    var dokumente: [DMSUrl] = []
    var gruendung: String?
    var elektrischePruefung: NSDate?
    var erdung: Bool?
    var monteur: String?
    var standsicherheitspruefung: NSDate?
    var verfahrenSHP: String?
    var foto: DMSUrl?
    var naechstesPruefdatum: NSDate?
    var anstrichfrabe: String?
    var revision: NSDate?
    var anlagengruppe: MastAnlagengruppe?
    var anbauten: String?
    
    // MARK: - required init because of ObjectMapper
    required init?(_ map: Map) {
        super.init(map)
    }
    
    // MARK: - essential overrides BaseEntity
    override func getType() -> Entity {
        return Entity.MASTEN
    }
    override func mapping(map: Map) {
        super.id <- map["id"];
        plz  <- map["plz"]
        strasse  <- map["fk_strassenschluessel"]
        bezirk  <- map["fk_stadtbezirk"]
        mastart  <- map["fk_mastart"]
        klassifizierung <- map["fk_klassifizierung"]
        mastanstrich <- (map["mastanstrich"], DateTransformFromMillisecondsTimestamp())
        mastschutz <- (map["mastschutz"], DateTransformFromMillisecondsTimestamp())
        unterhaltspflicht <- map["fk_unterhaltspflicht_mast"]
        typ <- map["fk_masttyp"]
        inbetriebnahme <- (map["inbetriebnahme_mast"], DateTransformFromMillisecondsTimestamp())
        verrechnungseinheit <- map["verrechnungseinheit"]
        letzteAenderung <- (map["letzte_aenderung"], DateTransformFromMillisecondsTimestamp())
        istVirtuellerStandort <- map["ist_virtueller_standort"]
        bemerkung <- map["bemerkungen"]
        montagefirma <- map["montagefirma"]
        standortangabe <- map["standortangabe"]
        kennziffer <- map["fk_kennziffer"]
        lfdNummer <- map["lfd_nummer"]
        hausnummer <- map["haus_nr"]
        dokumente <- map["dokumente"]
        gruendung <- map["gruendung"]
        elektrischePruefung <- (map["elek_pruefung"], DateTransformFromMillisecondsTimestamp())
        erdung <- map["erdung"]
        monteur <- map["monteur"]
        standsicherheitspruefung <- (map["standsicherheitspruefung"], DateTransformFromMillisecondsTimestamp())
        verfahrenSHP <- map["verfahren"]
        foto <- map["foto"]
        naechstesPruefdatum <- (map["naechstes_pruefdatum"], DateTransformFromMillisecondsTimestamp())
        anstrichfrabe <- map["anstrichfarbe"]
        revision <- (map["revision"], DateTransformFromMillisecondsTimestamp())
        anlagengruppe <- map["anlagengruppe"]
        anbauten <- map["anbauten"]
        
        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <- map["fk_geom.wgs84_wkt"]
        
    }
    
    // MARK: - essential overrides GeoBaseEntity
    override func getAnnotationImage(status: String?) -> UIImage{
        if let s=status {
            if let color=Arbeitsprotokoll.statusColors[s] {
                return GlyphTools.sharedInstance().getGlyphedAnnotationImage("icon-circlerecord",color: color);
            }
        }
        return GlyphTools.sharedInstance().getGlyphedAnnotationImage("icon-circlerecord");
    }
    override func getAnnotationTitle() -> String{
        return getMainTitle();
    }
    override func canShowCallout() -> Bool{
        return true
    }
    override func getAnnotationCalloutGlyphIconName() -> String {
        return "icon-horizontalexpand"
    }

    // MARK: - CellInformationProviderProtocol Impl
    func getMainTitle() -> String{
        var standortPart:String
        if let snrInt = lfdNummer {
            standortPart="\(snrInt)"
        }
        else {
            standortPart=""
        }
        
        return "Mast - \(standortPart)"
    }
    func getSubTitle() -> String{
        if let artBez = mastart?.name {
            return artBez
        }
        else {
            return "-ohne Mastart-"
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
    
    
    // MARK: - CallOutInformationProviderProtocol Impl
    func getCallOutTitle() -> String {
        return getAnnotationTitle()
    }
    func getGlyphIconName() -> String {
        return "icon-horizontalexpand"
    }
    func getDetailViewID() -> String{
        return "StandortDetails"
    }
    func canShowDetailInformation() -> Bool{
        return true
    }
    
    // MARK: - CellDataProvider Impl
    @objc func getTitle() -> String {
        return "Mast"
    }
    @objc func getDetailGlyphIconString() -> String {
        return "icon-horizontalexpand"
    }
    @objc func getAllData() -> [String: [CellData]] {
        var mastDetails: [String: [CellData]] = ["main":[]]
        
        if let ueberschrift=mastart?.name {
            mastDetails["main"]?.append(SimpleInfoCellData(data: ueberschrift))
        }
        
        if let typChecked=typ?.typ {
            var mastTypDetails: [String: [CellData]] = ["main":[]]
            mastTypDetails["main"]?.append(SimpleInfoCellData(data: typChecked))
            if let bezeichnung=typ?.bezeichnung {
                mastTypDetails["main"]?.append(SimpleInfoCellData(data: bezeichnung))
                
            }
            
            if let hersteller=typ?.hersteller {
                mastTypDetails["main"]?.append(SingleTitledInfoCellData(title: "Hersteller", data: hersteller))
                
            }
            if let lph=typ?.lph {
                mastTypDetails["main"]?.append(SingleTitledInfoCellData(title: "Lph", data: "\(lph)"))
                
            }
            if let wandstaerke=typ?.wandstaerke {
                mastTypDetails["main"]?.append(SingleTitledInfoCellData(title: "Wandstärke", data: "\(wandstaerke)"))
                
            }
            var docCount=0
            if let foto=typ?.foto {
                mastTypDetails["Dokumente"]=[]
                mastTypDetails["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: "Foto", url: foto.getUrl()))
                docCount=1
            }
            
            
            // zuerst die Dokumente des Typs
            if typ?.dokumente.count>0 {
                if docCount==0 {
                    mastDetails["Dokumente"]=[]
                }
                if let urls=typ?.dokumente {
                    for url in urls {
                        mastTypDetails["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: url.description ?? "Dokument", url: url.getUrl()))
                        docCount++
                    }
                }
            }
            if mastDetails["main"]?.count>1 {
                mastDetails["main"]?.append(SingleTitledInfoCellDataWithDetails(title: "Masttyp", data: typChecked ,details:mastTypDetails, sections: ["main","DeveloperInfo"]))
            }
            else {
                mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Masttyp", data: typChecked))
            }
        }
        
        if let klassifizierung=klassifizierung?.name {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Klassifizierung", data: klassifizierung))
        }
        if let anlagengruppe=anlagengruppe?.bezeichnung {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Anlagengruppe", data: anlagengruppe))
        }
        if let unterhalt=unterhaltspflicht?.name {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Unterhalt", data: unterhalt))
        }
        if let mastschutzChecked=mastschutz {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Mastschutz erneuert am", data: "\(mastschutzChecked.toDateString())"))
        }
        if let inbetriebnahmeChecked=inbetriebnahme {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Inbetriebnahme am", data: "\(inbetriebnahmeChecked.toDateString())"))
        }
        if let lae=letzteAenderung {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Letzte Änderung am", data: "\(lae.toDateString())"))
        }
        if let rev=revision {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Letzte Revision am", data: "\(rev.toDateString())"))
        }
        if let ma=mastanstrich {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Letzter Mastanstrich am", data: "\(ma.toDateString())"))
        }
        if let farbe=anstrichfrabe {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Anstrichfarbe", data: "\(farbe)"))
        }
        if let fa=montagefirma {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Montagefirma", data: "\(fa)"))
        }
        if let ve=verrechnungseinheit {
            if ve {
                mastDetails["main"]?.append(SimpleInfoCellData(data: "Verrechnungseinheit"))
            }
        }
        if let gruendung=gruendung {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Gründung", data: gruendung))
        }
        
        //Prüfungen
        var pruefDetails: [String: [CellData]] = ["main":[]]
        if let eP=elektrischePruefung {
            var erdStr="nein"
            if let erdung=erdung {
                if erdung {
                    erdStr="ja"
                }
            }
            pruefDetails["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Elektrische Pruefung", dataLeft: "\(eP.toDateString())", titleRight: "Erdung", dataRight: erdStr))
        }
        if let pruefer=monteur {
            pruefDetails["main"]?.append(SingleTitledInfoCellData(title: "Elektrische Pruefung durchgeführt von", data: pruefer))
        }
        if let ssp=standsicherheitspruefung {
            if let np=naechstesPruefdatum {
                pruefDetails["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Standsicherheitsprüfung", dataLeft: "\(ssp.toDateString())", titleRight: "Nächster Prüftermin", dataRight: "\(np.toDateString())"))
            }
            else {
                pruefDetails["main"]?.append(SingleTitledInfoCellData(title: "Standsicherheitsprüfung", data: "\(ssp.toDateString())"))
            }
        }
        else if let np=naechstesPruefdatum {
            pruefDetails["main"]?.append(SingleTitledInfoCellData(title: "Nächster Prüftermin", data: "\(np.toDateString())"))
        }
        if let vf=verfahrenSHP {
            pruefDetails["main"]?.append(SingleTitledInfoCellData(title: "Verfahren", data: vf))
            
        }
        
        if pruefDetails["main"]?.count>0 {
            mastDetails["main"]?.append(SimpleInfoCellDataWithDetails(data: "Prüfungen",details: pruefDetails, sections: ["main","DeveloperInfo"]))
            
        }
        //------------------------(PR)
        
        if let anbauten=anbauten {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Anbauten", data: anbauten))
        }
        if let bem=bemerkung {
            mastDetails["main"]?.append(SingleTitledInfoCellData(title: "Bemerkung", data: bem))
        }
        let docCount=0
        if let fotoChecked=foto {
            mastDetails["Dokumente"]=[]
            mastDetails["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: "Foto", url: fotoChecked.getUrl()))
        }
        
        
        if docCount==0 && dokumente.count>0 {
            mastDetails["Dokumente"]=[]
        }
        
        for url in dokumente {
            mastDetails["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: url.description ?? "Dokument", url: url.getUrl()))
        }
        
        mastDetails["DeveloperInfo"]=[]
        mastDetails["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))

        return mastDetails
    }
    @objc func getDataSectionKeys() -> [String] {
        return ["main","Dokumente","DeveloperInfo"]
    }

    // MARK: - ActionProvider Impl
    @objc func getAllActions() -> [BaseEntityAction] {
        
        
        var actions:[BaseEntityAction]=[]
        
        actions.append(TakeFotoAction(yourself: self))
        actions.append(ChooseFotoAction(yourself: self))
        
        return actions
    }
    
    // MARK: - DocumentContainer Impl
    func addDocument(document: DMSUrl) {
        dokumente.append(document)
    }
    
    // MARK: - ObjectActionProvider Impl
    @objc func getAllObjectActions() -> [ObjectAction]{
        return [AnstricharbeitenAction(),ElektrischePruefungAction(),MasterneuerungAction(), MastRevisionAction(),StandsicherheitspruefungAction(), SonstigesAction()]
    }
}

class Stadtbezirk : BaseEntity{
    var name: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        name <- map["bezirk"]
    }
}
class Mastart : BaseEntity{
    var pk: String?
    var name: String?
    
    override func mapping(map: Map) {
        super.id <- map["id"]
        pk <- map["pk"]
        name <- map["mastart"]
    }
}
class Mastklassifizierung : BaseEntity{
    var pk: String?
    var name: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        pk <- map["pk"]
        name <- map["klassifizierung"]
    }
}
class MastUnterhaltspflicht : BaseEntity{
    var pk: String?
    var name: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        pk <- map["pk"]
        name <- map["unterhalt_mast"]
    }
}
class Masttyp : BaseEntity{
    var typ: String?
    var bezeichnung: String?
    var lph: Double?
    var hersteller: String?
    var wandstaerke: Int?
    var dokumente: [DMSUrl] = []
    var foto: DMSUrl?
    
    override func mapping(map: Map) {
        super.id <- map["id"]
        typ <- map["masttyp"]
        bezeichnung <- map["bezeichnung"]
        lph <- map["lph"]
        hersteller <- map["hersteller"]
        wandstaerke <- map["wandstaerke"]
        dokumente <- map["dokumente"]
        foto <- map["foto"]
    }
}

class MastKennziffer : BaseEntity{
    var kennziffer: Int?
    var beschreibung: String?
    
    override func mapping(map: Map) {
        super.id <- map["id"]
        kennziffer <- map["kennziffer"]
        beschreibung <- map["beschreibung"]
    }
}
class MastAnlagengruppe : BaseEntity{
    var nummer: Int?
    var bezeichnung: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        nummer <- map["nummer"]
        bezeichnung <- map["bezeichnung"]
    }
}
