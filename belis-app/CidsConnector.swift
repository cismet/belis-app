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
    private var user : String; //WendlingM@BELIS2"
    private var password : String; //kif
    private var classes = [27:"TDTA_LEUCHTEN", 52:"MAUERLASCHE",49:"LEITUNG"] as [Int:String];
    let queue = NSOperationQueue()

    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
//    var manager: Manager
    init(user :String, password :String){
        self.user=user;
        self.password=password;
//        configuration.HTTPMaximumConnectionsPerHost = 1
//        configuration.timeoutIntervalForRequest = 30
//        manager=Alamofire.Manager(configuration: configuration)
//        manager=NetworkManager().manager!
    }
    var searchResults : [[GeoBaseEntity]] = [
        [Leuchte](),[Mauerlasche](),[Leitung]()
    ];
    var start=CidsConnector.currentTimeMillis();
    
    func login() {
        

    }
    
    func search(ewktMapContent: String,leuchtenEnabled: String, mauerlaschenEnabled: String, leitungenEnabled: String, handler: (searchResults : [[GeoBaseEntity]]) -> ()) {
        
        var qp=QueryParameters(list:[
            SingleQueryParameter(key: "LeuchteEnabled", value: leuchtenEnabled),
            SingleQueryParameter(key: "MauerlascheEnabled", value: mauerlaschenEnabled),
            SingleQueryParameter(key: "LeitungEnabled", value: leitungenEnabled),
            SingleQueryParameter(key: "GeometryFromWkt", value: ewktMapContent)
            ]);
        
        let y = Mapper().toJSON(qp);
        
        var kif="http://kif:8890/searches/BELIS2.de.cismet.belis2.server.search.BelisObjectsWktSearch/results?role=all&limit=100&offset";
        var bin="http://requestb.in/11yncui1";
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let manager = Alamofire.Manager(configuration: configuration)
        let alamoRequest=manager.request(.POST, kif, parameters: y, encoding: .JSON)
            .authenticate(user: user, password: password)
            .responseJSON { (request, response, data, error) in
               var json =  data!.valueForKeyPath("$collection") as [[String : AnyObject]];
                var nodes = Mapper().mapArray(json, toType: CidsObjectNode.self);
                println(nodes.count);
                self.queue.cancelAllOperations()
                if (nodes.count>0){
                    self.searchResults[0].removeAll(keepCapacity: false);
                    self.searchResults[1].removeAll(keepCapacity: false);
                    self.searchResults[2].removeAll(keepCapacity: false);

                    
                }
                self.start=CidsConnector.currentTimeMillis();
                self.queue.maxConcurrentOperationCount = 10

                for node in nodes {
                    //println("\(node.classId!) : \(node.objectId!)")
                    let op=self.getBelisObject(classId: node.classId!, objectId: node.objectId!,handler)
                    self.queue.addOperation(op)
                }
                
            }
        //println(alamoRequest.debugDescription)
    }

    
    func getBelisObject(#classId: Int!, objectId :Int!, handler: (searchResults : [[GeoBaseEntity]]) -> ()) -> NetworkOperation{
        let classKey=classes[classId]!;
        //println("go for id:\(objectId)@\(classKey)");
        let kif="http://kif:8890/BELIS2.\(classKey)/\(objectId)" //?role=all&omitNullValues=true&deduplicate=false
        let operation=NetworkOperation(method: Alamofire.Method.GET, URLString: kif, user: user, password: password, parameters: ["role":"all","omitNullValues":"true","deduplicate":"true"]) {
            (urlRequest , response, responseObject, error) in
            if let jsonData: AnyObject=responseObject {
                var json =  jsonData as [String : AnyObject];
                //                println(json);
                let classKey=self.classes[classId] as String!
                switch (classKey){
                    case "TDTA_LEUCHTEN":
                        var leuchte = Mapper().map(json, toType: Leuchte.self);
                        self.searchResults[0].append(leuchte)
                     case "MAUERLASCHE":
                        var mauerlasche = Mapper().map(json, toType: Mauerlasche.self);
                        self.searchResults[1].append(mauerlasche)
                    case "LEITUNG":
                        var leitung = Mapper().map(json, toType: Leitung.self);
                        self.searchResults[2].append(leitung)
               default:
                    println("could not find object with classid=\(classId)")
                }
                
                //println("+")
                //println("\(leuchte.id)==>\(leuchte.leuchtenNummer):\(leuchte.typ)@\(leuchte.standort?.strasse)->\(leuchte.wgs84WKT)");

                if self.queue.operationCount==1 {
                    var duration=(CidsConnector.currentTimeMillis() - self.start)
                    handler(searchResults: self.searchResults);
                    println("loaded \(duration)");

                }
            }
            else {
                println("-")
                self.searchResults[0].append(Leuchte())
                
            }
        
            
        }
        
        return operation;
    }
    
    
    class func currentTimeMillis() -> Int64{
        var nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000) + Int64(nowDouble/1000)
    }
}


