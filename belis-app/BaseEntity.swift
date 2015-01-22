//
//  BaseEntity.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseEntity : MapperProtocol{
    required init(){
    }

    var id: Int?
    
    func map(mapper: Mapper) {
        
    }
    
}