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
    
    required init?(map: Map) {
        mapping(map: map)
    }
    func mapping(map: Map) {
        classId <- map["LEGACY_CLASS_ID"];
        objectId <- map["LEGACY_OBJECT_ID"];
    }
}


class SingleQueryParameter : Mappable {
    var key: String?;
    var value: AnyObject?;
    init(){
        self.key="?";
        self.value="?" as AnyObject?;
    }
    required init?(map: Map) {
        mapping(map: map)
    }
    init(key: String, value: AnyObject) {
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
    required init?(map: Map) {
        mapping(map: map)
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
    required init?(map: Map) {
        mapping(map: map)
    }
    func mapping(map: Map) {
        params <- map["parameters"];
    }
    func append(_ key: String, value: AnyObject) {
        params.updateValue(value, forKey: key)
    }
}
