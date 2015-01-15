//
//  Leitung.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
class Leitung : GeoBaseEntity {
    var leitungstyp : String?; //wird Leitungstypobjekt
    init(id: Int, leitungstyp: String, geoString: String) {
        super.init();
        self.id=id;
        self.leitungstyp=leitungstyp;
        self.wgs84WKT=geoString;
    }

}
