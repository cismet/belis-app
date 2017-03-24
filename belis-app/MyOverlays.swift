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
        super.init(urlTemplate: template);
        maximumZ=15;
        self.canReplaceMapContent=true
        
    }
    
    @objc(URLForTilePathRenamed:)
    func URLForTilePath(_ path: MKTileOverlayPath) -> URL! {
        let ret=super.url(forTilePath: path);
        log.verbose("http://b.tile.openstreetmap.org/\(path.z)/\(path.x)/\(path.y).png");
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
    override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        return true;
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let rect=self.rect(for: mapRect);
        context.setFillColor(UIColor.brown.cgColor);
        context.fill(rect);
       
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
    override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        return true;
    }
    
    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        let rect=self.rect(for: mapRect);
        context.setFillColor(UIColor(red: 1, green: 1, blue: 1, alpha: 0.9).cgColor);
        context.fill(rect);
    }
}
