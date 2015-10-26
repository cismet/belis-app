//
//  Arbeitsprotokoll.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation

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
    
}

class Status: BaseEntity {
    
}

class StandaloneGeom: GeoBaseEntity {
    
}