//
//  Veranlassung.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Veranlassung : BaseEntity, CellDataProvider  {

    var dokumente: [DMSUrl] = []
    var standorte: [Standort] = []
    var infobausteine: [Infobaustein] = []
    var beschreibung: String?
    var bemerkungen: String?
    var infobaustein_template: InfobausteinTemplate?
    var geometrien: [StandaloneGeom] = []
    var nummer: String?
    var mauerlaschen: [Mauerlasche] = []
    var art: Veranlassungsart?
    var username: String?
    var abzweigdosen: [Abzweigdose] = []
    var leuchten: [Leuchte] = []
    var bezeichnung: String?
    var datum: NSDate?
    var schaltstellen: [Schaltstelle] = []
    var leitungen: [Leitung] = []


    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        dokumente <- map["ar_dokumente"];
        standorte <- map["ar_standorte"];
        infobausteine <- map["ar_infobausteine"];
        beschreibung <- map["beschreibung"];
        bemerkungen <- map["bemerkungen"];
        infobaustein_template <- map["fk_infobaustein_template"];
        geometrien <- map["ar_geometrien"];
        nummer <- map["nummer"];
        mauerlaschen <- map["ar_mauerlaschen"];
        art <- map["fk_art"];
        username <- map["username"];
        abzweigdosen <- map["ar_abzweigdosen"];
        leuchten <- map["ar_leuchten"];
        bezeichnung <- map["bezeichnung"];
        datum <- (map["datum"], DateTransformFromString(format: "yyyy-MM-dd"))
        schaltstellen <- map["ar_schaltstellen"];
        leitungen <- map["ar_leitungen"];
    }
     // MARK: BaseEntity - must be overridden
    override func getType() -> Entity {
        return Entity.VERANLASSUNGEN
    }
    
    
    // MARK: CellDataProvider
    @objc func getTitle() -> String {
        return "Veranlassung"
    }
    @objc func getDetailGlyphIconString() -> String {
        return "icon-switch"
    }
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        data["main"]?.append(SingleTitledInfoCellData(title: "Nummer", data: nummer ?? "?"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Bezeichnung", data: bezeichnung ?? "-"))
        data["main"]?.append(SingleTitledInfoCellData(title: "Grund (Art)", data: art?.bezeichnung ?? "-"))
        data["main"]?.append(MemoTitledInfoCellData(title: "Beschreibung", data: beschreibung ?? ""))
        data["main"]?.append(DoubleTitledInfoCellData(titleLeft: "angelegt von", dataLeft: username ?? "-", titleRight: "angelegt am", dataRight: datum?.toDateString() ?? "-"))
        data["main"]?.append(MemoTitledInfoCellData(title: "Bemerkungen", data: bemerkungen ?? ""))
        data["DeveloperInfo"]=[]
        data["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))
        return data
    }
    @objc func getDataSectionKeys() -> [String] {
        return ["main","DeveloperInfo"]
    }
    
}

class Infobaustein: BaseEntity {
    var schluessel: String?
    var pflichtfeld: Bool?
    var wert: String?
    var bezeichnung: String?
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        schluessel <- map["schluessel"];
        pflichtfeld <- map["pflichtfeld"];
        wert <- map["wert"];
        bezeichnung <- map["bezeichnung"];
    }
    
}

class InfobausteinTemplate: BaseEntity {
    var schluessel: String?
    var bezeichnung: String?
    var bausteine: [Infobaustein]=[]
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        schluessel <- map["schluessel"];
        bezeichnung <- map["bezeichnung"];
        bausteine <- map["ar_bausteine"];
    }
}

class Veranlassungsart: BaseEntity {
    var schluessel: String?
    var bezeichnung: String?

    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        schluessel <- map["schluessel"];
        bezeichnung <- map["bezeichnung"];
    }

}
