//
//  GenericFormViewController.swift
//  belis-app
//
//  Created by Thorsten Hell on 18.11.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import Foundation
import SwiftForms

class GenericFormViewController: FormViewController, Refreshable {
    var saveHandler : (()->())?
    var cancelHandler : (()->())?
    
    var preSaveCheck: ()->CheckResult={
        return CheckResult(passed: true)
    }

    var preCancelCheck: ()->CheckResult={
        return CheckResult(passed: true)
    }

    
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
        let check=preSaveCheck()
        if (check.passed) {
            self.dismiss(animated: true) { () -> Void in
                if let sh=self.saveHandler {
                    sh()
                }
                else {
                    //should not  happen >> log it
                }
            }
        }
        else {
            let alert = UIAlertController(title: check.title, message: check.message, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (ACTION :UIAlertAction)in
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    func cancel() {
        if let nc=self.navigationController {
            nc.popViewController(animated: true)
            if let ch=self.cancelHandler {
                ch()
            }
            else {
                //should not  happen >> log it
            }
        }
        else {
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
    
    func refresh() {
        print("refresh ¯\\_(ツ)_/¯")
    }

    
}

class CheckResult {
    var passed: Bool
    var message: String
    var title: String
    
    init(passed: Bool, title:String="", withMessage:String = ""){
        self.passed=passed
        self.title=title
        self.message=withMessage
    }
}

