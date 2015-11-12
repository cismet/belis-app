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
        "icon-ceilinglight":"\u{f4ec}",
        "icon-nut":"\u{f427}",
        "icon-line":"\u{f1bf}",
        "icon-lightningalt":"\u{f2a8}",
        "icon-connected":"\u{f51c}",
        "icon-noteslist":"\u{f5c6}",
        "icon-notestasks":"\u{f5c7}",
        "icon-stickynotealt":"\u{f60e}",
        "icon-tag":"\u{f032}",
         "icon-map-marker":"\u{f220}",
        "icon-antenna":"\u{f3ec}",
        "icon-document":"\u{f0c2}",
        "icon-camera":"\u{f19b}",
        "icon-horizontalexpand":"\u{f578}",
        "icon-switch":"\u{f28a}",
        "icon-certificatealt":"\u{f058}",
        "icon-chevron-down":"\u{f48b}",
        "icon-chevron-left":"\u{f489}",
        "icon-chevron-right":"\u{f488}",
        "icon-chevron-up":"\u{f48a}",
        "icon-world":"\u{f4f3}"
    ]
    
}

class GlyphTools {
    // MARK: SHARED INSTANCE
    static var instance: GlyphTools!
    
    class func sharedInstance() -> GlyphTools {
        self.instance = (self.instance ?? GlyphTools())
        return self.instance
    }

    func getGlyphedLabel(glyphName: String) -> UILabel? {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {
            let label=UILabel(frame: CGRectMake(0, 0, 25,25))
            label.font = UIFont(name: "WebHostingHub-Glyphs", size: 20)
            label.textAlignment=NSTextAlignment.Center
            label.text=glyph
            label.sizeToFit()
            return label
        }
        else  {
            return nil
        }
    }
    func getGlyphedButton(glyphName: String) -> UIButton? {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {
            let btn=UIButton(frame: CGRectMake(0, 0, 25,25))
            btn.titleLabel!.font = UIFont(name: "WebHostingHub-Glyphs", size: 20)
            btn.titleLabel!.textAlignment=NSTextAlignment.Center
            btn.setTitle(glyph, forState: UIControlState.Normal)
            btn.sizeToFit()
            return btn
        }
        else  {
            return nil
        }
    }
    
//    func getGlyphedImage(glyphName: String) -> UIImage? {
//        if let glyph=WebHostingGlyps.glyphs[glyphName] {
//            
//            let color=UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
//            let alpha=UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
//            let font=UIFont(name: "WebHostingHub-Glyphs", size: 14)!
//            let image=UIImage(text: glyph, font: font, color: color, backgroundColor: alpha, size: CGSize(width: 20,height:20), offset: CGPoint(x: 0, y: 2))
//            return image
//        }
//        else  {
//            return nil
//        }
//    }
}