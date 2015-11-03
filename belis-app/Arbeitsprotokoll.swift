//
//  Arbeitsprotokoll.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class Arbeitsprotokoll : BaseEntity {
    var material: String?
    var monteur: String?
    var bemerkung: String?
    var defekt: String?
    var datum: NSDate?
    var status: Status?
    var veranlassungsnummer: String?
    var protokollnummer: Int?
    
    
    var standort: Standort?
    var mauerlasche: Mauerlasche?
    var leuchte: Leuchte?
    var leitung: Leitung?
    var abzweigdose: Abzweigdose?
    var schaltstelle: Schaltstelle?
    var standaloneGeom: StandaloneGeom?

    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        material <- map["material"]
        monteur <- map["monteur"]
        bemerkung <- map["bemerkung"]
        defekt <- map["defekt"]
        datum <- map["datum"]
        status <- map["fk_status"]
        veranlassungsnummer <- map["veranlassungsnummer"]
        protokollnummer <- map["protokollnummer"]
        standort <- map["fk_standort"]
        mauerlasche <- map["protokollnummer"]
        leuchte <- map["fk_leuchte"]
        leitung <- map["fk_leitung"]
        abzweigdose <- map["fk_abzweigdose"]
        schaltstelle <- map["fk_schaltstelle"]
        standaloneGeom <- map["fk_geometrie"]
    }

}

class Status: BaseEntity {
    var bezeichnung: String?
    var schluessel: String?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"];
        schluessel <- map["schluessel"];
    }
}

class StandaloneGeom: GeoBaseEntity {
    var dokumente: [DMSUrl] = []
    var bezeichnung: String?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"];
        dokumente <- map["ar_dokumente"];
        wgs84WKT <- map["fk_geom.wgs84_wkt"]
    }

    
}