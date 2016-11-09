//
//  GenericFormViewController.swift
//  belis-app
//
//  Created by Thorsten Hell on 18.11.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import Foundation
import SwiftForms

class GenericFormViewController: FormViewController {
    var saveHandler : (()->())?
    var cancelHandler : (()->())?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Speichern", style: .plain, target: self, action: #selector(GenericFormViewController.save))
            let image=GlyphTools.sharedInstance().getGlyphedImage("icon-chevron-left", fontsize: 11, size: CGSize(width: 14, height: 14))
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain , target: self, action: #selector(GenericFormViewController.cancel))
        
    }
    
    
    func save() {
        self.dismiss(animated: true) { () -> Void in
            if let sh=self.saveHandler {
                sh()
            }
            else {
                //should not  happen >> log it
            }
        }
    }
    
    func cancel() {
        self.dismiss(animated: true) { () -> Void in
            if let ch=self.cancelHandler {
                ch()
            }
            else {
                //should not  happen >> log it
            }
        }
    }
    
}



