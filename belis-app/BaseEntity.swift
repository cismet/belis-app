//
//  BaseEntity.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class BaseEntity : MapperProtocol, CellDataProvider{
    var data: [String: [CellData]] = ["main":[]]
    
    required init(){
    }

    var id: Int = -1
    
    func map(mapper: Mapper) {
        
    }
    
    func getAllData() -> [String: [CellData]] {
        return data
    }
    
}