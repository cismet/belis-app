//
//  Strasse.swift
//  belis-app
//
//  Created by Thorsten Hell on 13/04/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class Strasse : BaseEntity, MapperProtocol{
    var name: String?
    var key: String?
    required init() {
        
    }
    
    override func map(mapper: Mapper) {
        super.id <= mapper["id"]
        name <= mapper["strasse"]
        key <= mapper["pk"]
    }
}
