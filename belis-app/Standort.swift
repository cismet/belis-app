//
//  Standort.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class Standort: GeoBaseEntity , Mappable{
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

    required init?(_ map: Map) {
        super.init(map)
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
    
    
}

class Stadtbezirk : BaseEntity, Mappable{
    var name: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        name <- map["bezirk"]
    }
}
class Mastart : BaseEntity, Mappable{
    var pk: String?
    var name: String?
    
    override func mapping(map: Map) {
        super.id <- map["id"]
        pk <- map["pk"]
        name <- map["mastart"]
    }
}
class Mastklassifizierung : BaseEntity, Mappable{
    var pk: String?
    var name: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        pk <- map["pk"]
        name <- map["klassifizierung"]
    }
}
class MastUnterhaltspflicht : BaseEntity, Mappable{
    var pk: String?
    var name: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        pk <- map["pk"]
        name <- map["unterhalt_mast"]
    }
}
class Masttyp : BaseEntity, Mappable{
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

class MastKennziffer : BaseEntity, Mappable{
    var kennziffer: Int?
    var beschreibung: String?
    
    override func mapping(map: Map) {
        super.id <- map["id"]
        kennziffer <- map["kennziffer"]
        beschreibung <- map["beschreibung"]
    }
}
class MastAnlagengruppe : BaseEntity, Mappable{
    var nummer: Int?
    var bezeichnung: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        nummer <- map["nummer"]
        bezeichnung <- map["bezeichnung"]
    }
}
