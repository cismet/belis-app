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
                    mapObject=GeoBaseEntityPointAnnotation(geoBaseEntity: self, point: point)
                }
                else if (geom is WKTLine) {
                    let line=geom as WKTLine;
                    let temp=self;
                    mapObject=GeoBaseEntityStyledMkPolylineAnnotation(line: line, geoBaseEntity: self)
                    (mapObject as GeoBaseEntityStyledMkPolylineAnnotation).geoBaseEntity=self
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
            else if (mapObject is GeoBaseEntityStyledMkPolylineAnnotation){
                mapView.addOverlay(mapObject as GeoBaseEntityStyledMkPolylineAnnotation);
                mapView.addAnnotation(mapObject as GeoBaseEntityStyledMkPolylineAnnotation);

            }
            
        }

    }
    
    
    func removeFromMapView(mapView:MKMapView) {
        if ( mapObject != nil ){
            if (mapObject is GeoBaseEntityPointAnnotation){
                mapView.removeAnnotation(mapObject as MKAnnotation);
            }
            else if (mapObject is GeoBaseEntityStyledMkPolylineAnnotation){
                mapView.removeOverlay(mapObject as GeoBaseEntityStyledMkPolylineAnnotation);
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


class GeoBaseEntityPointAnnotation:MKPointAnnotation, GeoBaseEntityProvider{
    var imageName: String!
    var callOutLeftImageName: String!
    var shouldShowCallout = false
    var geoBaseEntity: GeoBaseEntity
    init(geoBaseEntity: GeoBaseEntity, point: WKTPoint){
        self.geoBaseEntity=geoBaseEntity
        super.init()
        let mPoint=point.toMapPointAnnotation();
        coordinate=mPoint.coordinate;
        imageName=geoBaseEntity.getAnnotationImageName();
        callOutLeftImageName=geoBaseEntity.getAnnotationCalloutImageName();
        title=geoBaseEntity.getAnnotationTitle();
        subtitle=geoBaseEntity.getAnnotationSubTitle();
        shouldShowCallout=geoBaseEntity.canShowCallout();
    }
    
    func getGeoBaseEntity() -> GeoBaseEntity {
        return geoBaseEntity
    }
    
}

class GeoBaseEntityStyledMkPolylineAnnotation:MKPolyline{
    var imageName: String!
    var callOutLeftImageName: String!
    var shouldShowCallout = false
    var geoBaseEntity: GeoBaseEntity

    override init() {
        geoBaseEntity=GeoBaseEntity()
        super.init()
    }
    
    convenience init(line: WKTLine, geoBaseEntity: GeoBaseEntity) {
        self.init()
        let mLine=line.toMapLine();
        mLine.title="."
        self.init(points: mLine.points(), count: mLine.pointCount)
        imageName=geoBaseEntity.getAnnotationImageName();
        callOutLeftImageName=geoBaseEntity.getAnnotationCalloutImageName();
        title=geoBaseEntity.getAnnotationTitle();
        subtitle=geoBaseEntity.getAnnotationSubTitle();
        shouldShowCallout=geoBaseEntity.canShowCallout();
    }
    func getGeoBaseEntity() -> GeoBaseEntity {
        return geoBaseEntity
    }

}

class HighlightedMkPolyline:MKPolyline{
    
}

protocol GeoBaseEntityProvider {
    func getGeoBaseEntity() -> GeoBaseEntity
}


