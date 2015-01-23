//
//  GeoBaseEntity.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class GeoBaseEntity : BaseEntity, MapperProtocol{
    

        var wgs84WKT : String?
            {
        didSet {
            //println("geoString="+wgs84WKT!);
            if let wgs85WKTSTring=wgs84WKT {
            let geom=WKTParser.parseGeometry(wgs84WKT);
            if ( geom is WKTPoint){
                let point=geom as WKTPoint;
                let mPoint=point.toMapPointAnnotation();
                let myAnnotation=GeoBaseEntityPointAnnotation(delegateAnnotation: mPoint);
                myAnnotation.imageName=getAnnotationImageName();
                myAnnotation.callOutLeftImageName=getAnnotationCalloutImageName();
                myAnnotation.title=getAnnotationTitle();
                myAnnotation.subtitle=getAnnotationSubTitle();
                myAnnotation.shouldShowCallout=canShowCallout();
                mapObject=myAnnotation;
            }
            else if (geom is WKTLine) {
                let line=geom as WKTLine;
                let mLine=line.toMapLine();
                mLine.title=".";
                var styledLine=StyledMkPolyline(points: mLine.points(), count: mLine.pointCount);
                mapObject=styledLine;
            }
            }
            else{
                println("\(self) - id : \(self.id)");
            }

        }
        
    }
    var mapObject : NSObject?;
    private var geom :WKTGeometry?

    required init() {
    
    }
    
    func addToMapView(mapView:MKMapView) {
        if  ( mapObject != nil ) {
            if (mapObject is GeoBaseEntityPointAnnotation){
                mapView.addAnnotation(mapObject as GeoBaseEntityPointAnnotation);
               // mapView.showAnnotations([mapObject as GeoBaseEntityPointAnnotation], animated: true)

            }
            else if (mapObject is MKPolyline){
                mapView.addOverlay(mapObject as MKPolyline);
            }
            
        }

    }
    
    
    func removeFromMapView(mapView:MKMapView) {
        if ( mapObject != nil ){
            if (mapObject is GeoBaseEntityPointAnnotation){
                mapView.removeAnnotation(mapObject as MKAnnotation);
            }
            else if (mapObject is MKPolyline){
                mapView.removeOverlay(mapObject as MKOverlay);
            }
        }
    }
    
    func getAnnotationTitle() -> String{
        return "";
    }
    func getAnnotationSubTitle() -> String{
        return "";
    }
    func getAnnotationImageName() -> String{
        return "";
    }
    func canShowCallout() -> Bool{
        return false;
    }
    func getAnnotationCalloutImageName() -> String {
        return "";
    }

    
    func liesIn(coordinateRegion: MKCoordinateRegion ) -> Bool{
        let region = coordinateRegion;
        
        let center   = region.center;
        var northWestCorner = CLLocationCoordinate2D(latitude: 0, longitude: 0);
        var southEastCorner = CLLocationCoordinate2D(latitude: 0, longitude: 0);
        
        northWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
        northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
        southEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
        southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);

        if (mapObject is MKAnnotation){
            var anno = mapObject as MKAnnotation;
            return (
                    anno.coordinate.latitude  >= northWestCorner.latitude &&
                    anno.coordinate.latitude  <= southEastCorner.latitude &&
                    
                    anno.coordinate.longitude >= northWestCorner.longitude &&
                    anno.coordinate.longitude <= southEastCorner.longitude
            )
            
        }
        else if mapObject is MKPolyline {
            var line = mapObject as MKPolyline;
            var coords = [CLLocationCoordinate2D](count: line.pointCount, repeatedValue: kCLLocationCoordinate2DInvalid);
            line.getCoordinates(&coords, range: NSMakeRange(0, line.pointCount));
            
            for coord in coords {
                if (coord.latitude  >= northWestCorner.latitude &&
                    coord.latitude  <= southEastCorner.latitude &&
                    coord.longitude >= northWestCorner.longitude &&
                    coord.longitude <= southEastCorner.longitude) {
                        return true;
                }

            }
            return false;
        }
        else {
            return true;
        }
        
    }
    
    override func map(mapper: Mapper) {
    
    }

    
    
}


class GeoBaseEntityPointAnnotation:MKPointAnnotation{
    var imageName: String!;
    var callOutLeftImageName: String!;
    var shouldShowCallout = false;
    init(delegateAnnotation: MKPointAnnotation){
        super.init();
        coordinate=delegateAnnotation.coordinate;
    }
    
}

class StyledMkPolyline:MKPolyline{
    
}

class HighlightedMkPolyline:MKPolyline{
    
}

class FocusRectangle:MKPolygon {
    
}


