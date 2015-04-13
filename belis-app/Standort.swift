//
//  Standort.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class Standort: GeoBaseEntity , MapperProtocol{
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

    required init(){
        super.init();
    }
    

    override func map(mapper: Mapper) {
        super.id <= mapper["id"];
        plz  <= mapper["plz"]
        strasse  <= mapper["fk_strassenschluessel"]
        bezirk  <= mapper["fk_stadtbezirk"]
        mastart  <= mapper["fk_mastart"]
        klassifizierung <= mapper["fk_klassifizierung"]
        mastanstrich <= mapper["mastanstrich"]
        mastschutz <= mapper["mastschutz"]
        unterhaltspflicht <= mapper["fk_unterhaltspflicht_mast"]
        typ <= mapper["fk_masttyp"]
        inbetriebnahme <= mapper["inbetriebnahme_mast"]
        verrechnungseinheit <= mapper["verrechnungseinheit"]
        letzteAenderung <= mapper["letzte_aenderung"]
        istVirtuellerStandort <= mapper["ist_virtueller_standort"]
        bemerkung <= mapper["bemerkungen"]
        montagefirma <= mapper["montagefirma"]
        standortangabe <= mapper["standortangabe"]
        kennziffer <= mapper["fk_kennziffer"]
        lfdNummer <= mapper["lfd_nummer"]
        hausnummer <= mapper["haus_nr"]
        dokumente <= mapper["dokumente"]
        gruendung <= mapper["gruendung"]
        elektrischePruefung <= mapper["elek_pruefung"]
        erdung <= mapper["erdung"]
        monteur <= mapper["monteur"]
        standsicherheitspruefung <= mapper["standsicherheitspruefung"]
        verfahrenSHP <= mapper["verfahren"]
        foto <= mapper["foto"]
        naechstesPruefdatum <= mapper["naechstes_pruefdatum"]
        anstrichfrabe <= mapper["anstrichfarbe"]
        revision <= mapper["revision"]
        anlagengruppe <= mapper["anlagengruppe"]
        anbauten <= mapper["anbauten"]

        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <= mapper["fk_geom.wgs84_wkt"]
        
    }
    
    
}

class Stadtbezirk : BaseEntity, MapperProtocol{
    var name: String?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        name <= mapper["bezirk"]
    }
}
class Mastart : BaseEntity, MapperProtocol{
    var pk: String?
    var name: String?
    
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        pk <= mapper["pk"]
        name <= mapper["mastart"]
    }
}
class Mastklassifizierung : BaseEntity, MapperProtocol{
    var pk: String?
    var name: String?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        pk <= mapper["pk"]
        name <= mapper["klassifizierung"]
    }
}
class MastUnterhaltspflicht : BaseEntity, MapperProtocol{
    var pk: String?
    var name: String?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        pk <= mapper["pk"]
        name <= mapper["unterhalt_mast"]
    }
}
class Masttyp : BaseEntity, MapperProtocol{
    var typ: String?
    var bezeichnung: String?
    var lph: Double?
    var hersteller: String?
    var wandstaerke: Int?
    var dokumente: [DMSUrl] = []
    var foto: DMSUrl?
    
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        typ <= mapper["masttyp"]
        bezeichnung <= mapper["bezeichnung"]
        lph <= mapper["lph"]
        hersteller <= mapper["hersteller"]
        wandstaerke <= mapper["wandstaerke"]
        dokumente <= mapper["dokumente"]
        foto <= mapper["foto"]
    }
}

class MastKennziffer : BaseEntity, MapperProtocol{
    var kennziffer: Int?
    var beschreibung: String?
    
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        kennziffer <= mapper["kennziffer"]
        beschreibung <= mapper["beschreibung"]
    }
}
class MastAnlagengruppe : BaseEntity, MapperProtocol{
    var nummer: Int?
    var bezeichnung: String?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        nummer <= mapper["nummer"]
        bezeichnung <= mapper["bezeichnung"]
    }
}
