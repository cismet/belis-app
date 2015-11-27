//
//  Strasse.swift
//  belis-app
//
//  Created by Thorsten Hell on 13/04/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper


class Strasse : BaseEntity{
    var name: String?
    var key: String?

    // MARK: - required init because of ObjectMapper
    override func mapping(map: Map) {
        super.id <- map["id"]
        name <- map["strasse"]
        key <- map["pk"]
    }
}
