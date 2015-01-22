//
//  Leitung.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Leitung : GeoBaseEntity , MapperProtocol{
    var leitungstyp : String?; //wird Leitungstypobjekt
    init(id: Int, leitungstyp: String, geoString: String) {
        super.init();
        self.id=id;
        self.leitungstyp=leitungstyp;
        self.wgs84WKT=geoString;
    }
    required init(){}
    override func map(mapper: Mapper) {
        id <= mapper["id"];
        leitungstyp <= mapper["fk_leitungstyp.bezeichnung"];
        wgs84WKT <= mapper["fk_geom.wgs84_wkt"]
    }
}
