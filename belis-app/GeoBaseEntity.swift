//
//  GeoBaseEntity.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper
import MGSwipeTableCell

class GeoBaseEntity : BaseEntity, LeftSwipeActionProvider{
    var mapObject : NSObject?;
    private var geom :WKTGeometry?

    
    override init(){
        super.init()
    }
    
    var wgs84WKT : String?
        {
        didSet {
            //println("geoString="+wgs84WKT!);
            if let wgs84WKTSTring=wgs84WKT {
                geom=WKTParser.parseGeometry(wgs84WKTSTring)
                if ( geom is WKTPoint){
                    let point=geom as! WKTPoint;
                    mapObject=GeoBaseEntityPointAnnotation(geoBaseEntity: self, point: point)
                }
                else if (geom is WKTLine) {
                    let line=geom as! WKTLine;
                    mapObject=GeoBaseEntityStyledMkPolylineAnnotation(line: line, geoBaseEntity: self)
                    (mapObject! as! GeoBaseEntityStyledMkPolylineAnnotation).geoBaseEntity=self
                }
                else if (geom is WKTPolygon) {
                    let polygon=geom as! WKTPolygon
                    mapObject=GeoBaseEntityStyledMkPolygonAnnotation(polyg: polygon, geoBaseEntity: self)
                     (mapObject! as! GeoBaseEntityStyledMkPolygonAnnotation).geoBaseEntity=self
                }
                
            }
            else{
                print("\(self) - id : \(self.id)");
            }
            
        }
        
    }
    
    func addToMapView(mapView:MKMapView) {
        if let mo=mapObject {
            if let moPoint=mo as? GeoBaseEntityPointAnnotation {
                mapView.addAnnotation(moPoint)
            }
            else if let moLine=mo as? GeoBaseEntityStyledMkPolylineAnnotation {
                mapView.addOverlay(moLine)
                mapView.addAnnotation(moLine)
            }
            else if let moPolygon=mo as? GeoBaseEntityStyledMkPolygonAnnotation {
                mapView.addOverlay(moPolygon)
                mapView.addAnnotation(moPolygon)

            }
        }
    }
    
    
    func removeFromMapView(mapView:MKMapView) {
        if let mo=mapObject {
            if let moPoint=mo as? GeoBaseEntityPointAnnotation {
                mapView.removeAnnotation(moPoint)
            }
            else if let moLine=mo as? GeoBaseEntityStyledMkPolylineAnnotation {
                mapView.removeOverlay(moLine)
            }
            else if let moPoly=mo as? GeoBaseEntityStyledMkPolygonAnnotation {
                mapView.removeOverlay(moPoly)
            }
        }
    }
    
    func getAnnotationTitle() -> String{
        return "";
    }
    func getAnnotationImageName() -> String{
        return "";
    }
    func canShowCallout() -> Bool{
        return false;
    }
    func getAnnotationCalloutGlyphIconName() -> String {
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
            let anno = mapObject as! MKAnnotation;
            return (
                anno.coordinate.latitude  >= northWestCorner.latitude &&
                    anno.coordinate.latitude  <= southEastCorner.latitude &&
                    
                    anno.coordinate.longitude >= northWestCorner.longitude &&
                    anno.coordinate.longitude <= southEastCorner.longitude
            )
            
        }
        else if mapObject is MKPolyline {
            let line = mapObject as! MKPolyline;
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
    
    
    required init?(_ map: Map) {
        super.init(map)
    }
    override func mapping(map: Map) {
        
    }

    func getLeftSwipeActions() -> [MGSwipeButton] {
        let zoomC=UIColor(red: 193.0/255.0, green: 237.0/255.0, blue: 46.0/255.0, alpha: 1.0)
        
        let zoom=MGSwipeButton(title: "Zoom", backgroundColor: zoomC ,callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            if let anno=self.mapObject as? MKAnnotation, mainVC=CidsConnector.sharedInstance().mainVC {
                 mainVC.zoomToFitMapAnnotations([anno])
            }
            return true
        })
        return [zoom]
    }
    
}


class GeoBaseEntityPointAnnotation:MKPointAnnotation, GeoBaseEntityProvider{
    var imageName: String!
    var glyphName: String!
    var shouldShowCallout = false
    var geoBaseEntity: GeoBaseEntity
    init(geoBaseEntity: GeoBaseEntity, point: WKTPoint){
        self.geoBaseEntity=geoBaseEntity
        super.init()
        let mPoint=point.toMapPointAnnotation();
        coordinate=mPoint.coordinate;
        imageName=geoBaseEntity.getAnnotationImageName();
        glyphName=geoBaseEntity.getAnnotationCalloutGlyphIconName();
        title=geoBaseEntity.getAnnotationTitle();
        //        subtitle=geoBaseEntity.getAnnotationSubTitle();
        shouldShowCallout=geoBaseEntity.canShowCallout();
    }
    
    func getGeoBaseEntity() -> GeoBaseEntity {
        return geoBaseEntity
    }
    
}

class GeoBaseEntityStyledMkPolylineAnnotation:MKPolyline{
    var imageName: String!
    var glyphName: String!
    var shouldShowCallout = false
    var geoBaseEntity: GeoBaseEntity
    
    override init() {
        geoBaseEntity = GeoBaseEntity()
    }
    
    convenience init(line: WKTLine, geoBaseEntity: GeoBaseEntity) {
        self.init()
        let mLine=line.toMapLine();
        mLine.title="."
        self.init(points: mLine.points(), count: mLine.pointCount)
        imageName=geoBaseEntity.getAnnotationImageName();
        glyphName=geoBaseEntity.getAnnotationCalloutGlyphIconName();
        title=geoBaseEntity.getAnnotationTitle();
        //        subtitle=geoBaseEntity.getAnnotationSubTitle();
        shouldShowCallout=geoBaseEntity.canShowCallout();
    }
    func getGeoBaseEntity() -> GeoBaseEntity {
        return geoBaseEntity
    }
    
}


class GeoBaseEntityStyledMkPolygonAnnotation:MKPolygon{
    var shouldShowCallout = false
    var geoBaseEntity: GeoBaseEntity
    var imageName: String!
    var glyphName: String!
    override init() {
        geoBaseEntity = GeoBaseEntity()
    }
    
    convenience init(polyg: WKTPolygon, geoBaseEntity: GeoBaseEntity) {
        self.init()
        let mPolyg=polyg.toMapPolygon()
        mPolyg.title="."
        self.init(points: mPolyg.points(), count: mPolyg.pointCount)
        imageName=geoBaseEntity.getAnnotationImageName();
        glyphName=geoBaseEntity.getAnnotationCalloutGlyphIconName();
        title=geoBaseEntity.getAnnotationTitle();
        //        subtitle=geoBaseEntity.getAnnotationSubTitle();
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


