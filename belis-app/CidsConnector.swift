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
   
    let LEUCHTEN = 0
    let MASTEN = 1
    let MAUERLASCHEN = 2
    let LEITUNGEN = 3
    let SCHALTSTELLEN = 4
    
    private var user : String; //WendlingM@BELIS2"
    private var password : String; //kif
    private var classes = [27:"TDTA_LEUCHTEN", 26:"TDTA_STANDORT_MAST", 52:"MAUERLASCHE",49:"LEITUNG", 51:"SCHALTSTELLE"] as [Int:String];
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
        [Leuchte](),[Standort](),[Mauerlasche](),[Leitung](),[Schaltstelle]()
    ];
    var start=CidsConnector.currentTimeMillis();
    
    func login() {
        

    }
    
    func search(ewktMapContent: String,leuchtenEnabled: String, mastenEnabled: String,mauerlaschenEnabled: String, leitungenEnabled: String, schaltstellenEnabled: String, handler: (searchResults : [[GeoBaseEntity]]) -> ()) {
        
        var qp=QueryParameters(list:[
            SingleQueryParameter(key: "LeuchteEnabled", value: leuchtenEnabled),
            SingleQueryParameter(key: "MastOhneLeuchtenEnabled", value: mastenEnabled),
            SingleQueryParameter(key: "MauerlascheEnabled", value: mauerlaschenEnabled),
            SingleQueryParameter(key: "LeitungEnabled", value: leitungenEnabled),
            SingleQueryParameter(key: "SchaltstelleEnabled", value: schaltstellenEnabled),
            SingleQueryParameter(key: "GeometryFromWkt", value: ewktMapContent)
            ]);
        
        let y = Mapper().toJSON(qp);
        
        //var kif="http://kif:8890/searches/BELIS2.de.cismet.belis2.server.search.BelisObjectsWktSearch/results?role=all&limit=100&offset";
        var publicURL="http://belis-rest.cismet.de/searches/BELIS2.de.cismet.belis2.server.search.BelisObjectsWktSearch/results?role=all&limit=100&offset";
        var bin="http://requestb.in/11yncui1";
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let manager = Alamofire.Manager(configuration: configuration)
        let alamoRequest=manager.request(.POST, publicURL, parameters: y, encoding: .JSON)
            .authenticate(user: user, password: password)
            .responseJSON { (request, response, data, error) in
                if let checkeddata: AnyObject=data {
                    var json =  data!.valueForKeyPath("$collection") as! [[String : AnyObject]];
                    var nodes = Mapper<CidsObjectNode>().mapArray(json)
                    println(nodes.count);
                    self.queue.cancelAllOperations()
                    if (nodes.count>0){
                        self.searchResults[0].removeAll(keepCapacity: false);
                        self.searchResults[1].removeAll(keepCapacity: false);
                        self.searchResults[2].removeAll(keepCapacity: false);
                        self.searchResults[3].removeAll(keepCapacity: false);
                        self.searchResults[4].removeAll(keepCapacity: false);

                    }
                    self.start=CidsConnector.currentTimeMillis();
                    self.queue.maxConcurrentOperationCount = 10
                    
                    for node in nodes {
                        //println("\(node.classId!) : \(node.objectId!)")
                        let op=self.getBelisObject(classId: node.classId!, objectId: node.objectId!,handler: handler)
                        self.queue.addOperation(op)
                    }
                }
                else {
                    println("Problem in Request")
                }
                
            }
        println(alamoRequest.debugDescription)
    }

    
    func getBelisObject(#classId: Int!, objectId :Int!, handler: (searchResults : [[GeoBaseEntity]]) -> ()) -> NetworkOperation{
        let classKey=classes[classId]!;
        //println("go for id:\(objectId)@\(classKey)");
        //let kif="http://kif:8890/BELIS2.\(classKey)/\(objectId)" //?role=all&omitNullValues=true&deduplicate=false
        let publicUrl="http://belis-rest.cismet.de/BELIS2.\(classKey)/\(objectId)" //?role=all&omitNullValues=true&deduplicate=false
        let operation=NetworkOperation(method: Alamofire.Method.GET, URLString: publicUrl, user: user, password: password, parameters: ["role":"all","omitNullValues":"true","deduplicate":"false"]) {
            (urlRequest , response, responseObject, error) in
            if let jsonData: AnyObject=responseObject {
                var json =  jsonData as! [String : AnyObject];
                //                println(json);
                let classKey=self.classes[classId] as String!
                switch (classKey){
                case "TDTA_LEUCHTEN":
                    var leuchte = Mapper<Leuchte>().map(json)
                    self.searchResults[self.LEUCHTEN].append(leuchte!)
                case "TDTA_STANDORT_MAST":
                    var mast = Mapper<Standort>().map(json)
                    self.searchResults[self.MASTEN].append(mast!)
                case "MAUERLASCHE":
                    var mauerlasche = Mapper<Mauerlasche>().map(json)
                    self.searchResults[self.MAUERLASCHEN].append(mauerlasche!)
                case "LEITUNG":
                    var leitung = Mapper<Leitung>().map(json)
                    self.searchResults[self.LEITUNGEN].append(leitung!)
                case "SCHALTSTELLE":
                    var schaltstelle = Mapper<Schaltstelle>().map(json)
                    self.searchResults[self.SCHALTSTELLEN].append(schaltstelle!)
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


