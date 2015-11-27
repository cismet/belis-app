//
//  MyOSMMKTileOverlay.swift
//  BelIS
//
//  Created by Thorsten Hell on 11/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation

class MyOSMMKTileOverlay : MKTileOverlay {

    init(){
        let template="file:///Users/thorsten/Desktop/2732.png";
        super.init(URLTemplate: template);
        maximumZ=15;
        self.canReplaceMapContent=true
        
    }
    
    @objc(URLForTilePathRenamed:)
    func URLForTilePath(path: MKTileOverlayPath) -> NSURL! {
        let ret=super.URLForTilePath(path);
        print("http://b.tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png");
        return ret;
    }
    
    
}


class MyDesperateMKTileOverlayRenderer : MKTileOverlayRenderer {
    override init(overlay: MKOverlay) {
        super.init(overlay:overlay);
    }
    
    override init(tileOverlay overlay: MKTileOverlay) {
        super.init(tileOverlay:overlay);
    }
    override func canDrawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        return true;
    }
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
        let rect=self.rectForMapRect(mapRect);
        CGContextSetFillColorWithColor(context, UIColor.brownColor().CGColor);
        CGContextFillRect(context, rect);
       
    }
}


class MyBrightOverlay:MKTileOverlay {
    
}

class MyBrightOverlayRenderer : MKTileOverlayRenderer {
    override init(overlay: MKOverlay) {
        super.init(overlay:overlay);
    }
    
    override init(tileOverlay overlay: MKTileOverlay) {
        super.init(tileOverlay:overlay);
    }
    override func canDrawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        return true;
    }
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
        let rect=self.rectForMapRect(mapRect);
        CGContextSetFillColorWithColor(context, UIColor(red: 1, green: 1, blue: 1, alpha: 0.9).CGColor);
        CGContextFillRect(context, rect);
    }
}