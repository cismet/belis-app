//
//  DMSUrl.swift
//  belis-app
//
//  Created by Thorsten Hell on 18/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class DMSUrl : BaseEntity, Mappable{
    var typ: String?
    var url: Url?
    var description: String?
    var name: String?
    
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

class Url : BaseEntity, Mappable{
    var urlBase: UrlBase?
    var objectName: String?
    override func mapping(map: Map) {
        id <- map["id"];
        urlBase <- map["url_base_id"]
        objectName <- map["object_name"]
    }
}

class UrlBase : BaseEntity, Mappable{
    var protPrefix: String?
    var server: String?
    var path: String?
    override func mapping(map: Map) {
        id <- map["id"];
        protPrefix <- map["prot_prefix"]
        server <- map["server"]
        path <- map["path"]
    }
}