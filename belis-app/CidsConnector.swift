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

open class CidsConnector {
    
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
            UserDefaults.standard.set(tlsEnabled, forKey: "tlsEnabled")
        }
    }
    var pureBaseUrl="192.168.178.38" {
        didSet {
            UserDefaults.standard.set(pureBaseUrl, forKey: "cidsPureBaseURL")
        }
    }
    var baseUrlport="8890" {
        didSet {
            UserDefaults.standard.set(baseUrlport, forKey: "cidsBaseURLPort")
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
            return NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask,true)[0]
        }
    }
    
    var serverCert: String?{
        didSet {
            UserDefaults.standard.set(serverCert, forKey: "serverCert")
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
                return Bundle.main.path(forResource: "server.cert.dev", ofType:"der")!
            }
        }
    }
    
    var clientCert: String? {
        didSet {
            UserDefaults.standard.set(clientCert, forKey: "clientCert")
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
                return Bundle.main.path(forResource: "client.cert.dev", ofType: "p12")!
            }
        }
    }
    
    var clientCertContainerPass: String = ""{
        didSet {
            UserDefaults.standard.set(clientCertContainerPass, forKey: "clientCertContainerPass")
        }
    }
    
    // MARK: - other variables
    fileprivate var login : String!
    fileprivate var password : String!
    fileprivate let domain = "BELIS2"
    
    let defaultErrorMessageNoFurtherInformation="no further Information available. Sorry :-/"
    
    let backgroundQueue = CancelableOperationQueue(name: "backgroundQueue", afterCancellation: {})
    
    let cidsURLSessionQueue = OperationQueue()
    let cidsPickyURLSessionQueue = OperationQueue()
    let webdavURLSessionQueue = OperationQueue()
    
    var searchResults=[Entity: [GeoBaseEntity]]()
    
    var allArbeitsauftraegeBeforeCurrentSelection=[Entity: [GeoBaseEntity]]()
    var selectedArbeitsauftrag: Arbeitsauftrag?
    
    var veranlassungsCache=[String:Veranlassung]()
    let configuration = URLSessionConfiguration.default
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
        cidsURLSessionQueue.maxConcurrentOperationCount=10
        cidsPickyURLSessionQueue.maxConcurrentOperationCount=10
        webdavURLSessionQueue.maxConcurrentOperationCount=10
        
        let storedTLSEnabled: AnyObject? = UserDefaults.standard.object(forKey: "tlsEnabled") as AnyObject?
        if let storedTLSEnabledAsBool=storedTLSEnabled as? Bool {
            tlsEnabled=storedTLSEnabledAsBool
        }
        let storedPureUrlBase: AnyObject? = UserDefaults.standard.object(forKey: "cidsPureBaseURL") as AnyObject?
        if let storedPureUrlBaseAsString=storedPureUrlBase as? String {
            pureBaseUrl=storedPureUrlBaseAsString
        }
        
        let storedPort: AnyObject? = UserDefaults.standard.object(forKey: "cidsBaseURLPort") as AnyObject?
        if let storedPortAsString=storedPort as? String {
            baseUrlport=storedPortAsString
        }
        
        let storedServerCertPath: AnyObject? = UserDefaults.standard.object(forKey: "serverCert") as AnyObject?
        if let storedServerCertPathString=storedServerCertPath as? String {
            serverCert=storedServerCertPathString
        }
        let storedClientCertPath: AnyObject? = UserDefaults.standard.object(forKey: "clientCert") as AnyObject?
        if let storedClientCertPathString=storedClientCertPath as? String {
            clientCert=storedClientCertPathString
        }
        let storedClientCertContainerPass: AnyObject? = UserDefaults.standard.object(forKey: "clientCertContainerPass") as AnyObject?
        if let storedClientCertContainerPassString=storedClientCertContainerPass as? String {
            clientCertContainerPass=storedClientCertContainerPassString
        }
        else if simulator{
            clientCertContainerPass="123456"
        }
    }
    
    // MARK: - functions
    func login(_ user :String, password :String, handler: @escaping (Bool) -> ()) {
        self.login=user+"@"+domain
        self.password=password
        func cH(_ loggedIn: Bool, error: Error?) -> () {
            self.loggedIn=loggedIn
            
            if loggedIn {
                print("logged in")
            }
            else {
                print("Error\(error)")
            }
            if (loggedIn) {
                func teamsCompletionHandler(_ operation: GetAllEntitiesOperation, data: Data?, response: URLResponse?, error: Error?, queue: OperationQueue){
                    if (error == nil) {
                        // Success
                        let statusCode = (response as! HTTPURLResponse).statusCode
                        print("teams::GetAllEntities::URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                        if let checkeddata: [String : AnyObject] = getJson(data!) {
                            let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                            if let teams = Mapper<Team>().mapArray(JSONArray: json) {
                                
                                print("\(teams.count) Teams vorhanden")
                                let sortedTeams=teams.sorted(by: Team.ascending)
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
                        print("teams::GetAllEntities::URL Session Task Failed: %@", error?.localizedDescription ?? defaultErrorMessageNoFurtherInformation);
                    }
                    
                    handler(loggedIn)
                    
                }
                let teamsOperation=GetAllEntitiesOperation(baseUrl: baseUrl, domain: domain, entityName: "team", user: login, pass: password, queue: backgroundQueue, completionHandler: teamsCompletionHandler )
                
                teamsOperation.enqueue()
                getBackgroundLists()
            }
            else {
                handler(loggedIn)
            }
            
        }
        let loginOp=LoginOperation(baseUrl: baseUrl, domain: domain,user: login, pass: password,completionHandler: cH )
        loginOp.enqueue()
    }
    func getBackgroundLists() {
        
        func arbeitsprotokollstatusCompletionHandler(_ operation: GetAllEntitiesOperation, data: Data?, response: URLResponse?, error: Error?, queue: OperationQueue){
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("arbeitsprotokollstati::GetAllEntities::URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                if let checkeddata: [String : AnyObject] = getJson(data!) {
                    let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                    if let apsts = Mapper<ArbeitsprotokollStatus>().mapArray(JSONArray: json) {
                        
                        print("\(apsts.count) Protokollstati vorhanden")
                        let sortedApsts=apsts.sorted(by: ArbeitsprotokollStatus.ascending)
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
                    print("arbeitsprotokollstati::GetAllEntities::URL Session Task Failed: %@", error?.localizedDescription ?? defaultErrorMessageNoFurtherInformation);
                }
            }
        }
        let arbeitsprotokollstatiOperation=GetAllEntitiesOperation(baseUrl: baseUrl, domain: domain, entityName: "arbeitsprotokollstatus", user: login, pass: password, queue: backgroundQueue, completionHandler: arbeitsprotokollstatusCompletionHandler )
        
        func leuchtentypenCompletionHandler(_ operation: GetAllEntitiesOperation, data: Data?, response: URLResponse?, error: Error?, queue: OperationQueue){
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("leuchtentypen::GetAllEntities::URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                if let checkeddata: [String : AnyObject] = getJson(data!) {
                    let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                    if let lts = Mapper<LeuchtenTyp>().mapArray(JSONArray: json) {
                        
                        print("\(lts.count) Leuchtentypen vorhanden")
                        let sortedLts=lts.sorted(by: LeuchtenTyp.ascending)
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
                print("leuchtentypen::GetAllEntities::URL Session Task Failed: %@", error?.localizedDescription ?? "no further Info");
            }
            
        }
        let leuchtentypenOperation=GetAllEntitiesOperation(baseUrl: baseUrl, domain: domain, entityName: "tkey_leuchtentyp", user: login, pass: password, queue: backgroundQueue, completionHandler: leuchtentypenCompletionHandler)
        
        func leuchtmittelCompletionHandler(_ operation: GetAllEntitiesOperation, data: Data?, response: URLResponse?, error: Error?, queue: OperationQueue){
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("leuchtmittel::GetAllEntities::URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                if let checkeddata: [String : AnyObject] = getJson(data!) {
                    let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                    if let lms = Mapper<Leuchtmittel>().mapArray(JSONArray: json) {
                        
                        print("\(lms.count) Leuchtmittel vorhanden")
                        let sortedLms=lms.sorted(by: Leuchtmittel.ascending)
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
                print("leuchtmittel::GetAllEntities::URL Session Task Failed: %@", error?.localizedDescription ?? defaultErrorMessageNoFurtherInformation);
            }
            
        }
        
        let leuchtmittelOperation=GetAllEntitiesOperation(baseUrl: baseUrl, domain: domain, entityName: "leuchtmittel", user: login, pass: password, queue: backgroundQueue, completionHandler: leuchtmittelCompletionHandler)
        
        func rundsteuerempfaengerCompletionHandler(_ operation: GetAllEntitiesOperation, data: Data?, response: URLResponse?, error: Error?, queue: OperationQueue){
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("runsdsteuerempfaenger::GetAllEntities::URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                if let checkeddata: [String : AnyObject] = getJson(data!) {
                    let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                    if let rses = Mapper<Rundsteuerempfaenger>().mapArray(JSONArray: json) {
                        
                        print("\(rses.count) Rundsteuerempfänger vorhanden")
                        let sortedRses=rses.sorted(by: Rundsteuerempfaenger.ascending)
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
                print("runsdsteuerempfaenger::GetAllEntities::URL Session Task Failed with error: \(error?.localizedDescription ?? defaultErrorMessageNoFurtherInformation) for URL: \(operation.url)" );
            }
            
        }
        let rundsteuerempfaengerOperation=GetAllEntitiesOperation(baseUrl: baseUrl, domain: domain, entityName: "rundsteuerempfaenger", user: login, pass: password, queue: backgroundQueue, completionHandler: rundsteuerempfaengerCompletionHandler)
        
        arbeitsprotokollstatiOperation.enqueue()
        leuchtentypenOperation.enqueue()
        leuchtmittelOperation.enqueue()
        rundsteuerempfaengerOperation.enqueue()
        
    }
    func sortSearchResults() {
        for key in searchResults.keys {
            searchResults[key]?.sort {
                return $0.id < $1.id
            }
        }
    }
    func getJson(_ data: Data) -> [String: AnyObject]?{
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject]
        }
        catch {
            return nil
        }
    }
    func searchArbeitsauftraegeForTeam(_ team: Team, queue: CancelableOperationQueue, handler: @escaping () -> ()) {
        assert(loggedIn)
        var qp=QueryParameters(list:[
            SingleQueryParameter(key: "arbeitsauftragEnabled", value: true as AnyObject),
            SingleQueryParameter(key: "activeObjectsOnly", value: true as AnyObject),
            SingleQueryParameter(key: "zugewiesenAn", value: team.id as AnyObject) //39
            ]);
        func mySearchCompletionHandler(_ data : Data?, response : URLResponse?, error : Error?) -> Void {
            if (error == nil) {
                print("Arbeitsaufträge Search kein Fehler")
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("URL Session Task Succeeded: HTTP \(statusCode)")
                if (!queue.cancelRequested) {
                    if let checkeddata: [String : AnyObject] = getJson(data!) {
                        let json =  checkeddata["$collection"] as! [[String : AnyObject]];
                        if let nodes = Mapper<CidsObjectNode>().mapArray(JSONArray: json) {
                            
                            if nodes.count>1 {
                                showWaitingHUD(queue: queue, text: "\(nodes.count) Arbeitsaufträge laden", indeterminate: false )
                            }
                            else {
                                showWaitingHUD(queue: queue,text: "Arbeitsauftrag laden", indeterminate: false )
                            }
                            //queue.cancelAllOperations()
                            self.searchResults=[Entity: [GeoBaseEntity]]()
                            self.start=CidsConnector.currentTimeMillis();
                            if nodes.count==0 {
                                handler()
                            }
                            else {
                                var i=0
                                if (!queue.cancelRequested) {
                                    for node in nodes {
                                        let rightEntity=Entity.byClassId(node.classId!)!
                                        assert(rightEntity==Entity.ARBEITSAUFTRAEGE)
                                        let classKey=rightEntity.tableName()
                                        func getAACompletionHandler(_ operation:GetEntityOperation, data: Data?, response: URLResponse?, error: Error?, queue: CancelableOperationQueue) -> (){
                                            if (error == nil) {
                                                // Success
                                                let statusCode = (response as! HTTPURLResponse).statusCode
                                                print("arbeitsauftrag::GetEntity::URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                                                
                                                if let json: [String : AnyObject] = getJson(data!) {
                                                    var aa:Arbeitsauftrag?
                                                    aa = Mapper<Arbeitsauftrag>().map(JSON: json)!
                                                    i=i+1
                                                    let progress=Float(i)/Float(nodes.count)
                                                    setProgressInWaitingHUD(progress, forQueue: queue)
                                                    if (!queue.cancelRequested) {
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
                                                    }
                                                    if (queue.operationCount==1 && !queue.cancelRequested) {
                                                        let duration = (CidsConnector.currentTimeMillis() - self.start)
                                                        handler();
                                                        print("loaded \(duration)");
                                                        
                                                    }
                                                    else {
                                                        print("not 1=\(queue.operationCount)");
                                                    }
                                                    
                                                }else {
                                                    print("no json data for \(operation.url)")
                                                    //self.searchResults[0].append(Leuchte())
                                                    
                                                }
                                            }else {
                                                // Failure
                                                print("arbeitsauftrag::GetEntity::URL Session Task Failed: %@", error?.localizedDescription ?? defaultErrorMessageNoFurtherInformation);
                                            }
                                        }
                                        if (!queue.cancelRequested) {
                                            let op=GetEntityOperation(baseUrl: self.baseUrl, domain: self.domain, entityName: classKey, id: node.objectId!, user: self.login, pass: self.password, queue: queue, completionHandler: getAACompletionHandler)
                                            
                                            op.enqueue()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else {
                print("Arbeitsaufträge Search Cancelled oder Fehler")
            }
            
        }
        if (!queue.cancelRequested) {
            let sop=SearchOperation(baseUrl: self.baseUrl,searchKey: "BELIS2.de.cismet.belis2.server.search.ArbeitsauftragSearchStatement" , user: self.login, pass: self.password, queue:queue, parameters: qp, completionHandler: mySearchCompletionHandler)
            
            sop.enqueue()
        }
        
    }
    
    func refreshArbeitsauftrag(_ arbeitsauftrag: Arbeitsauftrag?, queue: CancelableOperationQueue = CancelableOperationQueue(name: "refreshArbeitsauftrag", afterCancellation: {}), handler: @escaping (_ success: Bool)->() ){
        if let _=arbeitsauftrag {
            func completionHandler(_ operation:GetEntityOperation, data: Data?, response: URLResponse?, error: Error?, queue: OperationQueue) -> (){
                if (error == nil) {
                    // Success
                    let statusCode = (response as! HTTPURLResponse).statusCode
                    print("arbeitsauftrag::GetEntity::URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                    if let json: [String : AnyObject] = getJson(data!) {
                        //let sel=self.mainVC!.tableView.indexPathForSelectedRow
                        let entity = Mapper<Arbeitsauftrag>().map(JSON: json)
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
                                    i += 1
                                }
                            }
                            
                            self.mainVC!.fillArbeitsauftragIntoTable(aa)
                            self.mainVC!.visualizeAllSearchResultsInMap(zoomToShowAll: false, showActivityIndicator: true)
                            //  if let s=sel  {
                            //  self.mainVC!.tableView.selectRowAtIndexPath(s, animated: false, scrollPosition: UITableViewScrollPosition.None)
                            //  }
                            
                            handler(true)
                            return
                        }
                        
                    }else {
                        print("no json data for \(operation.url)")
                        //self.searchResults[0].append(Leuchte())
                        
                    }
                }else {
                    // Failure
                    print("arbeitsauftrag::GetEntity::URL Session Task Failed: %@", error?.localizedDescription ?? defaultErrorMessageNoFurtherInformation);
                }
                
                handler(false)
            }
            
            let op=GetEntityOperation(baseUrl: self.baseUrl, domain: self.domain, entityName: Entity.ARBEITSAUFTRAEGE.tableName(), id: arbeitsauftrag!.id, user: self.login, pass: self.password, queue: queue, completionHandler: completionHandler)
            op.enqueue()
        }
    }
    
    func getVeranlassungByNummer(_ vnr:String, handler: @escaping (_ veranlassung:Veranlassung?) -> ()) {
        assert(loggedIn)
        
        var qp=QueryParameters(list:[
            SingleQueryParameter(key: "nummer", value: vnr as AnyObject)
            ]);
        
        func mySearchCompletionHandler(_ data : Data?, response : URLResponse?, error : Error?) -> Void {
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("veranlassungByNummer::Search::URL Session Task Succeeded: HTTP \(statusCode)")
                
                if let cidsJsonCollection: [String : AnyObject] = getJson(data!) {
                    // Content is now a cids Collection of json Data
                    
                    if let jsonArray=cidsJsonCollection["$collection"] as? [AnyObject] {
                        var veranlassung: Veranlassung?
                        veranlassung = Mapper<Veranlassung>().map(JSON: jsonArray[0] as! [String : Any])
                        handler(veranlassung)
                    }
                }
                else {
                    print("Problem in Request")
                }
                
            }
            else {
                // Failure
                print("veranlassungByNummer::Search::URL Session Task Failed: %@", error?.localizedDescription ?? defaultErrorMessageNoFurtherInformation);
            }
            handler(nil)
        }
        
       
        
        let sop=SearchOperation(baseUrl: self.baseUrl, searchKey: "BELIS2.de.cismet.belis2.server.search.VeranlassungByNummerSearch", user: self.login, pass: self.password, queue:CidsConnector.sharedInstance().backgroundQueue, parameters: qp, completionHandler: mySearchCompletionHandler)
        
        sop.enqueue()
        
    }
    
    
    func search(_ ewktMapContent: String,leuchtenEnabled: Bool, mastenEnabled: Bool,mauerlaschenEnabled: Bool, leitungenEnabled: Bool, schaltstellenEnabled: Bool,queue: CancelableOperationQueue, handler: @escaping () -> ()) {
        assert(loggedIn)
        var qp=QueryParameters(list:[
            SingleQueryParameter(key: "LeuchteEnabled", value: leuchtenEnabled as AnyObject),
            SingleQueryParameter(key: "MastOhneLeuchtenEnabled", value: mastenEnabled as AnyObject),
            SingleQueryParameter(key: "MauerlascheEnabled", value: mauerlaschenEnabled as AnyObject),
            SingleQueryParameter(key: "LeitungEnabled", value: leitungenEnabled as AnyObject),
            SingleQueryParameter(key: "SchaltstelleEnabled", value: schaltstellenEnabled as AnyObject),
            SingleQueryParameter(key: "GeometryFromWkt", value: ewktMapContent as AnyObject)
            ]);
        
        func mySearchCompletionHandler(_ data : Data?, response : URLResponse?, error : Error?) -> Void {
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("mainSearch::URL Session Task Succeeded: HTTP \(statusCode)")
                var err: Error?
                
                if (!queue.cancelRequested) {
                    if let checkeddata: [String : AnyObject] = getJson(data!) {
                        var json =  checkeddata["$collection"] as! [[String : AnyObject]];
                        if let nodes = Mapper<CidsObjectNode>().mapArray(JSONArray: json) {
                            if (nodes.count>1) {
                                showWaitingHUD(queue: queue, text:"\(nodes.count) Objekte laden", indeterminate: false)
                            }
                            else {
                                showWaitingHUD(queue:queue, text:"Objekt laden")
                            }
                            
                            //queue.cancelAllOperations()
                            
                            self.searchResults=[Entity: [GeoBaseEntity]]()
                            self.start=CidsConnector.currentTimeMillis();
                            
                            if nodes.count==0 {
                                handler()
                            }
                            else {
                                var i=0
                                if (!queue.cancelRequested) {
                                    for node in nodes {
                                        let rightEntity=Entity.byClassId(node.classId!)!
                                        let classKey=rightEntity.tableName()
                                        func completionHandler(_ operation:GetEntityOperation, data: Data?, response: URLResponse?, error: Error?, queue: CancelableOperationQueue) -> (){
                                            if (error == nil && !queue.cancelRequested) {
                                                // Success
                                                let statusCode = (response as! HTTPURLResponse).statusCode
                                                print("getObject::GetEntity::URL Session Task Succeeded: HTTP \(statusCode) for \(operation.url)")
                                                
                                                if let json: [String : AnyObject] = getJson(data!) {
                                                    var gbEntity:GeoBaseEntity?
                                                    
                                                    switch (rightEntity){
                                                    case .LEUCHTEN:
                                                        gbEntity = Mapper<Leuchte>().map(JSON: json)!
                                                    case .MASTEN:
                                                        gbEntity = Mapper<Standort>().map(JSON: json)!
                                                    case .MAUERLASCHEN:
                                                        gbEntity = Mapper<Mauerlasche>().map(JSON: json)!
                                                    case .LEITUNGEN:
                                                        gbEntity = Mapper<Leitung>().map(JSON: json)!
                                                    case .SCHALTSTELLEN:
                                                        gbEntity = Mapper<Schaltstelle>().map(JSON: json)!
                                                    default:
                                                        print("could not find object from entity \(operation.entityName)")
                                                    }
                                                    i=i+1
                                                    let progress=Float(i)/Float(nodes.count)
                                                    setProgressInWaitingHUD(progress, forQueue: queue)
                                                    if (!queue.cancelRequested) {
                                                        if let gbe=gbEntity {
                                                            if let _=self.searchResults[rightEntity] {
                                                                self.searchResults[rightEntity]!.append(gbe)
                                                            }
                                                            else {
                                                                self.searchResults.updateValue([gbe], forKey: rightEntity)
                                                            }
                                                        }
                                                    }
                                                    if (queue.operationCount==1 && !queue.cancelRequested) {
                                                        let duration = (CidsConnector.currentTimeMillis() - self.start)
                                                        handler();
                                                        print("loaded \(duration)");
                                                        
                                                    }
                                                    
                                                }else {
                                                    print("no json data for \(operation.url)")
                                                    //self.searchResults[0].append(Leuchte())
                                                    
                                                }
                                            }else if (queue.cancelRequested){
                                                print("CancelRequested! (and \(queue.operationCount) operations still alive in \(queue.name))")
                                            }
                                            else {
                                                // Failure
                                                print("getObject::GetEntity::URL Session Task Failed or Cancelled: \(error?.localizedDescription ?? defaultErrorMessageNoFurtherInformation)");
                                                
                                            }
                                        }
                                        if (!queue.cancelRequested) {
                                            let op=GetEntityOperation(baseUrl: self.baseUrl, domain: self.domain, entityName: classKey, id: node.objectId!, user: self.login, pass: self.password, queue: queue, completionHandler: completionHandler)
                                            
                                            op.enqueue()
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else {
                        print("Problem in Request")
                    }
                }
                
            }
            else {
                // Failure
                print("mainSearch::URL Session Task Failed or Cancelled: \(error?.localizedDescription ?? defaultErrorMessageNoFurtherInformation)");
            }
            
        }
        if (!queue.cancelRequested) {
            let sop=SearchOperation(baseUrl: self.baseUrl, searchKey: "BELIS2.de.cismet.belis2.server.search.BelisObjectsWktSearch", user: self.login, pass: self.password, queue:queue, parameters: qp, completionHandler: mySearchCompletionHandler)
            
            sop.enqueue()
            print ("Search enqueued in \(queue.name). Queue with \(queue.operationCount) operations")
            
        }
        
    }
    func executeSimpleServerAction(actionName: String!, params: ActionParameterContainer, handler: @escaping (_ success:Bool) -> ()) {
        assert(loggedIn)
        
        func myActionCompletionHandler(_ data : Data?, response : URLResponse?, error : Error?) -> Void {
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("Action::URL Session Task no Error: HTTP Status Code\(statusCode)")
                if statusCode == 200 {
                    handler(true)
                }
                else {
                    handler(false)
                }
            }
            else {
                // Failure
                print("Action::URL Session Task Failed: %@", error?.localizedDescription ?? defaultErrorMessageNoFurtherInformation);
                handler(false)
            }
            
        }
        let op=ServerActionOperation(baseUrl: baseUrl, user: login, pass: password, actionName: actionName,params:params, completionHandler: myActionCompletionHandler)
        op.enqueue()
    }
    func uploadImageToWebDAV(_ image: UIImage, fileName: String , completionHandler: @escaping (_ data : Data?, _ response : URLResponse?, _ error : Error?) -> Void) {
        assert(loggedIn)
        
        let baseUrl="http://board.cismet.de/belis"
        
        let up=WebDavUploadImageOperation(baseUrl: baseUrl, user: Secrets.getWebDavUser(), pass: Secrets.getWebDavPass(), fileName: fileName, image:image) {
            (data, response, error) -> Void in
            
            completionHandler(data, response, error)
        }
        
        up.enqueue()
    }
    
    // MARK: - class functions
    class func currentTimeMillis() -> Int64{
        let nowDouble = Date().timeIntervalSince1970
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
    static func byIndex(_ index: Int) -> Entity {
        return allValues[index]
    }
    static func byClassId(_ cid: Int) -> Entity? {
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
