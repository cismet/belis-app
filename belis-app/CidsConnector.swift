//
//  CidsConnector.swift
//  belis-app
//
//  Created by Thorsten Hell on 16/01/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import SwiftHTTP


public class CidsConnector {
    private var user : String; //WendlingM@BELIS2"
    private var password : String; //kif
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
    
    var start=CidsConnector.currentTimeMillis();
    
    func login() {
        

    }
    
    func search(ewktMapContent: String,leuchtenEnabled: String, mastenEnabled: String,mauerlaschenEnabled: String, leitungenEnabled: String, schaltstellenEnabled: String, handler: () -> ()) {
        

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

    
    
    func getBelisObject(#classId: Int!, objectId :Int!, handler: () -> ()) -> NetworkOperation{
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
                    handler();
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
    
    func updateBelisObject(#classId: Int!, objectId :Int!,entity: BaseEntity, handler: () -> ()) {
        let rightEntity=Entity.byClassId(classId)!
        let classKey=rightEntity.tableName()
        let publicUrl="http://belis-rest.cismet.de/BELIS2.\(classKey)/\(objectId)" //?role=all&omitNullValues=true&deduplicate=false
        
        let jsonRepresentationOfEntity=Mapper().toJSON(entity)
        
        let configuration = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let manager = Alamofire.Manager(configuration: configuration)
        let alamoRequest=manager.request(.PUT, publicUrl, parameters: jsonRepresentationOfEntity, encoding: .JSON)
            .authenticate(user: user, password: password)
            .response { (request, response, data, error) in
                if let errorObject: NSError=error {
                    println(errorObject.debugDescription)
                }
        }
   
    }
    
    func executeSimpleServerAction(#actionName: String!, params: ActionParameterContainer, handler: () -> ()) {
        if let jsonContent=Mapper().toJSONString(params, prettyPrint: false) {
            let dat=jsonContent.dataUsingEncoding(NSUTF8StringEncoding)
            let hup=HTTPUpload(data: dat!, fileName: "params.json", mimeType: "application/json")
            let params:Dictionary<String,AnyObject>=["taskparams":hup]
            
            var request = HTTPTask()
            //the auth closures will continually be called until a successful auth or rejection
            var attempted = false
            request.auth = {(challenge: NSURLAuthenticationChallenge) in
                if !attempted {
                    attempted = true
                    return NSURLCredential(user: self.user, password: self.password, persistence: .ForSession)
                }
                return nil //auth failed, nil causes the request to be properly cancelled.
            }
            
            request.POST("http://belis-rest.cismet.de/actions/BELIS2.\(actionName)/tasks", parameters: params, completionHandler: {(response: HTTPResponse) -> Void in
                if let err = response.error {
                    println("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                println("Got data with no error")
                handler()
                })
        }
    }
    func executeTestServerAction() {
        let actionName="AddDokument"
        let baseUrl="http://inspectb.in/4a0aa3be"
//        let baseUrl="http://belis-rest.cismet.de"
        let s=NSString(string: "{\"parameters\":{\"OBJEKT_ID\":\"411\", \"OBJEKT_TYP\":\"schaltstelle\", \"DOKUMENT_URL\":\"http://lorempixel.com/400/200/\\nZufallTest\", \"DOKUMENT_url\":\"http://lorempixel.com/400/200/nature/\\nNaturTest\"}}")
        
        let dat=s.dataUsingEncoding(NSUTF8StringEncoding)
        
        let hup=HTTPUpload(data: dat!, fileName: "params.json", mimeType: "application/json")
        
        
        
        let params:Dictionary<String,AnyObject>=["taskparams":hup]
        
        var request = HTTPTask()
        //the auth closures will continually be called until a successful auth or rejection
        var attempted = false
        request.auth = {(challenge: NSURLAuthenticationChallenge) in
            if !attempted {
                attempted = true
                return NSURLCredential(user: self.user, password: self.password, persistence: .ForSession)
            }
            return nil //auth failed, nil causes the request to be properly cancelled.
        }
        request.POST("\(baseUrl)/actions/BELIS2.\(actionName)/tasks", parameters: params, completionHandler: {(response: HTTPResponse) -> Void in
            if let err = response.error {
                println("error: \(err.localizedDescription)")
                return //also notify app of failure as needed
            }
            println("Got data with no error")        })
    }
    
    
       
    
    func uploadAndAddImageServerAction(#image: UIImage, entity: BaseEntity, description: String, completionHandler: (response: HTTPResponse) -> Void ) {
        let actionName="UploadDokument"
        //let baseUrl="http://inspectb.in/4a0aa3be"
        let baseUrl="http://belis-rest.cismet.de"

        let objectId=entity.id
        let objectTyp=entity.getType().tableName().lowercaseString
        
        let s=NSString(string: "{\"parameters\":{\"OBJEKT_ID\":\"\(objectId)\", \"OBJEKT_TYP\":\"\(objectTyp)\", \"UPLOAD_INFO\":\"png\\n\(description)\"}}")
        
        let dat=s.dataUsingEncoding(NSUTF8StringEncoding)
        
        let hup=HTTPUpload(data: dat!, fileName: "params.json", mimeType: "application/json")
        
        let png=UIImagePNGRepresentation(image)
        
        let imageUpload=HTTPUpload(data: png, fileName: "upload.png", mimeType: "image/png")
        
        
        let params:Dictionary<String,AnyObject>=["file":imageUpload,"taskparams":hup]
        
        var request = HTTPTask()
        //the auth closures will continually be called until a successful auth or rejection
        var attempted = false
        request.auth = {(challenge: NSURLAuthenticationChallenge) in
            if !attempted {
                attempted = true
                return NSURLCredential(user: self.user, password: self.password, persistence: .ForSession)
            }
            return nil //auth failed, nil causes the request to be properly cancelled.
        }
        request.POST("\(baseUrl)/actions/BELIS2.\(actionName)/tasks?resultingInstanceType=result", parameters: params, completionHandler: completionHandler)
//            {(response: HTTPResponse) -> Void in
//            if let err = response.error {
//                println("error: \(err.localizedDescription)")
//                return //also notify app of failure as needed
//            }
//            if let resp = response.responseObject as? NSData {
//                println(NSString(data: resp, encoding: NSUTF8StringEncoding))
//            }
//            println("Got data with no error")
//        })
        
        
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
