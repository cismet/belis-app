//
//  DMSUrl.swift
//  belis-app
//
//  Created by Thorsten Hell on 18/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class DMSUrl : BaseEntity{
    var typ: String?
    var url: Url?
    var description: String?
    var name: String?
    
    convenience init(name: String, fileName: String) {
        self.init()
        description=name
        url=Url(webdavObjectName: fileName)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        url <- map["url_id"]
        description <- map["description"]
        name <- map["name"]
    }
    
    func getUrl() -> String{
        return 
            (url?.urlBase?.protPrefix ?? "")
            +
            "\(Secrets.getWebDavAuthString())@"
            +
            (url?.urlBase?.server ?? "")
            +
            (url?.urlBase?.path ?? "")
            +
            (url?.objectName ?? "")
    }
    
    func getTitle() -> String {
        return name ?? description ?? "Dokument \(id)"
    }
}

class Url : BaseEntity{
    init(webdavObjectName: String){
        super.init()
        objectName=webdavObjectName
        urlBase=UrlBase.WEBDAVURLBASE
    }
    required init?(_ map: Map) {
        super.init()
        mapping(map)
    }
    
    
    var urlBase: UrlBase?
    var objectName: String?
    override func mapping(map: Map) {
        id <- map["id"];
        urlBase <- map["url_base_id"]
        objectName <- map["object_name"]
    }
}

class UrlBase : BaseEntity{
    var protPrefix: String?
    var server: String?
    var path: String?
    static let WEBDAVURLBASE=UrlBase(protPrefix: "http://",server: "board.cismet.de/",path: "belis/")
    
    init(protPrefix:String, server: String, path:String){
        super.init()
        self.protPrefix=protPrefix
        self.server=server
        self.path=path
    
    }
    
    required init?(_ map: Map) {
        super.init(map)
    }

    
    override func mapping(map: Map) {
        id <- map["id"];
        protPrefix <- map["prot_prefix"]
        server <- map["server"]
        path <- map["path"]
    }
}