//
//  CidsConnector.swift
//  belis-app
//
//  Created by Thorsten Hell on 16/01/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper
import Security

public class CidsConnector {
    
    static var instance: CidsConnector!
    
    //let baseUrl="http://belis-rest.cismet.de:80"
    let baseUrl="https://192.168.178.38:8890"
    //let baseUrl="https://leo:8890"
    // SHARED INSTANCE
    class func sharedInstance() -> CidsConnector {
        self.instance = (self.instance ?? CidsConnector())
        return self.instance
    }
    
    private var login : String!
    private var password : String!
    private let domain = "BELIS2"
    let queue = NSOperationQueue()
    var searchResults=[Entity: [GeoBaseEntity]]()
    
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    
    var certData:NSData!
    
    init(){
        
    }
    
    var start=CidsConnector.currentTimeMillis();
    var loggedIn=false
    
    
    func login(user :String, password :String, handler: (Bool) -> ()) {
        self.login=user+"@"+domain
        self.password=password
        func cH(loggedIn: Bool, error: NSError?) -> () {
            self.loggedIn=loggedIn
            
            if loggedIn {
                println("logged in")
            }
            else {
                println("Error\(error)")
            }
            
            handler(loggedIn)
        }
        var loginOp=LoginOperation(baseUrl: baseUrl, domain: domain,user: login, pass: password,completionHandler: cH)
        loginOp.enqueue()
    }
    
    func search(ewktMapContent: String,leuchtenEnabled: Bool, mastenEnabled: Bool,mauerlaschenEnabled: Bool, leitungenEnabled: Bool, schaltstellenEnabled: Bool, handler: () -> ()) {
        assert(loggedIn)
        var qp=QueryParameters(list:[
            SingleQueryParameter(key: "LeuchteEnabled", value: leuchtenEnabled),
            SingleQueryParameter(key: "MastOhneLeuchtenEnabled", value: mastenEnabled),
            SingleQueryParameter(key: "MauerlascheEnabled", value: mauerlaschenEnabled),
            SingleQueryParameter(key: "LeitungEnabled", value: leitungenEnabled),
            SingleQueryParameter(key: "SchaltstelleEnabled", value: schaltstellenEnabled),
            SingleQueryParameter(key: "GeometryFromWkt", value: ewktMapContent)
            ]);
        
        func mySearchCompletionHandler(data : NSData!, response : NSURLResponse!, error : NSError!) -> Void {
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                println("URL Session Task Succeeded: HTTP \(statusCode)")
                var err: NSError?
                
                if let checkeddata: [String : AnyObject]=NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err) as? [String: AnyObject] {
                    var json =  checkeddata["$collection"] as! [[String : AnyObject]];
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
                        let rightEntity=Entity.byClassId(node.classId!)!
                        let classKey=rightEntity.tableName()
                        
                        
                        func completionHandler(operation:GetEntityOperation, data: NSData!, response: NSURLResponse!, error: NSError!, queue: NSOperationQueue) -> (){
                            if (error == nil) {
                                // Success
                                let statusCode = (response as! NSHTTPURLResponse).statusCode
                                println("URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                                var err: NSError?
                                if let json: [String : AnyObject]=NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err) as? [String: AnyObject] {
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
                                        println("could not find object from entity \(operation.entityName)")
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
                                        handler();
                                        println("loaded \(duration)");
                                        
                                    }
                                    
                                }else {
                                    println("no json data for \(operation.url)")
                                    //self.searchResults[0].append(Leuchte())
                                    
                                }
                            }else {
                                // Failure
                                println("URL Session Task Failed: %@", error.localizedDescription);
                            }
                        }
                        var op=GetEntityOperation(baseUrl: self.baseUrl, domain: self.domain, entityName: classKey, id: node.objectId!, user: self.login, pass: self.password, queue: queue, completionHandler: completionHandler)
                        
                        op.enqueue()
                    }
                }
                else {
                    println("Problem in Request")
                }
                
            }
            else {
                // Failure
                println("URL Session Task Failed: %@", error.localizedDescription);
            }
            
        }
        
        var sop=SearchOperation(baseUrl: self.baseUrl, user: self.login, pass: self.password, parameters: qp, completionHandler: mySearchCompletionHandler)
        
        sop.enqueue()
        
    }
    
    
    func executeSimpleServerAction(#actionName: String!, params: ActionParameterContainer, handler: (success:Bool) -> ()) {
        assert(loggedIn)
        
        func myActionCompletionHandler(data : NSData!, response : NSURLResponse!, error : NSError!) -> Void {
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                println("Action-URL Session Task no Error: HTTP Status Code\(statusCode)")
                if statusCode == 200 {
                    handler(success:true)
                }
                else {
                    handler(success:false)
                }
            }
            else {
                // Failure
                println("ActionURL Session Task Failed: %@", error.localizedDescription);
                handler(success:false)
            }
            
        }
        
        var op=ServerActionOperation(baseUrl: baseUrl, user: login, pass: password, actionName: actionName,params:params, completionHandler: myActionCompletionHandler)
        op.enqueue()
    }
    
    
    func uploadImageToWebDAV(image: UIImage, fileName: String , completionHandler: (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void) {
        assert(loggedIn)
        
        let baseUrl="http://board.cismet.de/belis"
        
        var up=WebDavUploadImageOperation(baseUrl: baseUrl, user: Secrets.getWebDavUser(), pass: Secrets.getWebDavPass(), fileName: fileName, image:image) {
            (data, response, error) -> Void in
            
            completionHandler(data: data, response: response, error: error)
        }
        
        up.enqueue()
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
