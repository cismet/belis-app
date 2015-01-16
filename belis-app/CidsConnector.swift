//
//  CidsConnector.swift
//  belis-app
//
//  Created by Thorsten Hell on 16/01/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation;
import Alamofire;
import ObjectMapper;

class CidsConnector {
    
     class func search() {
        
        var qp=QueryParameters(list: [
            SingleQueryParameter(key: "LeuchteEnabled", value: "true"),
            SingleQueryParameter(key: "GeometryFromWkt", value: "SRID=4326;POLYGON((7.17955464135863 51.2627437325783,7.18126436660672 51.2627264811908,7.18127482387039 51.2631341355339,7.17956508350453 51.2631513871712,7.17955464135863 51.2627437325783))")
            ]);
        
        let y = Mapper().toJSON(qp);
        
        var kif="http://kif:8890/searches/BELIS2.de.cismet.belis2.server.search.BelisObjectsWktSearch/results?role=all&limit=100&offset";
        var bin="http://requestb.in/11yncui1";
        
        Alamofire.request(.POST, kif, parameters: y, encoding: .JSON)
            .authenticate(user: "WendlingM@BELIS2", password: "kif")
//            .responseString { (request, response, data, error) in
//                println(data)
//                println(error)
//            }
            .responseJSON { (request, response, data, error) in
               var json =  data!.valueForKeyPath("$collection") as [[String : AnyObject]];
                var nodes = Mapper().mapArray(json, toType: CidsObjectNode.self);
                println(nodes.count);
                for node in nodes {
                    println("\(node.classId!) : \(node.objectId!)")
                    
                }
            }
        
//            .responsePropertyList()

    }
    
}
//@objc public protocol ResponseObjectSerializable {
//    init(response: NSHTTPURLResponse, representation: AnyObject)
//}
//extension Alamofire.Request {
//    public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
//        let serializer: Serializer = { (request, response, data) in
//            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
//            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
//            if response != nil && JSON != nil {
//                return (T.collection(response: response!, representation: JSON!), nil)
//            } else {
//                return (nil, serializationError)
//            }
//        }
//        
//        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
//            completionHandler(request, response, object as? [T], error)
//        })
//    }
//}

