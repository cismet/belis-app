//
//  Arbeitsauftrag.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Arbeitsauftrag : GeoBaseEntity {
    var angelegtVon:String?
    var angelegtAm: NSDate?
    var nummer: String?
    var protokolle: [Arbeitsprotokoll]?
    var zugewiesenAn: Team?
}

class Team : BaseEntity {
    var name: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        name <- map["name"]
    }
}
