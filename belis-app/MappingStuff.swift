//
//  MappingStuff.swift
//  belis-app
//
//  Created by Thorsten Hell on 04/02/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation

class MappingTools {
    class func distanceOfPoint(_ pt: MKMapPoint, toPoly : MKPolyline) -> Double {
        var distance : Double = -1.0
        
        for n in 0...toPoly.pointCount-1 {
            let ptA = toPoly.points()[n]
            let ptB = toPoly.points()[n+1]
            
            let xDelta = abs(ptB.x - ptA.x)
            let yDelta = abs(ptB.y - ptA.y)
            
            if xDelta == 0.0 && yDelta == 0.0 {
                continue;
            }
            
            let diffX=pt.x - ptA.x
            let diffY=pt.y - ptA.y
            let u = (diffX * xDelta +  diffY * yDelta) / (xDelta * xDelta + yDelta * yDelta)
            
            var ptClosest: MKMapPoint
            
            if u < 0.0 {
                ptClosest = ptA
            }
            else if u > 1.0 {
                ptClosest = ptB
            }
            else {
                ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta)
            }
            let currentDist=MKMetersBetweenMapPoints(ptClosest, pt)

            if distance == -1 {
                distance = currentDist
            }
            else {
                distance = min(distance, currentDist)
            }
        }
        return distance
    }
 
    class func metersFromPixel(_ px: Int, atPoint: CGPoint, inMap : MKMapView) -> Double {
        let newX = atPoint.x + CGFloat(px)
        let ptB = CGPoint(x: newX, y: atPoint.y)
        let coordA = inMap.convert(atPoint, toCoordinateFrom: inMap)
        let coordB = inMap.convert(ptB, toCoordinateFrom: inMap)
        
        return MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordA), MKMapPointForCoordinate(coordB))
    }
    
}
