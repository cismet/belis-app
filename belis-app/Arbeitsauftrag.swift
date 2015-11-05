//
//  Arbeitsauftrag.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Arbeitsauftrag : GeoBaseEntity,CellInformationProviderProtocol, CellDataProvider {
    var angelegtVon:String?
    var angelegtAm: NSDate?
    var nummer: String?
    var protokolle: [Arbeitsprotokoll]?
    var zugewiesenAn: Team?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    override func getType() -> Entity {
        return Entity.ARBEITSAUFTRAEGE
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        angelegtVon <- map["angelegt_von"]
        angelegtAm <- (map["angelegt_am"], DateTransformFromString(format: "yyyy-MM-dd"))
        nummer <- map["nummer"]
        protokolle <- map["ar_protokolle"]
        zugewiesenAn <- map["zugewiesen_an"]
        
        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <- map["ausdehnung_wgs84"]
    }
    
    // MARK: - CellInformationProviderProtocol
    
    func getMainTitle() -> String{
        if let nr = nummer {
            return "A\(nr)"
        }
        else {
            return "A???"
        }
    }
    func getSubTitle() -> String{
        if let dat = angelegtAm {
            return dat.toDateString()
        }
        else {
            return "-"
        }
    }
    func getTertiaryInfo() -> String{
        if let von = angelegtVon {
            return von
        }
        return "-"
    }
    func getQuaternaryInfo() -> String{
        if let prot=protokolle {
            return "\(prot.count)"
        }
        return "?"
    }
    
    
    
    override func getAnnotationTitle() -> String{
        return "\(getMainTitle()) - \(getSubTitle())"
    }
    
    override func canShowCallout() -> Bool{
        return true;
    }
    
    override func getAnnotationCalloutGlyphIconName() -> String {
        return "icon-line";
    }
    
    
    @objc func getTitle() -> String {
        return "Arbeitsauftrag"
    }
    
    @objc func getDetailGlyphIconString() -> String {
        return "icon-switch"
    }

    
    @objc func getAllData() -> [String: [CellData]] {    
        var data: [String: [CellData]] = ["main":[]]
        data["main"]?.append(SingleTitledInfoCellData(title: "Nummer",data: getMainTitle()))
        data["DeveloperInfo"]=[]
        data["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))
        return data
    }
    @objc func getDataSectionKeys() -> [String] {
        return ["main","DeveloperInfo"]
    }
    
}

class Team : BaseEntity {
    var name: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        name <- map["name"]
    }
}
