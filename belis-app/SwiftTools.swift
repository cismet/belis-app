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
import JGProgressHUD

extension String {
    
    subscript (r: CountableClosedRange<Int>) -> String {
        get {
            let startIndex =  self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
            return self[startIndex...endIndex]
        }
    }
}

extension Date
{
    public func toDateString() -> String{
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "dd.MM.yyyy" // ad here HH:mm for debugging
        dateStringFormatter.locale = Locale(identifier: "de_DE")
        return dateStringFormatter.string(from: self)
    }
}

class DateTransformFromString : TransformType {
    typealias Object = Date
    typealias JSON = Int
    
    
    var dateFormat:String
    init(format: String) {
        dateFormat=format
    }
    
    func transformFromJSON(_ value: Any?) -> Object? {
        if let s = value as? String {
            let dateStringFormatter = DateFormatter()
            dateStringFormatter.dateFormat = dateFormat
            
            if let ret=dateStringFormatter.date(from: s) {
                return ret
            }
            else {
                //error
            }
            
        }
        
        return nil
    }
    func transformToJSON(_ value: Object?) -> JSON? {
        if let d=value {
            let ms:Int = Int(d.timeIntervalSince1970*1000.0)
            return ms
        }
        return nil
    }

}


class DateTransformFromMillisecondsTimestamp : TransformType {
    typealias Object = Date
    typealias JSON = Int
    
    func transformFromJSON(_ value: Any?) -> Date? {
        if let ms=value as? Int {
            let dms=Double(ms)
            return Date(timeIntervalSince1970: TimeInterval(dms/1000.0))
        }
        
       return nil
    }
    func transformToJSON(_ value: Date?) -> Int? {
        if let d=value {
            let ms:Int = Int(d.timeIntervalSince1970*1000.0)
            return ms
        }
        return nil
    }
}

class MatchingSearchItemsAnnotations : MKPointAnnotation {
    
}

extension ALAssetsLibrary {
    
    func saveImage(_ image: UIImage!, toAlbum: String? = nil,metadata: [AnyHashable: Any], withCallback callback: ((_ error: NSError?) -> Void)?) {
        self.writeImage(toSavedPhotosAlbum: image.cgImage, metadata: metadata){ (u, e) -> Void in
        //self.writeImageToSavedPhotosAlbum(image.CGImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!) { (u, e) -> Void in
            if e != nil {
                if callback != nil {
                    callback!(e as NSError?)
                }
                return
            }
            
            if toAlbum != nil {
                self.addAssetURL(u, toAlbum: toAlbum!, withCallback: callback)
            }
        }
    }
    
    func saveVideo(_ assetUrl: URL!, toAlbum: String? = nil, withCallback callback: ((_ error: NSError?) -> Void)?) {
        self.writeVideoAtPath(toSavedPhotosAlbum: assetUrl, completionBlock: { (u, e) -> Void in
            if e != nil {
                if callback != nil {
                    callback!(e as NSError?)
                }
                return;
            }
            
            if toAlbum != nil {
                self.addAssetURL(u, toAlbum: toAlbum!, withCallback: callback)
            }
        })
    }
    
    
    func addAssetURL(_ assetURL: URL!, toAlbum: String!, withCallback callback: ((_ error: NSError?) -> Void)?) {
        
        var albumWasFound = false
        
        // Search all photo albums in the library
        self.enumerateGroupsWithTypes(ALAssetsGroupAlbum, usingBlock: { (group, stop) -> Void in
            
            // Compare the names of the albums
            if group != nil && toAlbum == group?.value(forProperty: ALAssetsGroupPropertyName) as! String {
                albumWasFound = true
                
                // Get the asset and add to the album
                self.asset(for: assetURL, resultBlock: { (asset) -> Void in
                    group?.add(asset)
                    
                    if callback != nil {
                        callback!(nil)
                    }
                    
                    }, failureBlock: callback as! ALAssetsLibraryAccessFailureBlock!)
                
                // Album was found, bail out of the method
                return
            }
            else if group == nil && albumWasFound == false {
                // Photo albums are over, target album does not exist, thus create it
                
                // Create new assets album
                self.addAssetsGroupAlbum(withName: toAlbum, resultBlock: { (group) -> Void in
                    
                    // Get the asset and add to the album
                    self.asset(for: assetURL, resultBlock: { (asset) -> Void in
                        group?.add(asset)
                        
                        if callback != nil {
                            callback!(nil)
                        }
                        
                        }, failureBlock: callback as! ALAssetsLibraryAccessFailureBlock!)
                    
                    }, failureBlock: callback as! ALAssetsLibraryAccessFailureBlock!)
                
                return
            }
            }, failureBlock: callback as! ALAssetsLibraryAccessFailureBlock!)
    }
    
}


extension String
{
    var length: Int {
        get {
            return self.characters.count
        }
    }
    
    func contains(_ s: String) -> Bool
    {
        return (self.range(of: s) != nil )
    }
    
    func replace(_ target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }
    
    subscript (i: Int) -> Character
        {
        get {
            let index = characters.index(startIndex, offsetBy: i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String
        {
        get {
            let startIndex = self.characters.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.characters.index(self.startIndex, offsetBy: r.upperBound - 1)
            
            return self[(startIndex ..< endIndex)]
        }
    }
    
    func subString(_ startIndex: Int, length: Int) -> String
    {
        let start = self.characters.index(self.startIndex, offsetBy: startIndex)
        let end = self.characters.index(self.startIndex, offsetBy: startIndex + length)
        return self.substring(with: (start ..< end))
    }
    
    func indexOf(_ target: String) -> Int
    {
        let range = self.range(of: target)
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    func endsWith(_ end: String, caseSensitive: Bool = true )-> Bool{
        var myself: String=self
        var myend: String=end
        if !caseSensitive {
            myself=self.lowercased()
            myend=end.lowercased()
        }
        let index = myself.lastIndexOf(myend)
        if index == -1 || index + myend.length != myself.length {
            return false
        }
        else {
            return true
        }
    }
    
    func indexOf(_ target: String, startIndex: Int) -> Int
    {
        let startRange = self.characters.index(self.startIndex, offsetBy: startIndex)
        
        let range = self.range(of: target, options: NSString.CompareOptions.literal, range: (startRange ..< self.endIndex))
        
        if let range = range {
            return self.characters.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(_ target: String) -> Int
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
    
    func isMatch(_ regex: String, options: NSRegularExpression.Options) -> Bool
    {
        let exp = try! NSRegularExpression(pattern: regex, options: options)
        let matchCount = exp.numberOfMatches(in: self, options: [], range: NSMakeRange(0, self.length))
        return matchCount > 0
    }
    
    func getMatches(_ regex: String, options: NSRegularExpression.Options) -> [NSTextCheckingResult]
    {
        let exp = try! NSRegularExpression(pattern: regex, options: options)
        let matches = exp.matches(in: self, options: [], range: NSMakeRange(0, self.length))
        return matches 
    }
    
    fileprivate var vowels: [String]
        {
        get
        {
            return ["a", "e", "i", "o", "u"]
        }
    }
    
    fileprivate var consonants: [String]
        {
        get
        {
            return ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"]
        }
    }
    
    
    func pluralize(_ count: Int) -> String
    {
        if count == 1 {
            return self
        } else {
            let lastChar = self.subString(self.length - 1, length: 1)
            let secondToLastChar = self.subString(self.length - 2, length: 1)
            var prefix = "", suffix = ""
            
            if lastChar.lowercased() == "y" && vowels.filter({x in x == secondToLastChar}).count == 0 {
                prefix = self[0...self.length - 1]
                suffix = "ies"
            } else if lastChar.lowercased() == "s" || (lastChar.lowercased() == "o" && consonants.filter({x in x == secondToLastChar}).count > 0) {
                prefix = self[0...self.length]
                suffix = "es"
            } else {
                prefix = self[0...self.length]
                suffix = "s"
            }
            
            return prefix + (lastChar != lastChar.uppercased() ? suffix : suffix.uppercased())
        }
    }
}

public func lazyMainQueueDispatch(_ closure: @escaping ()->()){
    if Thread.isMainThread {
        closure()
    }
    else {
        DispatchQueue.main.async {
            closure()
        }
    }
}

public func showWaitingHUD(text:String = "", view:UIView? = nil,indeterminate:Bool = true) {
    
    lazyMainQueueDispatch({ () -> () in
        if text=="" {
            CidsConnector.sharedInstance().mainVC?.progressHUD?.textLabel.text=nil
        }
        else {
            CidsConnector.sharedInstance().mainVC?.progressHUD?.textLabel.text=text
        }
        if indeterminate {
                CidsConnector.sharedInstance().mainVC?.progressHUD?.indicatorView=JGProgressHUDIndeterminateIndicatorView()
        }
        if let v=view {
            CidsConnector.sharedInstance().mainVC?.progressHUD?.show(in: v,animated: true)
        }else {
            CidsConnector.sharedInstance().mainVC?.progressHUD?.show(in: CidsConnector.sharedInstance().mainVC?.view,animated: true)
        }
    })
}

public func setProgressInWaitingHUD(_ progress: Float) {
    lazyMainQueueDispatch({ () -> () in
        print(progress)
        CidsConnector.sharedInstance().mainVC?.progressHUD?.indicatorView=JGProgressHUDRingIndicatorView()
        CidsConnector.sharedInstance().mainVC?.progressHUD?.progress=progress
    })
}

public func hideWaitingHUD(delayedText:String = "", delay:Int = 0) {
    
    lazyMainQueueDispatch({ () -> () in
        if delayedText=="" {
            CidsConnector.sharedInstance().mainVC?.progressHUD?.textLabel.text=nil
        }
        else {
            CidsConnector.sharedInstance().mainVC?.progressHUD?.textLabel.text=delayedText
        }
        CidsConnector.sharedInstance().mainVC?.progressHUD?.dismiss(afterDelay: TimeInterval(delay), animated: true)
        delayed(Double(delay)+0.5) {
            lazyMainQueueDispatch({ () -> () in
                CidsConnector.sharedInstance().mainVC?.progressHUD?.textLabel.text=nil
            })
        }
    })
}

public func delayed(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
