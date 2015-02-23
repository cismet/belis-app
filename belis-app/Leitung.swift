//
//  Leitung.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Leitung : GeoBaseEntity , MapperProtocol,CellInformationProviderProtocol {
    var material: Leitungsmaterial?
    var leitungstyp: Leitungstyp?
    var querschnitt: Querschnitt?
    var dokumente: [DMSUrl] = []
    var laenge: Float?
    
    required init(){}
    override func map(mapper: Mapper) {
        id <= mapper["id"];
        material <= mapper["fk_material"];
        leitungstyp <= mapper["fk_leitungstyp"];
        querschnitt <= mapper["fk_querschnitt"];
        dokumente <= mapper["dokumente"]
        laenge <= mapper["laenge"]

        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <= mapper["fk_geom.wgs84_wkt"]
    }
    
    
    override func getAnnotationTitle() -> String{
        return "\(getMainTitle())-\(getSubTitle())"
    }
    override func getAnnotationSubTitle() -> String{
        return "\(leitungstyp!)";
    }
    override func canShowCallout() -> Bool{
        return true;
    }
    
    // CellInformationProviderProtocol
    
    func getMainTitle() -> String{
        if let mat = leitungstyp?.bezeichnung? {
            return mat
        }
        else {
            return "Leitung"
        }
    }
    func getSubTitle() -> String{
        var laengePart: String
        if let len = laenge? {
            let rounded=String(format: "%.2f", len)
            laengePart="\(rounded)m"
        }
        else {
            laengePart="?m"
        }
        var aPart:String
        if let a = querschnitt?.groesse? {
            aPart = ",\(a)mm²"
        }
        else {
            aPart=""
            
        }
        return "\(laengePart)\(aPart)"
    }
    func getTertiaryInfo() -> String{
        return "\(id)"
    }
    func getQuaternaryInfo() -> String{
        return ""
    }

}

class Leitungsmaterial : BaseEntity, MapperProtocol{
    var bezeichnung: String?
    
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        bezeichnung <= mapper["bezeichung"]
    }
}

class Querschnitt : BaseEntity, MapperProtocol {
    var groesse: Float?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        id <= mapper["id"];
        groesse <= mapper["querschnitt"]
    }
}

class Leitungstyp : BaseEntity, MapperProtocol{
    var bezeichnung: String?
    
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        id <= mapper["id"];
        bezeichnung <= mapper["bezeichnung"]
    }
}

