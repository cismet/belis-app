//
//  PureDocumentContainer.swift
//  belis-app
//
//  Created by Thorsten Hell on 13.12.16.
//  Copyright © 2016 cismet. All rights reserved.
//

import Foundation

class PureDocumentContainer: BaseEntity, DocumentContainer {
    var dokumente: [DMSUrl] = []

    
    func addDocument(_ document: DMSUrl) {
        dokumente.append(document)
    }
    
    override func getType() -> Entity {
        return Entity.VERANLASSUNGEN
    }
    
}
