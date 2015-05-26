//
//  CidsObjectNode.swift
//  belis-app
//
//  Created by Thorsten Hell on 16/01/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class CidsObjectNode : Mappable {
    var fucker :NSObject?;
    var classId :Int?;
    var objectId :Int?;
    
    required init?(_ map: Map) {
        mapping(map)
    }
    func mapping(map: Map) {
        classId <- map["classId"];
        objectId <- map["objectId"];
    }
}


class SingleQueryParameter : Mappable {
    var key: String?;
    var value: String?;
    init(){
        self.key="?";
        self.value="?";
    }
    required init?(_ map: Map) {
        mapping(map)
    }
    init(key: String, value: String) {
        self.key=key;
        self.value=value;
    }
    func mapping(map: Map) {
        key <- map["key"];
        value <- map["value"];
    }
    
}

class QueryParameters : Mappable {
    var list: [SingleQueryParameter]?;
    
    init(list: [SingleQueryParameter]) {
        self.list=list;
    }
    required init?(_ map: Map) {
        mapping(map)
    }
    func mapping(map: Map) {
        list <- map["list"];
    }
}




class ActionParameterContainer : Mappable {
    var params:[String : AnyObject] = [:];
    
    init(params: [String : AnyObject]) {
        self.params=params;
    }
    required init?(_ map: Map) {
        mapping(map)
    }
    func mapping(map: Map) {
        params <- map["parameters"];
    }
}

//class CollectionResult : MapperProtocol {
//    var collection : [ ]
//}



