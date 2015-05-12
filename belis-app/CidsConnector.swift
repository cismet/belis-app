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

public class CidsConnector {
    private var user : String; //WendlingM@BELIS2"
    private var password : String; //kif
    private var classes = [27:"TDTA_LEUCHTEN", 26:"TDTA_STANDORT_MAST", 52:"MAUERLASCHE",49:"LEITUNG", 51:"SCHALTSTELLE"] as [Int:String];
    let queue = NSOperationQueue()
    var searchResults=[Entity: [GeoBaseEntity]]()

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
    
    
//    var searchResults : [[GeoBaseEntity]] = [
//        [Leuchte](),[Standort](),[Mauerlasche](),[Leitung](),[Schaltstelle]()
//    ];
    var start=CidsConnector.currentTimeMillis();
    
    func login() {
        

    }
    
    func search(ewktMapContent: String,leuchtenEnabled: String, mastenEnabled: String,mauerlaschenEnabled: String, leitungenEnabled: String, schaltstellenEnabled: String, handler: (results : [Entity: [GeoBaseEntity]]) -> ()) {
        

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
                        self.searchResults=[Entity: [GeoBaseEntity]]()
                    }
                    self.start=CidsConnector.currentTimeMillis();
                    self.queue.maxConcurrentOperationCount = 10
                    
                    for node in nodes {
                        println("\(node.classId!) : \(node.objectId!)")
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

    
    func getBelisObject(#classId: Int!, objectId :Int!, handler: (results: [Entity: [GeoBaseEntity]]) -> ()) -> NetworkOperation{
        //println("go for id:\(objectId)@\(classKey)");
        //let kif="http://kif:8890/BELIS2.\(classKey)/\(objectId)" //?role=all&omitNullValues=true&deduplicate=false
        let rightEntity=Entity.byClassId(classId)!
        let classKey=rightEntity.tableName()
        let publicUrl="http://belis-rest.cismet.de/BELIS2.\(classKey)/\(objectId)" //?role=all&omitNullValues=true&deduplicate=false
        let operation=NetworkOperation(method: Alamofire.Method.GET, URLString: publicUrl, user: user, password: password, parameters: ["role":"all","omitNullValues":"true","deduplicate":"false"]) {
            (urlRequest , response, responseObject, error) in
            if let jsonData: AnyObject=responseObject {
                var json =  jsonData as! [String : AnyObject];
                //                println(json);
                
                var gbEntity:GeoBaseEntity
                
                switch (rightEntity){
                case .LEUCHTEN:
                    gbEntity = Mapper<Leuchte>().map(json)!
                case .MASTEN:
                    gbEntity = Mapper<Standort>().map(json)!
                case .MAUERLASCHEN:
                    gbEntity = Mapper<Mauerlasche>().map(json)!
                case .LEITUNGEN:
                    gbEntity = Mapper<Leitung>().map(json)!
                case .SCHALTSTELLEN:
                    gbEntity = Mapper<Schaltstelle>().map(json)!
                default:
                    println("could not find object with classid=\(classId)")
                }
                
                if let array=self.searchResults[rightEntity]{
                    self.searchResults[rightEntity]!.append(gbEntity)
                }
                else {
                    self.searchResults.updateValue([gbEntity], forKey: rightEntity)
                }
                
                //println("+")
                //println("\(leuchte.id)==>\(leuchte.leuchtenNummer):\(leuchte.typ)@\(leuchte.standort?.strasse)->\(leuchte.wgs84WKT)");
                
                if self.queue.operationCount==1 {
                    var duration=(CidsConnector.currentTimeMillis() - self.start)
                    handler(results: self.searchResults);
                    println("loaded \(duration)");
                    
                }
            }
            else {
                println("no json data")
                //self.searchResults[0].append(Leuchte())
                
            }
        }
        
        return operation;
    }
    
    
    class func currentTimeMillis() -> Int64{
        var nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000) + Int64(nowDouble/1000)
    }
}

enum Entity : String{
    case LEUCHTEN="Leuchten"
    case MASTEN="Masten"
    case MAUERLASCHEN="Mauerlaschen"
    case LEITUNGEN="Leitungen"
    case SCHALTSTELLEN="Schaltstellen"
    
    static let allValues=[LEUCHTEN,MASTEN,MAUERLASCHEN,LEITUNGEN,SCHALTSTELLEN]
    
    static func byIndex(index: Int) -> Entity {
        return allValues[index]
    }
    
    func index() -> Int {
        switch self {
        case .LEUCHTEN:
            return 0
        case .MASTEN:
            return 1
        case .MAUERLASCHEN:
            return 2
        case .LEITUNGEN:
            return 3
        case .SCHALTSTELLEN:
            return 4
        }
    }
    
    static func byClassId(cid: Int) -> Entity? {
        let dict=[27:LEUCHTEN, 26:MASTEN, 52:MAUERLASCHEN, 49:LEITUNGEN,51:SCHALTSTELLEN]
        return dict[cid]
    }
    func classId() -> Int{
        switch self {
        case .LEUCHTEN:
            return 27
        case .MASTEN:
            return 26
        case .MAUERLASCHEN:
            return 52
        case .LEITUNGEN:
            return 39
        case .SCHALTSTELLEN:
            return 51
        }
        
    }
    
    
    func tableName() -> String {
        switch self {
        case .LEUCHTEN:
            return "TDTA_LEUCHTEN"
        case .MASTEN:
            return "TDTA_STANDORT_MAST"
        case .MAUERLASCHEN:
            return "MAUERLASCHE"
        case .LEITUNGEN:
            return "LEITUNG"
        case .SCHALTSTELLEN:
            return "SCHALTSTELLE"
        }
    }
    
    func isInSearchResults() -> Bool {
        return true
    }
    
    
}
