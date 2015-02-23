//
//  Mauerlasche.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Mauerlasche : GeoBaseEntity, MapperProtocol,CellInformationProviderProtocol {
    var erstellungsjahr: Int?
    var laufendeNummer: Int?
    var material: Mauerlaschenmaterial?
    var strasse: Strasse?
    var dokumente: [DMSUrl] = []
    var pruefdatum: NSDate?
    var monteur: String?
    var bemerkung: String?
    var foto: DMSUrl?
    


    required init(){
    }
    
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
        return getMainTitle();
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
    
    override func map(mapper: Mapper) {
        id <= mapper["id"]
        strasse <= mapper["fk_strassenschluessel"]
        erstellungsjahr <= mapper["erstellungsjahr"]

        laufendeNummer <= mapper["laufende_nummer"]
        material <= mapper["fk_material"]
        strasse <= mapper["fk_strassenschluessel"]
        dokumente <= mapper["dokumente"]
        pruefdatum <= mapper["pruefdatum"]
        monteur <= mapper["monteur"]
        bemerkung <= mapper["bemerkung"]
        foto <= mapper["foto"]

        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <= mapper["fk_geom.wgs84_wkt"]
    }
    
    
    // CellInformationProviderProtocol
    
    func getMainTitle() -> String{
        if let lfdNr = laufendeNummer {
            return "\(lfdNr)"
        }
        else {
            return "ohne Nummer"
        }
    }
    func getSubTitle() -> String{
        if let mat = material?.bezeichnung? {
            return mat
        }
        else {
            return "Mauerlasche"
        }
    }
    func getTertiaryInfo() -> String{
        if let str = strasse?.name {
            return str
        }
        return "-"
    }
    func getQuaternaryInfo() -> String{
        return ""
    }
}

class Mauerlaschenmaterial : BaseEntity, MapperProtocol{
    var bezeichnung: String?
    
    required init(){
    }
    override func map(mapper: Mapper) {
        id <= mapper["id"];
        bezeichnung <= mapper["bezeichnung"];
    }

    
}
