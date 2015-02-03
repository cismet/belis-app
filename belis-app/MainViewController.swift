//
//  MainViewController.swift
//  BelIS
//
//  Created by Thorsten Hell on 08/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import UIKit;
import MapKit;
import Alamofire;
import ObjectMapper;


class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!;
    @IBOutlet weak var tableView: UITableView!;
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!;
    @IBOutlet weak var mapToolbar: UIToolbar!;
    @IBOutlet weak var focusToggle: UISwitch!
    
    let LEUCHTEN = 0;
    let MAUERLASCHEN = 1;
    let LEITUNGEN = 2;

    var searchResults : [[GeoBaseEntity]] = [
        [Leuchte](),[Mauerlasche](),[Leitung]()
    ];

    var isLeuchtenEnabled=true;
    var isMauerlaschenEnabled=false;
    var isleitungenEnabled=true;
    var highlightedLine : HighlightedMkPolyline?;
    
    
    var timer = NSTimer();
    
//    var mappingLeuchte = RKObjectMapping(forClass: Leuchte.self);
//    mappingLeuchte.addAttributeMappingsFromDictionary([
//    "id":"id",
//    "geom": "wgs84WKT",
//    ]);
    
    var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 150, 150)) as UIActivityIndicatorView
   
    
    var gotoUserLocationButton:MKUserTrackingBarButtonItem!;
    var locationManager: CLLocationManager!
    
    let focusRectShape = CAShapeLayer()

    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        locationManager=CLLocationManager();
        
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        
        locationManager.distanceFilter=100.0;
        locationManager.startUpdatingLocation();
        locationManager.requestWhenInUseAuthorization()
        
        gotoUserLocationButton=MKUserTrackingBarButtonItem(mapView:mapView);

        mapToolbar.items!.insert(gotoUserLocationButton,atIndex:0 );
        
//        var mappingLeitung = RKObjectMapping(forClass: Leitung.self);
//        mappingLeitung.addAttributeMappingsFromDictionary([
//            "id":"id",
//            "geom": "wgs84WKT",
//            "typ":"leitungstyp"
//            ]);
//
//        var jsonString="{"id"}";
        

        
        //delegate stuff
        locationManager.delegate=self;
        mapView.delegate=self;
        tableView.delegate=self;
        
        
        

//        var tileOverlay = MyOSMMKTileOverlay()
//        mapView.addOverlay(tileOverlay);
        
        
        var lat: CLLocationDegrees = 51.2751340785898
        var lng: CLLocationDegrees = 7.21241877946317
        var initLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)

        mapView.rotateEnabled=false;
        mapView.zoomEnabled=true;
        mapView.showsBuildings=true;

        mapView.setCenterCoordinate(initLocation, animated: true);
        mapView.camera.altitude = 50;
        
        focusRectShape.opacity = 0.4
        focusRectShape.lineWidth = 2
        focusRectShape.lineJoin = kCALineJoinMiter
        focusRectShape.strokeColor = UIColor(red: 0.29, green: 0.53, blue: 0.53, alpha: 1).CGColor
        focusRectShape.fillColor = UIColor(red: 0.51, green: 0.76, blue: 0.6, alpha: 1).CGColor
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "showSearchSelectionPopover") {
            let selectionVC = segue.destinationViewController as SelectionPopoverViewController;
            selectionVC.mainVC=self;
        }
        
    }

    
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults[section].count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: TableViewCell = tableView.dequeueReusableCellWithIdentifier("firstCellPrototype") as TableViewCell
        if indexPath.section==LEUCHTEN {
//            println(indexPath.row);
            let leuchte = searchResults[indexPath.section][indexPath.row] as Leuchte;
            cell.lblBezeichnung.text="L \(leuchte.standort!.laufendeNummer).\(leuchte.leuchtenNummer)";
            cell.lblStrasse.text="\(leuchte.standort!.strasse!)";
            cell.lblSubText.text="\(leuchte.typ!)";
        }
        else if indexPath.section==MAUERLASCHEN {
            let mauerlasche = searchResults[indexPath.section][indexPath.row] as Mauerlasche;
            cell.lblBezeichnung.text="Mauerlasche";
            cell.lblStrasse.text="\(mauerlasche.strasse!)";
            cell.lblSubText.text="Laufende Nummer:\(mauerlasche.laufendeNummer)";
          
        }
        else if indexPath.section==LEITUNGEN {
            let leitung = searchResults[indexPath.section][indexPath.row]  as Leitung;
            cell.lblBezeichnung.text="Leitung";
            cell.lblStrasse.text="\(leitung.id!)";
            cell.lblSubText.text="\(leitung.leitungstyp!)";
            
        }
        
        return cell;
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        if  highlightedLine != nil {
            mapView.removeOverlay(highlightedLine);
        }
        var mapObj=searchResults[indexPath.section][indexPath.row].mapObject;

        if mapObj is GeoBaseEntityPointAnnotation {
            mapView.selectAnnotation(mapObj as MKAnnotation, animated: true);
        }
        else if mapObj is StyledMkPolyline {
            var line = mapObj as StyledMkPolyline;
            highlightedLine = HighlightedMkPolyline(points: line.points(), count: line.pointCount);
            mapView.removeOverlay(line);
            mapView.addOverlay(highlightedLine);
            mapView.addOverlay(line);
            
        }

    }
    
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (searchResults[section].count>0){
            return 25;
        }
        else {
            return 0.0;
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section==0){
            return "Leuchten \(searchResults[LEUCHTEN].count)";
        }
        else if (section==1){
            return "Mauerlaschen \(searchResults[MAUERLASCHEN].count)";
        }else
        {
            return "Leitungen \(searchResults[LEITUNGEN].count)";
        }
    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//       
//    }
//    
//    func tableView(tableView: UITableView!, editActionsForRowAtIndexPath indexPath: NSIndexPath!) -> [AnyObject]! {
//        
//    }

    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
//        println("locations = \(locations)");
    }
    
    
    
    
    //NKMapViewDelegates
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            if overlay is StyledMkPolyline {
                var polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.strokeColor = UIColor(red: 228.0/255.0, green: 118.0/255.0, blue: 37.0/255.0, alpha: 0.8);
                polylineRenderer.lineWidth = 2
                return polylineRenderer
            }
            else if overlay is HighlightedMkPolyline {
                var polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.strokeColor =  UIColor(red: 255.0/255.0, green: 224.0/255.0, blue: 110.0/255.0, alpha: 0.8);
                polylineRenderer.lineWidth = 10
                return polylineRenderer
                
            }
        }
        else if (overlay is MKTileOverlay){
            
            var renderer =  MyDesperateMKTileOverlayRenderer(tileOverlay: overlay as MKTileOverlay);
            return renderer;
        }
        return nil
    }
    
    
    
    
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
//        println(mapView.region.span.latitudeDelta);
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation is GeoBaseEntityPointAnnotation){
            let gbePA=annotation as GeoBaseEntityPointAnnotation;
            let reuseId = "belisAnnotation"
            
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: gbePA, reuseIdentifier: reuseId)
               
            }
            else {
                anView.annotation = gbePA
            }
            
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            
            anView.canShowCallout = gbePA.shouldShowCallout;
            anView.image = UIImage(named: gbePA.imageName);
            anView.rightCalloutAccessoryView=UIButton.buttonWithType(UIButtonType.DetailDisclosure) as UIView;
            anView.leftCalloutAccessoryView=UIImageView(image: UIImage(named: gbePA.callOutLeftImageName));

            return anView
        }
        return nil;
      }
    
    
    func mapView(mapView: MKMapView!, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        println("didChangeUserTrackingMode")
    }
    
    //Actions
    
    @IBAction func searchButtonTabbed(sender: AnyObject) {
        for entityClass in searchResults{
            for entity in entityClass {
                entity.removeFromMapView(mapView);
            }
        }

        searchResults=[[Leuchte](),[Mauerlasche](),[Leitung]()];
        
        self.tableView.reloadData();

        actInd.center = mapView.center;
        actInd.hidesWhenStopped = true;
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray;
        self.view.addSubview(actInd);
        actInd.startAnimating();

        
        var mRect : MKMapRect
        if focusToggle.on {
            mRect = createFocusRect()
        }
        else {
            mRect = self.mapView.visibleMapRect;
        }

        
        var mRegion=MKCoordinateRegionForMapRect(mRect);
        var x1=mRegion.center.longitude-(mRegion.span.longitudeDelta/2)
        var y1=mRegion.center.latitude-(mRegion.span.latitudeDelta/2)
        var x2=mRegion.center.longitude+(mRegion.span.longitudeDelta/2)
        var y2=mRegion.center.latitude+(mRegion.span.latitudeDelta/2)
        
        
        let ewktMapExtent="SRID=4326;POLYGON((\(x1) \(y1),\(x1) \(y2),\(x2) \(y2),\(x2) \(y1),\(x1) \(y1)))";
        
        
        CidsConnector(user: "WendlingM@BELIS2", password: "kif").search(ewktMapExtent, leuchtenEnabled: "\(isLeuchtenEnabled)", mauerlaschenEnabled: "\(isMauerlaschenEnabled)", leitungenEnabled: "\(isleitungenEnabled)") {
            searchResults in
            self.searchResults=searchResults
            self.tableView.reloadData();
            
            for entityClass in searchResults{
                for entity in entityClass {
                    
                    entity.addToMapView(self.mapView);
                    
                }
            }
            self.actInd.stopAnimating();
            self.actInd.removeFromSuperview();
            
        }

    }
    
    func createFocusRect() -> MKMapRect {
        let mRect = self.mapView.visibleMapRect;
        let newSize = MKMapSize(width: mRect.size.width/3,height: mRect.size.height/3)
        let newOrigin = MKMapPoint(x: mRect.origin.x+newSize.width, y: mRect.origin.y+newSize.height)
        return MKMapRect(origin: newOrigin,size: newSize)
    }

    
    @IBAction func mapTypeButtonTabbed(sender: AnyObject) {
        switch(mapTypeSegmentedControl.selectedSegmentIndex){
    
        case 0:
            mapView.mapType=MKMapType.Standard;
        case 1:
            mapView.mapType=MKMapType.Hybrid;
        case 2:
            mapView.mapType=MKMapType.Satellite;
        default:
            mapView.mapType=MKMapType.Standard;
        }
        
    }
    
    @IBAction func lookUpButtonTabbed(sender: AnyObject) {
//        if tableView.hidden {
//            tableView.hidden = false;
//        }
//        else {
//            tableView.hidden = true;
//        }

//        tableView.selectRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 2), animated: true,scrollPosition: UITableViewScrollPosition.Middle);
//        tableView(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 2));
        
    }
   
    @IBAction func focusItemTabbed(sender: AnyObject) {
        
        focusToggle.setOn(!focusToggle.on, animated: true)
    }
    
    @IBAction func focusToggleValueChanged(sender: AnyObject) {
        ensureFocusRectangleIsDisplayedWhenAndWhereItShould()
    }
    
    private func ensureFocusRectangleIsDisplayedWhenAndWhereItShould(){
        focusRectShape.removeFromSuperlayer()
        if focusToggle.on {
            let path = UIBezierPath()
            let w = self.mapView.frame.width / 3
            let h = self.mapView.frame.height / 3
            let x1 = w
            let y1 = h
            let x2 = x1 + w
            let y2 = y1
            let x3 = x2
            let y3 = y2 + h
            let x4 = x1
            let y4 = y3
            
            path.moveToPoint(CGPointMake(x1, y1))
            path.addLineToPoint(CGPointMake(x2, y2))
            path.addLineToPoint(CGPointMake(x3, y3))
            path.addLineToPoint(CGPointMake(x4, y4))
            path.closePath()
            focusRectShape.path = path.CGPath
            mapView.layer.addSublayer(focusRectShape)

        }
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        focusRectShape.removeFromSuperlayer()
        coordinator.animateAlongsideTransition(nil, completion: { context in
            if UIDevice.currentDevice().orientation.isLandscape.boolValue {
                println("landscape")
            } else {
                println("portraight")
            }
            self.ensureFocusRectangleIsDisplayedWhenAndWhereItShould()
        })
        
    }
}
