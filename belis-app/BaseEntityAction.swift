//
//  BaseEntityAction.swift
//  belis-app
//
//  Created by Thorsten Hell on 12/05/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation


class BaseEntityAction : NSObject{
    var title:String
    var style:UIAlertActionStyle
    var handler: (UIAlertAction?, BaseEntityAction, BaseEntity,UIViewController)->Void
    init(title: String, style: UIAlertActionStyle, handler: @escaping (UIAlertAction?, BaseEntityAction, BaseEntity,UIViewController)->Void){
        self.title=title
        self.style=style
        self.handler=handler
    }
}

protocol DocumentContainer {
    func addDocument(_ document: DMSUrl)
}
