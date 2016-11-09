//
//  WebHostingGlyph.swift
//  belis-app
//
//  Created by Thorsten Hell on 24/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import CoreGraphics

struct WebHostingGlyps {
    static var glyphs: [String: String] = [
        "icon-ceilinglight":"\u{f4ec}",             //Leuchte
        "icon-nut":"\u{f427}",                      //Mauerlaschen
        "icon-line":"\u{f1bf}",                     //Leitungen
        "icon-lightningalt":"\u{f2a8}",             //
        "icon-connected":"\u{f51c}",                //Abzweigdose
        "icon-squarea":"\u{f6c5}",                  //Abzweigdose*
        "icon-noteslist":"\u{f5c6}",                //Protokoll
        "icon-notestasks":"\u{f5c7}",               //
        "icon-stickynotealt":"\u{f60e}",            //
        "icon-tag":"\u{f032}",                      //
        "icon-map-marker":"\u{f220}",               //
        "icon-antenna":"\u{f3ec}",                  //
        "icon-document":"\u{f0c2}",                 //
        "icon-camera":"\u{f19b}",                   //
        "icon-horizontalexpand":"\u{f578}",         //Standorte
        "icon-switch":"\u{f28a}",                   //Schaltstelle
        "icon-certificatealt":"\u{f058}",           //Connection-Settings
        "icon-chevron-down":"\u{f48b}",             //Menu
        "icon-chevron-left":"\u{f489}",             //Back-Button
        "icon-chevron-right":"\u{f488}",            //Detail-Button
        "icon-chevron-up":"\u{f48a}",               //
        "icon-polygonlasso":"\u{f397}",             //Freie Geometrie
        "icon-world":"\u{f4f3}",                    //Zoom auf alle Objekte
        "icon-circlerecordempty":"\u{f566}",        //AnnotationImage Leuchte
        "icon-circlerecord":"\u{f55e}",        //AnnotationImage Mast
        "icon-squarepause":"\u{f4fb}",                 //AnnotationImage Schaltstelle
        "icon-plaque":"\u{f2b8}",             //AnnotationImage Mauerlasche
        "icon-squarestop":"\u{f4fa}",             //AnnotationImage Abzweigdose
        
    ]
    
}

class GlyphTools {
    // MARK: SHARED INSTANCE
    static var instance: GlyphTools!
    static let glyphFontName="WebHostingHub-Glyphs"
    
    class func sharedInstance() -> GlyphTools {
        self.instance = (self.instance ?? GlyphTools())
        return self.instance
    }
    
    func getGlyphedLabel(_ glyphName: String) -> UILabel? {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {
            let label=UILabel(frame: CGRect(x: 0, y: 0, width: 25,height: 25))
            label.font = UIFont(name: GlyphTools.glyphFontName, size: 20)
            label.textAlignment=NSTextAlignment.center
            label.text=glyph
            label.sizeToFit()
            return label
        }
        else  {
            return nil
        }
    }
    func getGlyphedButton(_ glyphName: String) -> UIButton? {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {
            let btn=UIButton(frame: CGRect(x: 0, y: 0, width: 25,height: 25))
            btn.titleLabel!.font = UIFont(name: GlyphTools.glyphFontName, size: 20)
            btn.titleLabel!.textAlignment=NSTextAlignment.center
            btn.setTitle(glyph, for: UIControlState())
            btn.sizeToFit()
            return btn
        }
        else  {
            return nil
        }
    }
    
    
    func getGlyphedAnnotationImage(_ glyphName: String, fontSize: CGFloat=7.0, color: UIColor = UIColor.black,backgroundcolor:UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0) ) -> UIImage {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {

            let font=UIFont(name: GlyphTools.glyphFontName, size: fontSize)!
            let offset=CGPoint(x: 0, y: 0)
            let sizeOfImage=CGSize(width: font.lineHeight,height:font.lineHeight)
            return getTextImage(glyph, font: font, color: color, backgroundColor: backgroundcolor, size: sizeOfImage, offset: offset) ;
        }
        return UIImage();

    }
    
    func getGlyphedImage(_ glyphName: String, fontsize: CGFloat = 14, size: CGSize = CGSize(width: 20,height:20), offset: CGPoint = CGPoint(x: 0, y: 2), color: UIColor = UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0),backgroundcolor:UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0) ) -> UIImage {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {
            
            let font=UIFont(name: GlyphTools.glyphFontName, size: fontsize)!
            let image=getTextImage(glyph, font: font, color: color, backgroundColor: backgroundcolor, size: size, offset: offset)
            return image
        }
        
        return UIImage();

    }
    
    fileprivate func getTextImage(_ charText: String, font: UIFont = UIFont.systemFont(ofSize: 18), color: UIColor = UIColor.white, backgroundColor: UIColor = UIColor.gray, size:CGSize = CGSize(width: 100, height: 100), offset: CGPoint = CGPoint(x: 0, y: 0)) -> UIImage   {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(backgroundColor.cgColor)
        context?.fill(CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        let attr = [NSFontAttributeName:font, NSForegroundColorAttributeName:color, NSParagraphStyleAttributeName:style]
        let rect = CGRect(x: offset.x, y: offset.y, width: size.width, height: size.height)
        charText.draw(in: rect, withAttributes: attr)
        let result=UIImage(cgImage:(UIGraphicsGetImageFromCurrentImageContext()?.cgImage!)!)
        UIGraphicsEndImageContext()
        return result;
    }
    
    func setGlyphLabel(_ label: UILabel, glyphName: String) {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {
            label.font = UIFont(name: GlyphTools.glyphFontName, size: 20)
            label.textAlignment=NSTextAlignment.center
            label.text=glyph
            label.sizeToFit()
        }
    }

}
