//
//  CidsObjectNode.swift
//  belis-app
//
//  Created by Thorsten Hell on 16/01/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class CidsObjectNode : MapperProtocol {
    var fucker :NSObject?;
    var classId :Int?;
    var objectId :Int?;
    required init(){};
    func map(mapper: Mapper) {
        classId <= mapper["classId"];
        objectId <= mapper["objectId"];
    }
}


class SingleQueryParameter : MapperProtocol {
    var key: String?;
    var value: String?;
    required init(){
        self.key="?";
        self.value="?";
    }
    init(key: String, value: String) {
        self.key=key;
        self.value=value;
    }
    func map(mapper: Mapper) {
        key <= mapper["key"];
        value <= mapper["value"];
    }
    
}

class QueryParameters : MapperProtocol {
    var list: [SingleQueryParameter]?;
    required init(){};

    init(list: [SingleQueryParameter]) {
        self.list=list;
    }
    func map(mapper: Mapper) {
        list <= mapper["list"];
    }
}

//class CollectionResult : MapperProtocol {
//    var collection : [ ]
//}



