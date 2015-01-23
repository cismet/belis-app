//
//  Leuchte.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Leuchte : GeoBaseEntity, MapperProtocol {
    var standort : Standort?;
    var leuchtenNummer=0;
    var typ : String?; //wird Leuchtentyp

    required init(){
        super.init();
        standort=Standort();
        typ="";
    }
    
    init(id:Int, standort:Standort, leuchtenNummer:Int, typ:String){
        super.init();
        self.id=id;
        self.standort=standort;
        self.leuchtenNummer=leuchtenNummer;
        self.typ=typ;
        self.wgs84WKT=standort.wgs84WKT;
    }
    override func getAnnotationImageName() -> String{
        return "leuchte.png";
    }
    
    override func getAnnotationTitle() -> String{
        return "L \(standort!.laufendeNummer).\(leuchtenNummer)";
    }
    override func getAnnotationSubTitle() -> String{
        return "\(typ!)";
    }
    
        override func canShowCallout() -> Bool{
        return true;
    }

    override func map(mapper: Mapper) {
        id <= mapper["id"];
        standort <= mapper["fk_standort"];
        leuchtenNummer <= mapper["leuchtennummer"];
        typ <= mapper["fk_leuchttyp.leuchtentyp"]
        wgs84WKT <= mapper["fk_standort.fk_geom.wgs84_wkt"]
    }
 
    
}