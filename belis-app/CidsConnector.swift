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
    
    // MARK: - fill simulator value
    #if arch(i386) || arch(x86_64)
    let simulator=true
    #else
    let simulator=false
    #endif
    
    
    // MARK: SHARED INSTANCE
    static var instance: CidsConnector!
    class func sharedInstance() -> CidsConnector {
        self.instance = (self.instance ?? CidsConnector())
        return self.instance
    }
    
    
    
    // MARK: - Values with custom getters and setters
    var tlsEnabled=false {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(tlsEnabled, forKey: "tlsEnabled")
        }
    }
    var pureBaseUrl="192.168.178.38" {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(pureBaseUrl, forKey: "cidsPureBaseURL")
        }
    }
    var baseUrlport="8890" {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(baseUrlport, forKey: "cidsBaseURLPort")
        }
    }
    
    var baseUrl:String {
        get {
            var prot="http://"
            if tlsEnabled {
                prot="https://"
            }
            return "\(prot)\(pureBaseUrl):\(baseUrlport)"
        }
        
    }
    
    var docFolder: String {
        get {
            return NSSearchPathForDirectoriesInDomains(.DocumentDirectory,.UserDomainMask,true)[0]
        }
    }
    
    var serverCert: String?{
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(serverCert, forKey: "serverCert")
        }
    }
    var serverCertPath: String {
        get {
            if !simulator {
                if let cert=serverCert {
                    return docFolder+cert
                }
                else {
                    return ""
                }
            }
            else {
                return NSBundle.mainBundle().pathForResource("server.cert.dev", ofType:"der")!
            }
        }
    }
    
    var clientCert: String? {
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(clientCert, forKey: "clientCert")
        }
    }
    
    var clientCertPath: String {
        get {
            if !simulator {
                if let cert=clientCert {
                    return docFolder+cert
                }
                else {
                    return ""
                }
            }
            else {
                return NSBundle.mainBundle().pathForResource("client.cert.dev", ofType: "p12")!
            }
        }
    }
    
    var clientCertContainerPass: String = ""{
        didSet {
            NSUserDefaults.standardUserDefaults().setObject(clientCertContainerPass, forKey: "clientCertContainerPass")
        }
    }
    
    // MARK: - other variables
    private var login : String!
    private var password : String!
    private let domain = "BELIS2"
    
    let blockingQueue = NSOperationQueue()
    let backgroundQeue = NSOperationQueue()
    
    var searchResults=[Entity: [GeoBaseEntity]]()
    
    var allArbeitsauftraegeBeforeCurrentSelection=[Entity: [GeoBaseEntity]]()
    var selectedArbeitsauftrag: Arbeitsauftrag?
    
    var veranlassungsCache=[String:Veranlassung]()
    let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
    var mainVC:MainViewController?
    var start=CidsConnector.currentTimeMillis();
    var loggedIn=false
    var selectedTeam: Team?
    var selectedTeamId: String?
    var lastMonteur: String?
    
    // MARK: - Lists
    var sortedTeamListKeys: [String]=[]
    var teamList: [String:Team]=[:]
    
    var sortedLeuchtenTypListKeys: [String]=[]
    var leuchtentypList: [String:LeuchtenTyp]=[:]
    
    var sortedLeuchtmittelListKeys: [String]=[]
    var leuchtmittelList: [String:Leuchtmittel]=[:]
    
    var sortedRundsteuerempfaengerListKeys: [String]=[]
    var rundsteuerempfaengerList: [String:Rundsteuerempfaenger]=[:]
    
    var sortedArbeitsprotokollStatusListKeys: [String]=[]
    var arbeitsprotokollStatusList: [String:ArbeitsprotokollStatus]=[:]
    
    // MARK: - constructor
    init(){
        
        let storedTLSEnabled: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("tlsEnabled")
        if let storedTLSEnabledAsBool=storedTLSEnabled as? Bool {
            tlsEnabled=storedTLSEnabledAsBool
        }
        let storedPureUrlBase: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("cidsPureBaseURL")
        if let storedPureUrlBaseAsString=storedPureUrlBase as? String {
            pureBaseUrl=storedPureUrlBaseAsString
        }
        
        let storedPort: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("cidsBaseURLPort")
        if let storedPortAsString=storedPort as? String {
            baseUrlport=storedPortAsString
        }
        
        let storedServerCertPath: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("serverCert")
        if let storedServerCertPathString=storedServerCertPath as? String {
            serverCert=storedServerCertPathString
        }
        let storedClientCertPath: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("clientCert")
        if let storedClientCertPathString=storedClientCertPath as? String {
            clientCert=storedClientCertPathString
        }
        let storedClientCertContainerPass: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("clientCertContainerPass")
        if let storedClientCertContainerPassString=storedClientCertContainerPass as? String {
            clientCertContainerPass=storedClientCertContainerPassString
        }
        else if simulator{
            clientCertContainerPass="123456"
        }
    }
    
    // MARK: - functions
    func login(user :String, password :String, handler: (Bool) -> ()) {
        self.login=user+"@"+domain
        self.password=password
        func cH(loggedIn: Bool, error: NSError?) -> () {
            self.loggedIn=loggedIn
            
            if loggedIn {
                print("logged in")
            }
            else {
                print("Error\(error)")
            }
            if (loggedIn) {
                func teamsCompletionHandler(operation: GetAllEntitiesOperation, data: NSData!, response: NSURLResponse!, error: NSError!, queue: NSOperationQueue){
                    if (error == nil) {
                        // Success
                        let statusCode = (response as! NSHTTPURLResponse).statusCode
                        print("URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                        if let checkeddata: [String : AnyObject] = getJson(data) {
                            let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                            if let teams = Mapper<Team>().mapArray(json) {
                                
                                print("\(teams.count) Teams vorhanden")
                                let sortedTeams=teams.sort(Team.ascending)
                                self.sortedTeamListKeys=[]
                                for t in sortedTeams {
                                    self.teamList.updateValue(t, forKey: "\(t.id)")
                                    self.sortedTeamListKeys.append("\(t.id)")
                                }
                                print("\(teams.count) Teams abgelegt")
                                if let tid=CidsConnector.sharedInstance().selectedTeamId {
                                    if let t=CidsConnector.sharedInstance().teamList[tid]{
                                        CidsConnector.sharedInstance().selectedTeam=t
                                    }
                                }
                            }
                        }
                        else {
                            print("no json data for \(operation.url)")
                            //self.searchResults[0].append(Leuchte())
                            
                        }
                    }else {
                        // Failure
                        print("URL Session Task Failed: %@", error.localizedDescription);
                    }
                    
                    handler(loggedIn)

                }
                
                let teamsOperation=GetAllEntitiesOperation(baseUrl: baseUrl, domain: domain, entityName: "team", user: login, pass: password, queue: blockingQueue, completionHandler: teamsCompletionHandler)
                
                teamsOperation.enqueue()
                getBackgroundLists()
            }
            else {
                handler(loggedIn)
            }

        }
        let loginOp=LoginOperation(baseUrl: baseUrl, domain: domain,user: login, pass: password,completionHandler: cH)
        loginOp.enqueue()
    }
    func getBackgroundLists() {
        
        func arbeitsprotokollstatusCompletionHandler(operation: GetAllEntitiesOperation, data: NSData!, response: NSURLResponse!, error: NSError!, queue: NSOperationQueue){
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                if let checkeddata: [String : AnyObject] = getJson(data) {
                    let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                    if let apsts = Mapper<ArbeitsprotokollStatus>().mapArray(json) {
                        
                        print("\(apsts.count) Protokollstati vorhanden")
                        let sortedApsts=apsts.sort(ArbeitsprotokollStatus.ascending)
                        self.sortedArbeitsprotokollStatusListKeys=[]
                        for aps in sortedApsts {
                            self.arbeitsprotokollStatusList.updateValue(aps, forKey: "\(aps.id)")
                            self.sortedArbeitsprotokollStatusListKeys.append("\(aps.id)")
                        }
                        print("\(apsts.count) Protokollstati abgelegt")
                    }
                    else {
                        print("no json data for \(operation.url)")
                        //self.searchResults[0].append(Leuchte())
                        
                    }
                }else {
                    // Failure
                    print("URL Session Task Failed: %@", error.localizedDescription);
                }
            }
        }
        let arbeitsprotokollstatiOperation=GetAllEntitiesOperation(baseUrl: baseUrl, domain: domain, entityName: "arbeitsprotokollstatus", user: login, pass: password, queue: backgroundQeue, completionHandler: arbeitsprotokollstatusCompletionHandler)
        
        func leuchtentypenCompletionHandler(operation: GetAllEntitiesOperation, data: NSData!, response: NSURLResponse!, error: NSError!, queue: NSOperationQueue){
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                if let checkeddata: [String : AnyObject] = getJson(data) {
                    let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                    if let lts = Mapper<LeuchtenTyp>().mapArray(json) {
                        
                        print("\(lts.count) Leuchtentypen vorhanden")
                        let sortedLts=lts.sort(LeuchtenTyp.ascending)
                        self.sortedLeuchtenTypListKeys=[]
                        for lt in sortedLts {
                            self.leuchtentypList.updateValue(lt, forKey: "\(lt.id)")
                            self.sortedLeuchtenTypListKeys.append("\(lt.id)")
                        }
                        print("\(lts.count) Leuchtentypen abgelegt")
                        
                        //                        if self.queue.operationCount==1 {
                        //                            let duration = (CidsConnector.currentTimeMillis() - self.start)
                        //                            handler();
                        //                            print("loaded \(duration)");
                        //
                        //                        }
                    }
                }
                else {
                    print("no json data for \(operation.url)")
                    //self.searchResults[0].append(Leuchte())
                    
                }
            }else {
                // Failure
                print("URL Session Task Failed: %@", error.localizedDescription);
            }
            
        }
        let leuchtentypenOperation=GetAllEntitiesOperation(baseUrl: baseUrl, domain: domain, entityName: "tkey_leuchtentyp", user: login, pass: password, queue: backgroundQeue, completionHandler: leuchtentypenCompletionHandler)
        
        func leuchtmittelCompletionHandler(operation: GetAllEntitiesOperation, data: NSData!, response: NSURLResponse!, error: NSError!, queue: NSOperationQueue){
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                if let checkeddata: [String : AnyObject] = getJson(data) {
                    let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                    if let lms = Mapper<Leuchtmittel>().mapArray(json) {
                        
                        print("\(lms.count) Leuchtmittel vorhanden")
                        let sortedLms=lms.sort(Leuchtmittel.ascending)
                        self.sortedLeuchtmittelListKeys=[]
                        for lm in sortedLms {
                            self.leuchtmittelList.updateValue(lm, forKey: "\(lm.id)")
                            self.sortedLeuchtmittelListKeys.append("\(lm.id)")
                        }
                        print("\(lms.count) Leuchtmittel abgelegt")
                        
                        //                        if self.queue.operationCount==1 {
                        //                            let duration = (CidsConnector.currentTimeMillis() - self.start)
                        //                            handler();
                        //                            print("loaded \(duration)");
                        //
                        //                        }
                    }
                }
                else {
                    print("no json data for \(operation.url)")
                    //self.searchResults[0].append(Leuchte())
                    
                }
            }else {
                // Failure
                print("URL Session Task Failed: %@", error.localizedDescription);
            }
            
        }
        
        let leuchtmittelOperation=GetAllEntitiesOperation(baseUrl: baseUrl, domain: domain, entityName: "leuchtmittel", user: login, pass: password, queue: backgroundQeue, completionHandler: leuchtmittelCompletionHandler)
        
        func rundsteuerempfaengerCompletionHandler(operation: GetAllEntitiesOperation, data: NSData!, response: NSURLResponse!, error: NSError!, queue: NSOperationQueue){
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                if let checkeddata: [String : AnyObject] = getJson(data) {
                    let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                    if let rses = Mapper<Rundsteuerempfaenger>().mapArray(json) {
                        
                        print("\(rses.count) Rundsteuerempfänger vorhanden")
                        let sortedRses=rses.sort(Rundsteuerempfaenger.ascending)
                        self.sortedRundsteuerempfaengerListKeys=[]
                        for rse in sortedRses {
                            self.rundsteuerempfaengerList.updateValue(rse, forKey: "\(rse.id)")
                            self.sortedRundsteuerempfaengerListKeys.append( "\(rse.id)")
                        }
                        print("\(rses.count) Rundsteuerempfänger abgelegt")
                        
                        //                        if self.queue.operationCount==1 {
                        //                            let duration = (CidsConnector.currentTimeMillis() - self.start)
                        //                            handler();
                        //                            print("loaded \(duration)");
                        //
                        //                        }
                    }
                }
                else {
                    print("no json data for \(operation.url)")
                    //self.searchResults[0].append(Leuchte())
                    
                }
            }else {
                // Failure
                print("URL Session Task Failed: %@", error.localizedDescription);
            }
            
        }
        let rundsteuerempfaengerOperation=GetAllEntitiesOperation(baseUrl: baseUrl, domain: domain, entityName: "rundsteuerempfaenger", user: login, pass: password, queue: backgroundQeue, completionHandler: rundsteuerempfaengerCompletionHandler)
        
        arbeitsprotokollstatiOperation.enqueue()
        leuchtentypenOperation.enqueue()
        leuchtmittelOperation.enqueue()
        rundsteuerempfaengerOperation.enqueue()
        
    }
    func sortSearchResults() {
        for key in searchResults.keys {
            searchResults[key]?.sortInPlace {
                return $0.id < $1.id
            }
        }
    }
    func getJson(data: NSData) -> [String: AnyObject]?{
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        }
        catch {
            return nil
        }
    }
    func searchArbeitsauftraegeForTeam(team: Team, handler: () -> ()) {
        assert(loggedIn)
        var qp=QueryParameters(list:[
            SingleQueryParameter(key: "arbeitsauftragEnabled", value: true),
            SingleQueryParameter(key: "activeObjectsOnly", value: true),
            SingleQueryParameter(key: "zugewiesenAn", value: team.id) //39
            ]);
        func mySearchCompletionHandler(data : NSData!, response : NSURLResponse!, error : NSError!) -> Void {
            if (error == nil) {
                print("Arbeitsaufträge Search kein Fehler")
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                
                if let checkeddata: [String : AnyObject] = getJson(data) {
                    let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                    if let nodes = Mapper<CidsObjectNode>().mapArray(json) {
                        
                        if nodes.count>1 {
                            showWaitingHUD(text: "\(nodes.count) Arbeitsaufträge laden", indeterminate: false )
                        }
                        else {
                            showWaitingHUD(text: "Arbeitsauftrag laden", indeterminate: false )
                        }
                        self.blockingQueue.cancelAllOperations()
                        self.searchResults=[Entity: [GeoBaseEntity]]()
                        self.start=CidsConnector.currentTimeMillis();
                        self.blockingQueue.maxConcurrentOperationCount = 10
                        if nodes.count==0 {
                            handler()
                        }
                        else {
                            var i=0
                            for node in nodes {
                                print("\(node.classId!) : \(node.objectId!)")
                                let rightEntity=Entity.byClassId(node.classId!)!
                                assert(rightEntity==Entity.ARBEITSAUFTRAEGE)
                                let classKey=rightEntity.tableName()
                                func getAACompletionHandler(operation:GetEntityOperation, data: NSData!, response: NSURLResponse!, error: NSError!, queue: NSOperationQueue) -> (){
                                    if (error == nil) {
                                        // Success
                                        let statusCode = (response as! NSHTTPURLResponse).statusCode
                                        print("URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                                        
                                        if let json: [String : AnyObject] = getJson(data) {
                                            var aa:Arbeitsauftrag?
                                            aa = Mapper<Arbeitsauftrag>().map(json)!
                                            let progress=Float(++i)/Float(nodes.count)
                                            setProgressInWaitingHUD(progress)

                                            if let auftrag=aa {
                                                if let _=self.searchResults[Entity.ARBEITSAUFTRAEGE] {
                                                    self.searchResults[Entity.ARBEITSAUFTRAEGE]!.append(auftrag)
                                                }
                                                else {
                                                    self.searchResults.updateValue([auftrag], forKey: Entity.ARBEITSAUFTRAEGE)
                                                }
                                                
                                                for veranlassungsnummer in auftrag.getVeranlassungsnummern() {
                                                    if let _=self.veranlassungsCache[veranlassungsnummer] {
                                                        print("cacheHit")
                                                    }
                                                    else {
                                                        getVeranlassungByNummer(veranlassungsnummer, handler: { (veranlassung) -> () in
                                                            if let v=veranlassung {
                                                                self.veranlassungsCache.updateValue(v, forKey: veranlassungsnummer)
                                                                if self.selectedArbeitsauftrag != nil {
                                                                    lazyMainQueueDispatch({ () -> () in
                                                                        self.mainVC?.tableView.reloadData()
                                                                    })
                                                                }
                                                                
                                                            }
                                                        })
                                                    }
                                                }
                                            }
                                            
                                            if self.blockingQueue.operationCount==1 {
                                                let duration = (CidsConnector.currentTimeMillis() - self.start)
                                                handler();
                                                print("loaded \(duration)");
                                                
                                            }
                                            
                                        }else {
                                            print("no json data for \(operation.url)")
                                            //self.searchResults[0].append(Leuchte())
                                            
                                        }
                                    }else {
                                        // Failure
                                        print("URL Session Task Failed: %@", error.localizedDescription);
                                    }
                                }
                                let op=GetEntityOperation(baseUrl: self.baseUrl, domain: self.domain, entityName: classKey, id: node.objectId!, user: self.login, pass: self.password, queue: blockingQueue, completionHandler: getAACompletionHandler)
                                
                                op.enqueue()
                            }
                        }
                    }
                }
            }
            else {
                print("Arbeitsaufträge Search Fehler")
            }
            
        }
        let sop=SearchOperation(baseUrl: self.baseUrl,searchKey: "BELIS2.de.cismet.belis2.server.search.ArbeitsauftragSearchStatement" , user: self.login, pass: self.password, parameters: qp, completionHandler: mySearchCompletionHandler)
        
        sop.enqueue()
        
    }
    func refreshArbeitsauftrag(arbeitsauftrag: Arbeitsauftrag?, handler: (success: Bool)->() ){
        if let _=arbeitsauftrag {
            func completionHandler(operation:GetEntityOperation, data: NSData!, response: NSURLResponse!, error: NSError!, queue: NSOperationQueue) -> (){
                if (error == nil) {
                    // Success
                    let statusCode = (response as! NSHTTPURLResponse).statusCode
                    print("URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                    if let json: [String : AnyObject] = getJson(data) {
                        //let sel=self.mainVC!.tableView.indexPathForSelectedRow
                        let entity = Mapper<Arbeitsauftrag>().map(json)
                        if let aa=entity {
                            CidsConnector.sharedInstance().selectedArbeitsauftrag=aa
                            var tmp=CidsConnector.sharedInstance().allArbeitsauftraegeBeforeCurrentSelection
                            if let x=tmp[Entity.ARBEITSAUFTRAEGE] {
                                var i=0
                                for oldAA in x {
                                    if oldAA.id==aa.id {
                                       CidsConnector.sharedInstance().allArbeitsauftraegeBeforeCurrentSelection[Entity.ARBEITSAUFTRAEGE]![i]=aa
                                        break
                                    }
                                    i++
                                }
                            }
                            
                            self.mainVC!.fillArbeitsauftragIntoTable(aa)
                            self.mainVC!.visualizeAllSearchResultsInMap(zoomToShowAll: false, showActivityIndicator: true)
                            //  if let s=sel  {
                            //  self.mainVC!.tableView.selectRowAtIndexPath(s, animated: false, scrollPosition: UITableViewScrollPosition.None)
                            //  }

                            handler(success: true)
                            return
                        }
                        
                    }else {
                        print("no json data for \(operation.url)")
                        //self.searchResults[0].append(Leuchte())
                        
                    }
                }else {
                    // Failure
                    print("URL Session Task Failed: %@", error.localizedDescription);
                }
                
                handler(success: false)
            }
            let op=GetEntityOperation(baseUrl: self.baseUrl, domain: self.domain, entityName: Entity.ARBEITSAUFTRAEGE.tableName(), id: arbeitsauftrag!.id, user: self.login, pass: self.password, queue: blockingQueue, completionHandler: completionHandler)
            op.enqueue()
        }
    }
    func getVeranlassungByNummer(vnr:String, handler: (veranlassung:Veranlassung?) -> ()) {
        assert(loggedIn)
        
        var qp=QueryParameters(list:[
            SingleQueryParameter(key: "nummer", value: vnr)
            ]);
        
        func mySearchCompletionHandler(data : NSData!, response : NSURLResponse!, error : NSError!) -> Void {
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                
                if let cidsJsonCollection: [String : AnyObject] = getJson(data) {
                    // Content is now a cids Collection of json Data
                    
                    if let jsonArray=cidsJsonCollection["$collection"] as? [AnyObject] {
                        var veranlassung: Veranlassung?
                        veranlassung = Mapper<Veranlassung>().map(jsonArray[0])
                        handler(veranlassung: veranlassung)
                    }
                }
                else {
                    print("Problem in Request")
                }
                
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error.localizedDescription);
            }
            handler(veranlassung: nil)
        }
        
        
        let sop=SearchOperation(baseUrl: self.baseUrl, searchKey: "BELIS2.de.cismet.belis2.server.search.VeranlassungByNummerSearch", user: self.login, pass: self.password, parameters: qp, completionHandler: mySearchCompletionHandler)
        
        sop.enqueue()
        
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
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                var err: NSError?
                
                if let checkeddata: [String : AnyObject] = getJson(data) {
                    var json =  checkeddata["$collection"] as! [[String : AnyObject]];
                    if let nodes = Mapper<CidsObjectNode>().mapArray(json) {
                        
                        if (nodes.count>1) {
                            showWaitingHUD(text:"\(nodes.count) Objekte laden", indeterminate: false)
                        }
                        else {
                            showWaitingHUD(text:"Objekt laden")
                        }


                        self.blockingQueue.cancelAllOperations()
                        self.searchResults=[Entity: [GeoBaseEntity]]()
                        self.start=CidsConnector.currentTimeMillis();
                        self.blockingQueue.maxConcurrentOperationCount = 10
                        if nodes.count==0 {
                            handler()
                        }
                        else {
                            var i=0
                            for node in nodes {
                                print("\(node.classId!) : \(node.objectId!)")
                                let rightEntity=Entity.byClassId(node.classId!)!
                                let classKey=rightEntity.tableName()
                                
                                
                                func completionHandler(operation:GetEntityOperation, data: NSData!, response: NSURLResponse!, error: NSError!, queue: NSOperationQueue) -> (){
                                    if (error == nil) {
                                        // Success
                                        let statusCode = (response as! NSHTTPURLResponse).statusCode
                                        print("URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                                        
                                        if let json: [String : AnyObject] = getJson(data) {
                                            var gbEntity:GeoBaseEntity?
                                            
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
                                                print("could not find object from entity \(operation.entityName)")
                                            }
                                            let progress=Float(++i)/Float(nodes.count)
                                            setProgressInWaitingHUD(progress)

                                            if let gbe=gbEntity {
                                                if let _=self.searchResults[rightEntity] {
                                                    self.searchResults[rightEntity]!.append(gbe)
                                                }
                                                else {
                                                    self.searchResults.updateValue([gbe], forKey: rightEntity)
                                                }
                                            }
                                            //println("+")
                                            //println("\(leuchte.id)==>\(leuchte.leuchtenNummer):\(leuchte.typ)@\(leuchte.standort?.strasse)->\(leuchte.wgs84WKT)");
                                            
                                            if self.blockingQueue.operationCount==1 {
                                                let duration = (CidsConnector.currentTimeMillis() - self.start)
                                                handler();
                                                print("loaded \(duration)");
                                                
                                            }
                                            
                                        }else {
                                            print("no json data for \(operation.url)")
                                            //self.searchResults[0].append(Leuchte())
                                            
                                        }
                                    }else {
                                        // Failure
                                        print("URL Session Task Failed: %@", error.localizedDescription);
                                    }
                                }
                                let op=GetEntityOperation(baseUrl: self.baseUrl, domain: self.domain, entityName: classKey, id: node.objectId!, user: self.login, pass: self.password, queue: blockingQueue, completionHandler: completionHandler)
                                
                                op.enqueue()
                            }
                        }
                    }
                }
                else {
                    print("Problem in Request")
                }
                
            }
            else {
                // Failure
                print("URL Session Task Failed: %@", error.localizedDescription);
            }
            
        }
        
        let sop=SearchOperation(baseUrl: self.baseUrl, searchKey: "BELIS2.de.cismet.belis2.server.search.BelisObjectsWktSearch", user: self.login, pass: self.password, parameters: qp, completionHandler: mySearchCompletionHandler)
        
        sop.enqueue()
        
    }
    func executeSimpleServerAction(actionName actionName: String!, params: ActionParameterContainer, handler: (success:Bool) -> ()) {
        assert(loggedIn)
        
        func myActionCompletionHandler(data : NSData!, response : NSURLResponse!, error : NSError!) -> Void {
            if (error == nil) {
                // Success
                let statusCode = (response as! NSHTTPURLResponse).statusCode
                print("Action-URL Session Task no Error: HTTP Status Code\(statusCode)")
                if statusCode == 200 {
                    handler(success:true)
                }
                else {
                    handler(success:false)
                }
            }
            else {
                // Failure
                print("ActionURL Session Task Failed: %@", error.localizedDescription);
                handler(success:false)
            }
            
        }
        
        let op=ServerActionOperation(baseUrl: baseUrl, user: login, pass: password, actionName: actionName,params:params, completionHandler: myActionCompletionHandler)
        op.enqueue()
    }
    func uploadImageToWebDAV(image: UIImage, fileName: String , completionHandler: (data : NSData!, response : NSURLResponse!, error : NSError!) -> Void) {
        assert(loggedIn)
        
        let baseUrl="http://board.cismet.de/belis"
        
        let up=WebDavUploadImageOperation(baseUrl: baseUrl, user: Secrets.getWebDavUser(), pass: Secrets.getWebDavPass(), fileName: fileName, image:image) {
            (data, response, error) -> Void in
            
            completionHandler(data: data, response: response, error: error)
        }
        
        up.enqueue()
    }
    
    // MARK: - class functions
    class func currentTimeMillis() -> Int64{
        let nowDouble = NSDate().timeIntervalSince1970
        return Int64(nowDouble*1000) + Int64(nowDouble/1000)
    }
}

// MARK: - Entity Enum
enum Entity : String{
    case LEUCHTEN="Leuchten"
    case MASTEN="Masten"
    case MAUERLASCHEN="Mauerlaschen"
    case LEITUNGEN="Leitungen"
    case SCHALTSTELLEN="Schaltstellen"
    case ARBEITSAUFTRAEGE="Arbeitsaufträge"
    case VERANLASSUNGEN="Veranlassungen"
    case PROTOKOLLE="Protokolle"
    case ABZWEIGDOSEN="Abzweigdose"
    case STANDALONEGEOMS="Geometrie"
    
    static let allValues=[LEUCHTEN,MASTEN,MAUERLASCHEN,LEITUNGEN,SCHALTSTELLEN,ARBEITSAUFTRAEGE,VERANLASSUNGEN,PROTOKOLLE,ABZWEIGDOSEN,STANDALONEGEOMS]
    static func byIndex(index: Int) -> Entity {
        return allValues[index]
    }
    static func byClassId(cid: Int) -> Entity? {
        let dict=[27:LEUCHTEN, 26:MASTEN, 52:MAUERLASCHEN, 49:LEITUNGEN,51:SCHALTSTELLEN, 47:ARBEITSAUFTRAEGE,35:VERANLASSUNGEN,54:PROTOKOLLE, 50:ABZWEIGDOSEN,56:STANDALONEGEOMS]
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
        case .ARBEITSAUFTRAEGE:
            return 47
        case .VERANLASSUNGEN:
            return 35
        case .PROTOKOLLE:
            return 54
        case .ABZWEIGDOSEN:
            return 50
        case .STANDALONEGEOMS:
            return 56
            
        }
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
        case .ARBEITSAUFTRAEGE:
            return 5
        case .VERANLASSUNGEN:
            return 6
        case .PROTOKOLLE:
            return 7
        case .ABZWEIGDOSEN:
            return 8
        case .STANDALONEGEOMS:
            return 9
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
        case .ARBEITSAUFTRAEGE:
            return "ARBEITSAUFTRAG"
        case .VERANLASSUNGEN:
            return "VERANLASSUNG"
        case .PROTOKOLLE:
            return "ARBEITSPROTOKOLL"
        case .ABZWEIGDOSEN:
            return "ABZWEIGDOSE"
        case .STANDALONEGEOMS:
            return "GEOMETRIE"
        }
    }
    func isInSearchResults() -> Bool {
        return true
    }
}
