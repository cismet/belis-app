//
//  DMSUrl.swift
//  belis-app
//
//  Created by Thorsten Hell on 18/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

// MARK:
class DMSUrl : BaseEntity{
    var typ: String?
    var url: Url?
    var description: String?
    var name: String?

    // MARK: - convenience constructor
    convenience init(name: String, fileName: String) {
        self.init()
        description=name
        url=Url(webdavObjectName: fileName)
    }
    
    // MARK: - essential overrides BaseEntity
    override func mapping(map: Map) {
        id <- map["id"];
        url <- map["url_id"]
        description <- map["description"]
        name <- map["name"]
    }
    
    // MARK: - object functions
    func getUrl() -> String{
        let prot=(url?.urlBase?.protPrefix ?? "")
        let auth=Secrets.getWebDavAuthString()
        let server=(url?.urlBase?.server ?? "")
        let path=(url?.urlBase?.path ?? "")
        let objName=url?.objectName ?? ""
        
        return "\(prot)\(auth)@\(server)\(path)\(objName)"
    }
    func getPublicUrl() -> String{
        let prot=(url?.urlBase?.protPrefix ?? "")
        let server=(url?.urlBase?.server ?? "")
        let path=(url?.urlBase?.path ?? "")
        let objName=url?.objectName ?? ""
        
        return "\(prot)\(server)\(path)\(objName)"
    }
    func getTitle() -> String {
        return name ?? description ?? "Dokument \(id)"
    }
}
// MARK:
class Url : BaseEntity{
    init(webdavObjectName: String){
        super.init()
        objectName=webdavObjectName
        urlBase=CidsConnector.sharedInstance().getWebDAVBaseUrl()
    }
    required init?(map: Map) {
        super.init()
        mapping(map: map)
    }
    
    var urlBase: UrlBase?
    var objectName: String?
    // MARK: - essential overrides BaseEntity
    override func mapping(map: Map) {
        id <- map["id"];
        urlBase <- map["url_base_id"]
        objectName <- map["object_name"]
    }
}
// MARK:
class UrlBase : BaseEntity{
    var protPrefix: String?
    var server: String?
    var path: String?
    
    
    init(protPrefix:String, server: String, path:String){
        super.init()
        self.protPrefix=protPrefix
        self.server=server
        self.path=path
    
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    func getUrl() -> String {
        return "\(protPrefix ?? "")\(server ?? "")\(path ?? "")"
    }
    // MARK: - essential overrides BaseEntity
    override func mapping(map: Map) {
        id <- map["id"];
        protPrefix <- map["prot_prefix"]
        server <- map["server"]
        path <- map["path"]
    }
}
