//
//  Leitung.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Leitung : GeoBaseEntity ,CellInformationProviderProtocol, CellDataProvider,ActionProvider, DocumentContainer, ObjectActionProvider {
    var material: Leitungsmaterial?
    var leitungstyp: Leitungstyp?
    var querschnitt: Querschnitt?
    var dokumente: [DMSUrl] = []
    var laenge: Float?

    // MARK: - required init because of ObjectMapper
    required init?(map: Map) {
        super.init(map: map)
    }
    
    // MARK: - essential overrides BaseEntity
    override func getType() -> Entity {
        return Entity.LEITUNGEN
    }
    override func mapping(map: Map) {
        id <- map["id"];
        material <- map["fk_material"];
        leitungstyp <- map["fk_leitungstyp"];
        querschnitt <- map["fk_querschnitt"];
        dokumente <- map["dokumente"]
        laenge <- map["laenge"]

        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <- map["fk_geom.wgs84_wkt"]
        
        
    }
    
    // MARK: - essential overrides GeoBaseEntity
    override func getAnnotationTitle() -> String{
        return "\(getMainTitle()) - \(getSubTitle())"
    }
    override func canShowCallout() -> Bool{
        return true;
    }
    override func getAnnotationCalloutGlyphIconName() -> String {
        return "icon-line";
    }
    
    // MARK: - CellDataProvider Impl
    @objc func getTitle() -> String {
        return "Leitung"
    }
    @objc func getDetailGlyphIconString() -> String {
        return "icon-line"
    }
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        data["main"]?.append(SimpleInfoCellData(data: leitungstyp?.bezeichnung ?? "Leitung"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Material",data: material?.bezeichnung ?? "-"))
        
        if let a = querschnitt?.groesse {
            data["main"]?.append(SingleTitledInfoCellData(title: "Querschnitt", data: "\(a)mm²"))
        }
        
        if dokumente.count>0 {
            data["Dokumente"]=[]
            for doc in dokumente {
                
                data["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: doc.getTitle(), url: doc.getUrl()))
            }
        }
        data["DeveloperInfo"]=[]
        data["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))

        return data;
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
    func addDocument(_ document: DMSUrl) {
        dokumente.append(document)
    }
   
    // MARK: - CellInformationProviderProtocol Impl
    func getMainTitle() -> String{
        if let mat = leitungstyp?.bezeichnung {
            return mat
        }
        else {
            return "Leitung"
        }
    }
    func getSubTitle() -> String{
        var laengePart: String
        if let len = laenge {
            let rounded=String(format: "%.2f", len)
            laengePart="\(rounded)m"
        }
        else {
            laengePart="?m"
        }
        var aPart:String
        if let a = querschnitt?.groesse {
            aPart = ", \(a)mm²"
        }
        else {
            aPart=""
            
        }
        return "\(laengePart)\(aPart)"
    }
    func getTertiaryInfo() -> String{
        return "\(id)"
    }
    func getQuaternaryInfo() -> String{
        return ""
    }

    // MARK: - ObjectActionProvider impl
    @objc func getAllObjectActions() -> [ObjectAction]{
        return [SonstigesAction()]
    }
}

class Leitungsmaterial : BaseEntity{
    var bezeichnung: String?
    
   
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"]
    }
}

class Querschnitt : BaseEntity {
    var groesse: Float?
    
    override func mapping(map: Map) {
        id <- map["id"];
        groesse <- map["groesse"]
    }
}

class Leitungstyp : BaseEntity{
    var bezeichnung: String?
    
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"]
    }
}

