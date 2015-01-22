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
    var strasse : String?; // wird Strassenschluessel
    var hausnummer : String?;
    var laufendeNummer=0;
    var standortangabe : String?;
    var mastArt : String?;
    var mastTyp : String?;
    
    required init(){
        super.init();
        strasse="";
        hausnummer="";
        standortangabe="";
        mastArt="";
        mastTyp="";
    }
    
    init(id: Int,strasse: String, hausnummer: String, laufendeNummer: Int, standortangabe: String, mastArt: String, mastTyp: String, geoString: String) {
        super.init();
        self.id=id;
        self.strasse=strasse;
        self.hausnummer=hausnummer;
        self.laufendeNummer=laufendeNummer;
        self.standortangabe=standortangabe;
        self.mastArt=mastArt;
        self.mastTyp=mastTyp;
        self.wgs84WKT=geoString;
    
    }

    override func map(mapper: Mapper) {
        id <= mapper["id"];
        strasse <= mapper["fk_strassenschluessel.strasse"];
        hausnummer <= mapper["haus_nr"];
        laufendeNummer <= mapper["lfd_nummer"];
        standortangabe <= mapper["standortangabe"];
        mastArt <= mapper["fk_mastart.mastart"];
        mastTyp <= mapper["fk_masttyp.masttyp"]
        wgs84WKT <= mapper["fk_geom.wgs84_wkt"]
    }
    
    
}

