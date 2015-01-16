//
//  CidsConnector.swift
//  belis-app
//
//  Created by Thorsten Hell on 16/01/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import Alamofire

class CidsConnector {
    
     class func search() {
        let x : [ String : AnyObject] = [
            "list": [
                ["key":"LeuchteEnabled","value":"true"],
                ["key":"GeometryFromWkt","value":"SRID=4326;POLYGON((7.17955464135863 51.2627437325783,7.18126436660672 51.2627264811908,7.18127482387039 51.2631341355339,7.17956508350453 51.2631513871712,7.17955464135863 51.2627437325783))"]
            ]
        ]
        
        //
        
        //        Alamofire.request(.POST, "http://httpbin.org/post", parameters: parameters, encoding: .JSON).responseJSON { (_, _, JSON, _) in
        //            println(JSON)
        //        }
        //        Alamofire.request(.POST, "http://httpbin.org/get",parameters: x, encoding: .JSON)
        
        
        //            .authenticate(user: user, password: password)
        
        var kif="http://kif:8890/searches/BELIS2.de.cismet.belis2.server.search.BelisObjectsWktSearch/results?role=all&limit=100&offset";
        var bin="http://requestb.in/11yncui1";
        
        Alamofire.request(.POST, kif, parameters: x, encoding: .JSON)
            .authenticate(user: "WendlingM@BELIS2", password: "kif")
            .responseString { (request, response, data, error) in
                println(data)
                println(error)
                
            }
            .responseJSON { (request, response, data, error) in
                println(data)
        }

    }
    
}