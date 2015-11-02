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
    var ar_infobausteine: [Infobaustein] = []
    var beschreibung: String?
    var bemerkungen: String?
    var fk_infobaustein_template: InfobausteinTemplate?
    var ar_geometrien: [StandaloneGeom] = []
    var nummer: String?
    var ar_mauerlaschen: [Mauerlasche] = []
    var fk_art: [Veranlassungsart] = []
    var username: String?
    var ar_abzweigdosen: [Abzweigdose] = []
    var ar_leuchten: [Leuchte] = []
    var bezeichnung: String?
    var datum: NSDate?
    var ar_schaltstellen: [Schaltstelle] = []
    var ar_leitungen: [Leitung] = []


    required init?(_ map: Map) {
        super.init(map)
    }
    
    
    
    override func mapping(map: Map) {
        id <- map["id"];
    }
    
}

class Infobaustein: BaseEntity {
    
}

class InfobausteinTemplate: BaseEntity {
    
}

class Veranlassungsart: BaseEntity {
    
}
