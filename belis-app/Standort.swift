//
//  Standort.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation

class Standort: GeoBaseEntity {
    var strasse : String?; // wird Strassenschluessel
    var hausnummer : String?;
    var laufendeNummer=0;
    var standortangabe : String?;
    var mastArt : String?;
    var mastTyp : String?;

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
}
