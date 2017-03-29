//
//  Mauerlasche.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Mauerlasche : GeoBaseEntity, CellInformationProviderProtocol, CellDataProvider,ActionProvider, DocumentContainer, ObjectActionProvider {
    var erstellungsjahr: Int?
    var laufendeNummer: Int?
    var material: Mauerlaschenmaterial?
    var strasse: Strasse?
    var dokumente: [DMSUrl] = []
    var pruefdatum: Date?
    var monteur: String?
    var bemerkung: String?
    var foto: DMSUrl?
    

    
    init(id: Int, laufendeNummer: Int, geoString: String) {
        super.init()
        self.id=id;
        self.laufendeNummer=laufendeNummer;
        self.wgs84WKT=geoString;
    }

    required init?(map: Map) {
        super.init(map: map)
    }

    override func getType() -> Entity {
        return Entity.MAUERLASCHEN
    }

    override func getAnnotationImage(_ status: String?) -> UIImage{
        if let s=status {
            if let color=Arbeitsprotokoll.statusColors[s] {
                return GlyphTools.sharedInstance().getGlyphedAnnotationImage("icon-plaque",color: color);
            }
        }
        return GlyphTools.sharedInstance().getGlyphedAnnotationImage("icon-plaque",fontSize: 5,color: UIColor(red: 167.0/255.0, green: 219.0/255.0, blue: 216.0/255.0, alpha: 0.8));
    }
    
    override func getAnnotationTitle() -> String{
        return getMainTitle();
    }
    
    override func canShowCallout() -> Bool{
        return true;
    }

    override func getAnnotationCalloutGlyphIconName() -> String {
        return "icon-nut";
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        strasse <- map["fk_strassenschluessel"]
        erstellungsjahr <- map["erstellungsjahr"]

        laufendeNummer <- map["laufende_nummer"]
        material <- map["fk_material"]
        strasse <- map["fk_strassenschluessel"]
        dokumente <- map["dokumente"]
        pruefdatum <- (map["pruefdatum"], DateTransformFromMillisecondsTimestamp())
        monteur <- map["monteur"]
        bemerkung <- map["bemerkung"]
        foto <- map["foto"]

        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <- map["fk_geom.wgs84_wkt"]
        
    }
    
    
    // MARK: - CellDataProvider Impl
    @objc func getTitle() -> String {
        return "Mauerlasche"
    }
    
    @objc func getDetailGlyphIconString() -> String {
        return "icon-nut"
    }
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        if let mat=material?.bezeichnung {
            data["main"]?.append(SingleTitledInfoCellData(title: "Material", data: mat))
        }
        data["main"]?.append(SingleTitledInfoCellData(title: "Strasse", data: strasse?.name ?? "-"))
        
        if let jj=erstellungsjahr {
            if let pruefd=pruefdatum {
                data["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Montage",dataLeft: "\(jj)" ,titleRight: "Prüfung",dataRight: "\(pruefd)"))
            }
            else {
                data["main"]?.append(SingleTitledInfoCellData(title: "Montage", data: "\(jj)"))
            }
        }
        else {
            if let pruefd=pruefdatum {
                data["main"]?.append(SingleTitledInfoCellData(title: "Prüfung", data: "\(pruefd.toDateString())"))
            }
        }
        if let m=monteur {
            data["main"]?.append(SingleTitledInfoCellData(title: "Monteur", data: m))
        }
        if let bem=bemerkung {
            data["main"]?.append(MemoTitledInfoCellData(title: "Bemerkung", data: bem))
        }

        data["Dokumente"]=[]

        if let fotodok=foto {
            data["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: fotodok.getTitle(), url: fotodok.getUrl()))
        }
        
        if dokumente.count>0 {
            for doc in dokumente {
                data["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: doc.getTitle(), url: doc.getUrl()))
            }
        }
        
        data["DeveloperInfo"]=[]
        data["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))

        return data
    }
    @objc func getDataSectionKeys() -> [String] {
        return ["main","Dokumente","DeveloperInfo"]
    }
    // Actions 
    @objc func getAllActions() -> [BaseEntityAction] {
        

        var actions:[BaseEntityAction]=[]
        
        actions.append(AddIncidentAction(yourself: self))
        actions.append(TakeFotoAction(yourself: self))
        actions.append(ChooseFotoAction(yourself: self))

        return actions
    }
        
    func addDocument(_ document: DMSUrl) {
        dokumente.append(document)
    }
    
    // MARK: - CellInformationProviderProtocol
    
    func getMainTitle() -> String{
        if let lfdNr = laufendeNummer {
            return "M-\(lfdNr)"
        }
        else {
            return "M"
        }
    }
    func getSubTitle() -> String{
        if let mat = material?.bezeichnung {
            return mat
        }
        else {
            return "Mauerlasche"
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
    
    // MARK: - ObjectActionProvider
    @objc func getAllObjectActions() -> [ObjectAction]{
        return [MauerlaschenPruefungAction(entity: self),SonstigesAction()]
    }
    
    // MARK: - sorter
    override func getSorter()->((GeoBaseEntity,GeoBaseEntity)->Bool) {
        func sorter(a: GeoBaseEntity, b: GeoBaseEntity) -> Bool{
            if let x=a as? Mauerlasche, let y=b as? Mauerlasche {
                if x.strasse?.name ?? "" == y.strasse?.name ?? "" {
                    return x.laufendeNummer ?? 0 < y.laufendeNummer ?? 0
                }
                else {
                    return x.strasse?.name ?? "" < y.strasse?.name ?? ""
                }
            }
            log.warning("GeoBaseEntity is no Mauerlasche. Will use the id to sort")
            return a.id<b.id
        }
        return sorter;
    }

    
}

class Mauerlaschenmaterial : BaseEntity{
    var bezeichnung: String?
    
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"];
    }

    
}
