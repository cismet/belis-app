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
    var id: Int = -1
    // MARK: - Constructor
    init() {
        
    }
    // MARK: - required init because of ObjectMapper
    required init?(map: Map) {
        mapping(map: map)
    }
  
    // MARK: - essential methods
    // - will be overridden
    func mapping(map: Map) {
    
    }
    func getType() -> Entity {
        assert(false, "This method must be overridden")
        return Entity.LEUCHTEN
    }
}
