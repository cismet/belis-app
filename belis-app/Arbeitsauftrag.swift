//
//  Arbeitsauftrag.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Arbeitsauftrag : GeoBaseEntity,CellInformationProviderProtocol {
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
        angelegtVon <- map["angelegt_von"];
        angelegtAm <- map["angelegt_am"];
        nummer <- map["nummer"];
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
    
}

class Team : BaseEntity {
    var name: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        name <- map["name"]
    }
}
