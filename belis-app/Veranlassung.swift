//
//  Veranlassung.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Veranlassung : BaseEntity {

    var dokumente: [DMSUrl] = []
    var standorte: [Standort] = []
    var infobausteine: [Infobaustein] = []
    var beschreibung: String?
    var bemerkungen: String?
    var infobaustein_template: InfobausteinTemplate?
    var geometrien: [StandaloneGeom] = []
    var nummer: String?
    var mauerlaschen: [Mauerlasche] = []
    var art: [Veranlassungsart] = []
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
        datum <- map["datum"];
        schaltstellen <- map["ar_schaltstellen"];
        leitungen <- map["ar_leitungen"];
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
