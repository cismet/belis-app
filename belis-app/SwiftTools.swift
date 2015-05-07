//
//  SwiftTools.swift
//  belis-app
//
//  Created by Thorsten Hell on 18/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

extension NSDate
{
    public func toDateString() -> String{
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "dd.MM.yyyy" // ad here HH:mm for debugging
        dateStringFormatter.locale = NSLocale(localeIdentifier: "de_DE")
        return dateStringFormatter.stringFromDate(self)
    }
}

class DateTransformFromMillisecondsTimestamp : TransformType {
    
    func transformFromJSON(value: AnyObject?) -> NSDate? {
        if let ms=value as? Int {
            var dms=Double(ms)
            return NSDate(timeIntervalSince1970: NSTimeInterval(dms/1000.0))
        }
       return nil
    }
    func transformToJSON(value: NSDate?) -> Int? {
        if let d=value {
            var ms:Int = Int(d.timeIntervalSince1970*1000.0)
            return ms
        }
        return nil
    }
}

class MatchingSearchItemsAnnotations : MKPointAnnotation {
    
}