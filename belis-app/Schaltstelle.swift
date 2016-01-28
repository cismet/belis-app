//
//  Schaltstelle.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Schaltstelle : GeoBaseEntity ,  CellInformationProviderProtocol,CallOutInformationProviderProtocol,CellDataProvider,ActionProvider, DocumentContainer, ObjectActionProvider{
    
    var erstellungsjahr: NSDate?
    var laufendeNummer: Int?
    var bauart: Schaltstellenbauart?
    var strasse: Strasse?
    var bemerkung: String?
    var schaltstellenNummer: String?
    var zusaetzlicheStandortbezeichnung: String?
    var hausnummer: String?
    var dokumente: [DMSUrl]=[]
    var pruefdatum: NSDate?
    var foto: DMSUrl?
    var monteur: String?
    var rundsteuerempfaenger: Rundsteuerempfaenger?
    var einbaudatumRundsteuerempfaenger: NSDate?
    
    // MARK: - required init because of ObjectMapper
    required init?(_ map: Map) {
        super.init(map)
    }

    // MARK: - essential overrides BaseEntity
    override func getType() -> Entity {
        return Entity.SCHALTSTELLEN
    }
    override func mapping(map: Map) {
        super.id <- map["id"];
        erstellungsjahr <- (map["erstellungsjahr"],DateTransformFromMillisecondsTimestamp())
        laufendeNummer <- map["laufende_nummer"]
        bauart <- map["fk_bauart"]
        strasse <- map["fk_strassenschluessel"]
        bemerkung <- map["bemerkung"]
        schaltstellenNummer <- map["schaltstellen_nummer"]
        zusaetzlicheStandortbezeichnung <- map["zusaetzliche_standortbezeichnung"]
        hausnummer <- map["haus_nummer"]
        dokumente <- map["dokumente"]
        pruefdatum <- (map["pruefdatum"], DateTransformFromMillisecondsTimestamp())
        foto <- map["foto"]
        monteur <- map["monteur"]
        rundsteuerempfaenger <- map["rundsteuerempfaenger"]
        einbaudatumRundsteuerempfaenger <- (map["einbaudatum_rs"], DateTransformFromMillisecondsTimestamp())
        
        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <- map["fk_geom.wgs84_wkt"]

    }

    // MARK: - essential overrides GeoBaseEntity
    override func getAnnotationImage(status: String?) -> UIImage{
        if let s=status {
            if let color=Arbeitsprotokoll.statusColors[s] {
                return GlyphTools.sharedInstance().getGlyphedAnnotationImage("icon-squarepause",color: color);
            }
        }
        return GlyphTools.sharedInstance().getGlyphedAnnotationImage("icon-squarepause");
    }
    override func getAnnotationTitle() -> String{
        return getMainTitle();
    }
    override func canShowCallout() -> Bool{
        return true
    }
    override func getAnnotationCalloutGlyphIconName() -> String {
        return "icon-switch"
    }

    // MARK: - CellInformationProviderProtocol Impl
    func getMainTitle() -> String{
        var s=""
        
        if let bauartBez=bauart?.bezeichnung {
            s=bauartBez
        }
        else {
            s="Schaltstelle"
        }
        
        if let nr=schaltstellenNummer {
            s=s+" - \(nr)"
        }
        return s
    }
    func getSubTitle() -> String{
        return "-"
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
    func getCalloutTitle() -> String {
        return getAnnotationTitle()
    }
    func getGlyphIconName() -> String {
        return "icon-switch"
    }
    func getDetailViewID() -> String{
        return "SchaltstelleDetails"
    }
    func canShowDetailInformation() -> Bool{
        return true
    }
    
    // MARK: - CellDataProvider Impl
    @objc func getTitle() -> String {
        return "Schaltstelle"
    }
    @objc func getDetailGlyphIconString() -> String {
        return "icon-switch"
    }
    @objc func getAllData() -> [String: [CellData]] {
        var details: [String: [CellData]] = ["main":[]]
        details["main"]?.append(SimpleInfoCellData(data: getMainTitle()))
        
        //Laufende Nummer
        
        //Strasse
        if let strName=strasse?.name {
            var strDetails: [String: [CellData]] = ["main":[]]
            
            if let hausnr=hausnummer {
                strDetails["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Strasse", dataLeft: strName, titleRight: "Hausnummer", dataRight: "\(hausnr)"))
            }
            else {
                strDetails["main"]?.append(SingleTitledInfoCellData(title: "Strasse", data: strName))
                
            }
            
            if let schluessel=strasse?.key {
                strDetails["main"]?.append(SingleTitledInfoCellData(title: "Schlüssel", data: schluessel))
            }
            
            if let standortangabe=zusaetzlicheStandortbezeichnung {
                strDetails["main"]?.append(SingleTitledInfoCellData(title: "Standortangabe", data: standortangabe))
            }
            
            if let hausnr=hausnummer {
                details["main"]?.append(DoubleTitledInfoCellDataWithDetails(titleLeft: "Strasse", dataLeft: strName, titleRight: "Hausnummer", dataRight: "\(hausnr)",details:strDetails, sections: ["main","DeveloperInfo"]))
            }
            else {
                details["main"]?.append(SingleTitledInfoCellDataWithDetails(title: "Strasse", data: strName,details:strDetails, sections:["main","DeveloperInfo"]))
            }
        }
        
        //Erstellungsjahr
        if let erst=erstellungsjahr {
            details["main"]?.append(SingleTitledInfoCellData(title: "Erstellungsjahr", data: erst.toDateString()))
        }
        
        //Prüfdatum
        if let pruef=pruefdatum {
            details["main"]?.append(SingleTitledInfoCellData(title: "Prüfdatum", data: pruef.toDateString()))
        }

        //Monteur
        if let mont=monteur {
            details["main"]?.append(SingleTitledInfoCellData(title: "Monteur", data: mont))
        }

        
        //Schaltstellennummer
        if let snr=schaltstellenNummer {
            details["main"]?.append(SingleTitledInfoCellData(title: "Schaltstellennummer", data: "\(snr)"))
        }


        //Rundsteuerempfänger + Einbaudatum
        
        if let rse=rundsteuerempfaenger?.rs_typ {
            if let ebd=einbaudatumRundsteuerempfaenger {
                details["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Rundsteuerempfänger", dataLeft: rse, titleRight: "Einbaudatum", dataRight: "\(ebd.toDateString())"))
            }
            else {
                details["main"]?.append(SingleTitledInfoCellData(title: "Rundsteuerempfänger", data: rse))
            }
        }

        //Bemerkung
        if let bem=bemerkung {
            details["main"]?.append(SingleTitledInfoCellData(title: "Bemerkung", data: bem))
        }
        

        //Dokumente

        var docCount=0
        if let fotoChecked=foto {
            details["Dokumente"]=[]
            details["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: "Foto", url: fotoChecked.getUrl()))
            docCount=1
        }
        
        
        if docCount==0 && dokumente.count>0 {
            details["Dokumente"]=[]
        }
        
        for url in dokumente {
            details["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: url.description ?? "Dokument", url: url.getUrl()))
        }
        details["DeveloperInfo"]=[]
        details["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))

        return details
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
        return [SchaltstellenRevisionAction(),SonstigesAction()]
    }
}


class Schaltstellenbauart: BaseEntity {
    var bezeichnung: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        bezeichnung <- map["bezeichnung"]
    }
}