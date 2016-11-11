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
    fileprivate var geom :WKTGeometry?
    
    var wgs84WKT : String?
        {
        didSet {
            print("geoString didSet")
            if let wgs84WKTString=wgs84WKT {
                geom=WKTParser.parseGeometry(wgs84WKTString)
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
    
    
    // MARK: - Constructor
    override init(){
        super.init()
    }

    // MARK: - required init because of ObjectMapper
    required init?(map: Map) {
        super.init(map: map)
    }
    
    // MARK: - essential overrides GeoBaseEntity
    func getAnnotationTitle() -> String{
        return "";
    }
    func getAnnotationImage(_ status: String?=nil) -> UIImage{
        return UIImage();
    }
    func canShowCallout() -> Bool{
        return false;
    }
    func getAnnotationCalloutGlyphIconName() -> String {
        return "";
    }
    
    // MARK: - LeftSwipeActionProvider Impl
    func getLeftSwipeActions() -> [MGSwipeButton] {
        let zoomC=UIColor(red: 199.0/255.0, green: 244.0/255.0, blue: 100.0/255.0, alpha: 1.0)
        
        let zoom=MGSwipeButton(title: "Zoom", backgroundColor: zoomC ,callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            if let anno=self.mapObject as? MKAnnotation, let mainVC=CidsConnector.sharedInstance().mainVC {
                 mainVC.zoomToFitMapAnnotations([anno])
            }
            return true
        })
        return [zoom]
    }
    // MARK: - object functions
    func addToMapView(_ mapView:MKMapView) {
        if let mo=mapObject {
            if let moPoint=mo as? GeoBaseEntityPointAnnotation {
                mapView.addAnnotation(moPoint)
            }
            else if let moLine=mo as? GeoBaseEntityStyledMkPolylineAnnotation {
                mapView.add(moLine)
                mapView.addAnnotation(moLine)
            }
            else if let moPolygon=mo as? GeoBaseEntityStyledMkPolygonAnnotation {
                mapView.add(moPolygon)
                mapView.addAnnotation(moPolygon)
                
            }
        }
    }
    func removeFromMapView(_ mapView:MKMapView) {
        if let mo=mapObject {
            if let moPoint=mo as? GeoBaseEntityPointAnnotation {
                mapView.removeAnnotation(moPoint)
            }
            else if let moLine=mo as? GeoBaseEntityStyledMkPolylineAnnotation {
                mapView.remove(moLine)
            }
            else if let moPoly=mo as? GeoBaseEntityStyledMkPolygonAnnotation {
                mapView.remove(moPoly)
            }
        }
    }
    func liesIn(_ coordinateRegion: MKCoordinateRegion ) -> Bool{
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
            var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: line.pointCount);
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
    
}


class GeoBaseEntityPointAnnotation:MKPointAnnotation, GeoBaseEntityProvider{
    var annotationImage: UIImage!
    var glyphName: String!
    var shouldShowCallout = false
    var geoBaseEntity: GeoBaseEntity
    init(geoBaseEntity: GeoBaseEntity, point: WKTPoint){
        self.geoBaseEntity=geoBaseEntity
        super.init()
        let mPoint=point.toMapPointAnnotation();
        coordinate=(mPoint?.coordinate)!;
        annotationImage=geoBaseEntity.getAnnotationImage();
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
    var annotationImage: UIImage!
    var glyphName: String!
    var shouldShowCallout = false
    var geoBaseEntity: GeoBaseEntity
    
    override init() {
        geoBaseEntity = GeoBaseEntity()
    }
    
    convenience init(line: WKTLine, geoBaseEntity: GeoBaseEntity) {
        self.init()
        let mLine=line.toMapLine();
        mLine?.title="."
        self.init(points: (mLine?.points())!, count: (mLine?.pointCount)!)
        annotationImage=geoBaseEntity.getAnnotationImage();
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
    var annotationImage: UIImage!
    var glyphName: String!
    override init() {
        geoBaseEntity = GeoBaseEntity()
    }
    
    convenience init(polyg: WKTPolygon, geoBaseEntity: GeoBaseEntity) {
        self.init()
        let mPolyg=polyg.toMapPolygon()
        mPolyg?.title="."
        self.init(points: (mPolyg?.points())!, count: (mPolyg?.pointCount)!)
        annotationImage=geoBaseEntity.getAnnotationImage();
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

protocol PolygonStyler {
    func getStrokeColor()->UIColor
    func getLineWidth()->CGFloat
    func getFillColor()->UIColor
}
struct PolygonStylerConstants {
    static let strokeColor=UIColor(red: 96.0/255.0, green: 224.0/255.0, blue: 173.0/255.0, alpha: 0.8)
    static let fillColor=UIColor(red: 229.0/255.0, green: 252.0/255.0, blue: 194.0/255.0, alpha: 0.8)
    static let lineWidth: CGFloat=5.0
    
    
}

