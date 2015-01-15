//
//  Mauerlasche.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation

class Mauerlasche : GeoBaseEntity {
    var strasse : String?; // wird Strassenschluessel
    var laufendeNummer=0;

    init(id: Int, laufendeNummer: Int, geoString: String) {
        super.init();
        self.id=id;
        self.laufendeNummer=laufendeNummer;
        self.wgs84WKT=geoString;
    }
    override func getAnnotationImageName() -> String{
        return "mauerlasche.png";
    }
    override func getAnnotationTitle() -> String{
        return "M\(id!) ";
    }
    override func getAnnotationSubTitle() -> String{
        return "";
    }
    
    override func canShowCallout() -> Bool{
        return true;
    }

    override func getAnnotationCalloutImageName() -> String {
        return "ml.png";
    }
}
