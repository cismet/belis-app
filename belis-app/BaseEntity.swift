//
//  BaseEntity.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseEntity : Mappable {
    init() {
        
    }
    
    required init?(_ map: Map) {
        mapping(map)
    }

    var id: Int = -1
    
    func mapping(map: Map) {
    
    }
    
}