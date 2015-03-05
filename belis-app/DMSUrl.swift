//
//  DMSUrl.swift
//  belis-app
//
//  Created by Thorsten Hell on 18/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class DMSUrl : BaseEntity, MapperProtocol{
    var typ: String?
    var url: Url?
    var description: String?
    var name: String?
    
    required init(){}
    override func map(mapper: Mapper) {
        id <= mapper["id"];
        url <= mapper["url_id"]
        description <= mapper["description"]
        name <= mapper["name"]
    }
    
    func getUrl() -> String{
        return 
            (url?.urlBase?.protPrefix? ?? "")
            +
            "\(Secrets.getWebDavAuthString())@"
            +
            (url?.urlBase?.server? ?? "")
            +
            (url?.urlBase?.path? ?? "")
            +
            (url?.objectName? ?? "")
    }
    
    func getTitle() -> String {
        return name? ?? description? ?? "Dokument \(id)"
    }
}

class Url : BaseEntity, MapperProtocol{
    var urlBase: UrlBase?
    var objectName: String?
    required init(){}
    override func map(mapper: Mapper) {
        id <= mapper["id"];
        urlBase <= mapper["url_base_id"]
        objectName <= mapper["object_name"]
    }
}

class UrlBase : BaseEntity, MapperProtocol{
    var protPrefix: String?
    var server: String?
    var path: String?
    required init(){}
    override func map(mapper: Mapper) {
        id <= mapper["id"];
        protPrefix <= mapper["prot_prefix"]
        server <= mapper["server"]
        path <= mapper["path"]
    }
}