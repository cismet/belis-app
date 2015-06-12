//
//  SwiftTools.swift
//  belis-app
//
//  Created by Thorsten Hell on 18/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper
import ImageIO
import AssetsLibrary
import UIKit

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

extension ALAssetsLibrary {
    
    func saveImage(image: UIImage!, toAlbum: String? = nil,metadata: [NSObject:AnyObject], withCallback callback: ((error: NSError?) -> Void)?) {
        self.writeImageToSavedPhotosAlbum(image.CGImage, metadata: metadata){ (u, e) -> Void in
        //self.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!) { (u, e) -> Void in
            if e != nil {
                if callback != nil {
                    callback!(error: e)
                }
                return
            }
            
            if toAlbum != nil {
                self.addAssetURL(u, toAlbum: toAlbum!, withCallback: callback)
            }
        }
    }
    
    func saveVideo(assetUrl: NSURL!, toAlbum: String? = nil, withCallback callback: ((error: NSError?) -> Void)?) {
        self.writeVideoAtPathToSavedPhotosAlbum(assetUrl, completionBlock: { (u, e) -> Void in
            if e != nil {
                if callback != nil {
                    callback!(error: e)
                }
                return;
            }
            
            if toAlbum != nil {
                self.addAssetURL(u, toAlbum: toAlbum!, withCallback: callback)
            }
        })
    }
    
    
    func addAssetURL(assetURL: NSURL!, toAlbum: String!, withCallback callback: ((error: NSError?) -> Void)?) {
        
        var albumWasFound = false
        
        // Search all photo albums in the library
        self.enumerateGroupsWithTypes(ALAssetsGroupAlbum, usingBlock: { (group, stop) -> Void in
            
            // Compare the names of the albums
            if group != nil && toAlbum == group.valueForProperty(ALAssetsGroupPropertyName) as! String {
                albumWasFound = true
                
                // Get the asset and add to the album
                self.assetForURL(assetURL, resultBlock: { (asset) -> Void in
                    group.addAsset(asset)
                    
                    if callback != nil {
                        callback!(error: nil)
                    }
                    
                    }, failureBlock: callback)
                
                // Album was found, bail out of the method
                return
            }
            else if group == nil && albumWasFound == false {
                // Photo albums are over, target album does not exist, thus create it
                
                // Create new assets album
                self.addAssetsGroupAlbumWithName(toAlbum, resultBlock: { (group) -> Void in
                    
                    // Get the asset and add to the album
                    self.assetForURL(assetURL, resultBlock: { (asset) -> Void in
                        group.addAsset(asset)
                        
                        if callback != nil {
                            callback!(error: nil)
                        }
                        
                        }, failureBlock: callback)
                    
                    }, failureBlock: callback)
                
                return
            }
            }, failureBlock: callback)
    }
    
}


extension String
{
    var length: Int {
        get {
            return count(self)
        }
    }
    
    func contains(s: String) -> Bool
    {
        return (self.rangeOfString(s) != nil )
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString, options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    subscript (i: Int) -> Character
        {
        get {
            let index = advance(startIndex, i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String
        {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(self.startIndex, r.endIndex - 1)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func subString(startIndex: Int, length: Int) -> String
    {
        var start = advance(self.startIndex, startIndex)
        var end = advance(self.startIndex, startIndex + length)
        return self.substringWithRange(Range<String.Index>(start: start, end: end))
    }
    
    func indexOf(target: String) -> Int
    {
        var range = self.rangeOfString(target)
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func endsWith(end: String, caseSensitive: Bool = true )-> Bool{
        var myself: String=self
        var myend: String=end
        if !caseSensitive {
            myself=self.lowercaseString
            myend=end.lowercaseString
        }
        let index = myself.lastIndexOf(myend)
        if index == -1 || index + myend.length != myself.length {
            return false
        }
        else {
            return true
        }
    }
    
    func indexOf(target: String, startIndex: Int) -> Int
    {
        var startRange = advance(self.startIndex, startIndex)
        
        var range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(start: startRange, end: self.endIndex))
        
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(target: String) -> Int
    {
        var index = -1
        var stepIndex = self.indexOf(target)
        while stepIndex > -1
        {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target, startIndex: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    
    func isMatch(regex: String, options: NSRegularExpressionOptions) -> Bool
    {
        var error: NSError?
        var exp = NSRegularExpression(pattern: regex, options: options, error: &error)!
        
        if let error = error {
            println(error.description)
        }
        var matchCount = exp.numberOfMatchesInString(self, options: nil, range: NSMakeRange(0, self.length))
        return matchCount > 0
    }
    
    func getMatches(regex: String, options: NSRegularExpressionOptions) -> [NSTextCheckingResult]
    {
        var error: NSError?
        var exp = NSRegularExpression(pattern: regex, options: options, error: &error)!
        
        if let error = error {
            println(error.description)
        }
        var matches = exp.matchesInString(self, options: nil, range: NSMakeRange(0, self.length))
        return matches as! [NSTextCheckingResult]
    }
    
    private var vowels: [String]
        {
        get
        {
            return ["a", "e", "i", "o", "u"]
        }
    }
    
    private var consonants: [String]
        {
        get
        {
            return ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"]
        }
    }
    
    func pluralize(count: Int) -> String
    {
        if count == 1 {
            return self
        } else {
            var lastChar = self.subString(self.length - 1, length: 1)
            var secondToLastChar = self.subString(self.length - 2, length: 1)
            var prefix = "", suffix = ""
            
            if lastChar.lowercaseString == "y" && vowels.filter({x in x == secondToLastChar}).count == 0 {
                prefix = self[0...self.length - 1]
                suffix = "ies"
            } else if lastChar.lowercaseString == "s" || (lastChar.lowercaseString == "o" && consonants.filter({x in x == secondToLastChar}).count > 0) {
                prefix = self[0...self.length]
                suffix = "es"
            } else {
                prefix = self[0...self.length]
                suffix = "s"
            }
            
            return prefix + (lastChar != lastChar.uppercaseString ? suffix : suffix.uppercaseString)
        }
    }
}