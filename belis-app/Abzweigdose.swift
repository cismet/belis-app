//
//  Abzweigdose.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Abzweigdose : GeoBaseEntity {
    var dokumente: [DMSUrl]=[]
    required init?(_ map: Map) {
        super.init(map)
    }
    override func mapping(map: Map) {
        id <- map["id"];
        dokumente <- map["dokumente"];
        
        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <- map["fk_geom.wgs84_wkt"]
        
        
    }
}
