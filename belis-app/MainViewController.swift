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
    var isMauerlaschenEnabled=true;
    var isleitungenEnabled=true;
    var highlightedLine : HighlightedMkPolyline?;
    var selectedAnnotation : MKAnnotation?;
    
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
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("mapTapped:"))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        //mapView.gestureRecognizerShouldBegin(tapGestureRecognizer)
        
        UINavigationController(rootViewController: self)
        
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
        var cellInfoProvider: CellInformationProviderProtocol = NoCellInformation()
        
        if indexPath.section==LEUCHTEN {
            //            println(indexPath.row);
            let leuchte = searchResults[indexPath.section][indexPath.row] as Leuchte;
            cellInfoProvider=leuchte
        }
        else if indexPath.section==MAUERLASCHEN {
            let mauerlasche = searchResults[indexPath.section][indexPath.row] as Mauerlasche;
            cellInfoProvider=mauerlasche
        }
        else if indexPath.section==LEITUNGEN {
            let leitung = searchResults[indexPath.section][indexPath.row]  as Leitung;
            cellInfoProvider=leitung
        }
        
        cell.lblBezeichnung.text=cellInfoProvider.getMainTitle()
        cell.lblStrasse.text=cellInfoProvider.getTertiaryInfo()
        cell.lblSubText.text=cellInfoProvider.getSubTitle()
        
        return cell;
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3;
    }
    
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        println("didSelectRowAtIndexPath")
        selectOnMap(searchResults[indexPath.section][indexPath.row])
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
    
    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
    }
    
    
    
    
    //NKMapViewDelegates
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            if overlay is GeoBaseEntityStyledMkPolylineAnnotation {
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
            
            
            if let label=getGlyphedLabel(gbePA.glyphName) {
                label.textColor=UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
                anView.leftCalloutAccessoryView=label
            }
            
            
            if let btn=getGlyphedButton("icon-chevron-right"){
                btn.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), forState: UIControlState.Normal)
                anView.rightCalloutAccessoryView=btn
            }
            anView.alpha=0.9
            return anView
        } else if (annotation is GeoBaseEntityStyledMkPolylineAnnotation){
            let gbeSMKPA=annotation as GeoBaseEntityStyledMkPolylineAnnotation;
            let reuseId = "belisAnnotation"
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: gbeSMKPA, reuseIdentifier: reuseId)
                
            }
            else {
                anView.annotation = gbeSMKPA
            }
            
            if let label=getGlyphedLabel(gbeSMKPA.glyphName) {
                label.textColor=UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
                anView.leftCalloutAccessoryView=label
            }
            if let btn=getGlyphedButton("icon-chevron-right"){
                btn.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), forState: UIControlState.Normal)
                anView.rightCalloutAccessoryView=btn
            }
            
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            anView.image = UIImage(named: gbeSMKPA.imageName);
            anView.canShowCallout = gbeSMKPA.shouldShowCallout;
            anView.alpha=0.9
            return anView
            
        }
        
        return nil;
    }
    func getGlyphedLabel(glyphName: String) -> UILabel? {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {
            var label=UILabel(frame: CGRectMake(0, 0, 25,25))
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
    func getGlyphedImage(glyphName: String) -> UIImage? {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {
            
            let color=UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
            let alpha=UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
            let font=UIFont(name: "WebHostingHub-Glyphs", size: 14)!
            let image=UIImage(text: glyph, font: font, color: color, backgroundColor: alpha, size: CGSize(width: 20,height:20), offset: CGPoint(x: 0, y: 2))
            return image
        }
        else  {
            return nil
        }
    }
    
    
    func getGlyphedButton(glyphName: String) -> UIButton? {
        if let glyph=WebHostingGlyps.glyphs[glyphName] {
            var btn=UIButton(frame: CGRectMake(0, 0, 25,25))
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
    
    
    
    func mapView(mapView: MKMapView!, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        println("didChangeUserTrackingMode")
    }
    
    
    func mapView(mapView: MKMapView!, didSelectAnnotationView view: MKAnnotationView!) {
        delay(0.0)
            {
                if view.annotation !== self.selectedAnnotation {
                    mapView.deselectAnnotation(view.annotation, animated: false)
                    mapView.selectAnnotation(self.selectedAnnotation, animated: false)
                }
                
        }
        println("didSelectAnnotationView >> \(view.annotation.title)")
    }
    
    func mapView(mapView: MKMapView!, didDeselectAnnotationView view: MKAnnotationView!) {
        delay(0.0)
            {
                if view.annotation === self.selectedAnnotation {
                    mapView.selectAnnotation(self.selectedAnnotation, animated: false)
                }
                
        }
        println("didDeselectAnnotationView >> \(view.annotation.title)")
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // MARK: - Use mark to logically organize your code
    func mapTapped(sender: UITapGestureRecognizer) {
        let touchPt = sender.locationInView(mapView)
        var hittedUI = mapView.hitTest(touchPt, withEvent: nil)
        //        println(hittedUI)
        println("mapTabbed")
        
        
        let buffer=CGFloat(22)
        
        var foundPolyline: GeoBaseEntityStyledMkPolylineAnnotation?
        var foundPoint: GeoBaseEntityPointAnnotation?
        
        
        
        
        
        
        if mapView.annotations != nil {
            for anno: AnyObject in mapView.annotations {
                if let pointAnnotation = anno as? GeoBaseEntityPointAnnotation {
                    let cgPoint = mapView.convertCoordinate(pointAnnotation.coordinate, toPointToView: mapView)
                    var path  = CGPathCreateMutable()
                    CGPathMoveToPoint(path, nil, cgPoint.x, cgPoint.y)
                    CGPathAddLineToPoint(path, nil, cgPoint.x, cgPoint.y)
                    
                    let fuzzyPath=CGPathCreateCopyByStrokingPath(path, nil, buffer, kCGLineCapRound, kCGLineJoinRound, 0.0)
                    if (CGPathContainsPoint(fuzzyPath, nil, touchPt, false)) {
                        foundPoint = pointAnnotation
                        println("foundPoint")
                        selectOnMap(foundPoint?.getGeoBaseEntity())
                        selectInTable(foundPoint?.getGeoBaseEntity())
                        break
                    }
                }
            }
        }
        
        if (foundPoint == nil){
            
            if mapView.overlays != nil {
                for overlay: AnyObject in mapView.overlays {
                    if let lineAnnotation  = overlay as? GeoBaseEntityStyledMkPolylineAnnotation{
                        var path  = CGPathCreateMutable()
                        for i in 0...lineAnnotation.pointCount-1 {
                            let mapPoint = lineAnnotation.points()[i]
                            
                            let cgPoint = mapView.convertCoordinate(MKCoordinateForMapPoint(mapPoint), toPointToView: mapView)
                            if i==0 {
                                CGPathMoveToPoint(path, nil, cgPoint.x, cgPoint.y)
                            }
                            else {
                                CGPathAddLineToPoint(path, nil, cgPoint.x, cgPoint.y)
                            }
                        }
                        let fuzzyPath=CGPathCreateCopyByStrokingPath(path, nil, buffer, kCGLineCapRound, kCGLineJoinRound, 0.0)
                        if (CGPathContainsPoint(fuzzyPath, nil, touchPt, false)) {
                            foundPolyline = lineAnnotation
                            break
                        }
                    }
                }
                
                if let hitPolyline = foundPolyline {
                    selectOnMap(hitPolyline.getGeoBaseEntity())
                    selectInTable(hitPolyline.getGeoBaseEntity())
                    println("selected Line with \(hitPolyline.pointCount) points")
                }
                else {
                    selectOnMap(nil)
                }
                
            }
        }
        
    }
    
    func selectOnMap(geoBaseEntityToSelect : GeoBaseEntity?){
        if  highlightedLine != nil {
            mapView.removeOverlay(highlightedLine);
        }
        if (selectedAnnotation != nil){
            mapView.deselectAnnotation(selectedAnnotation, animated: false)
        }
        
        if let geoBaseEntity = geoBaseEntityToSelect{
            var mapObj=geoBaseEntity.mapObject
            
            mapView.selectAnnotation(mapObj as MKAnnotation, animated: true);
            selectedAnnotation=mapObj as? MKAnnotation
            
            if mapObj is GeoBaseEntityPointAnnotation {
                
                
            }
            else if mapObj is GeoBaseEntityStyledMkPolylineAnnotation {
                var line = mapObj as GeoBaseEntityStyledMkPolylineAnnotation;
                highlightedLine = HighlightedMkPolyline(points: line.points(), count: line.pointCount);
                mapView.removeOverlay(line);
                mapView.addOverlay(highlightedLine);
                mapView.addOverlay(line); //bring the highlightedLine below the line
                
            }
        } else {
            selectedAnnotation=nil
        }
    }
    
    
    func selectInTable(geoBaseEntityToSelect : GeoBaseEntity?){
        if let geoBaseEntity = geoBaseEntityToSelect?{
            var kindOfGeoBaseEntity = 0;
            if geoBaseEntity is Leuchte {
                kindOfGeoBaseEntity=LEUCHTEN
            } else if geoBaseEntity is Leitung {
                kindOfGeoBaseEntity=LEITUNGEN
            } else if geoBaseEntity is Mauerlasche {
                kindOfGeoBaseEntity=MAUERLASCHEN
            }
            for i in 0...searchResults[kindOfGeoBaseEntity].count-1 {
                var results : [GeoBaseEntity] = searchResults[kindOfGeoBaseEntity]
                if results[i].id == geoBaseEntity.id {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: i, inSection: kindOfGeoBaseEntity), animated: true, scrollPosition: UITableViewScrollPosition.Top)
                    break;
                }
            }
        }
    }
    
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        //var detailVC=LeuchtenDetailsViewController()
        //        var detailVC=storyboard!.instantiateViewControllerWithIdentifier("LeuchtenDetails") as UIViewController
        var geoBaseEntity: GeoBaseEntity?
        if let pointAnnotation = view.annotation as? GeoBaseEntityPointAnnotation {
            geoBaseEntity=pointAnnotation.geoBaseEntity
        }
        else if let lineAnnotation = view.annotation as? GeoBaseEntityStyledMkPolylineAnnotation {
            geoBaseEntity=lineAnnotation.geoBaseEntity
        }
        
        if let leuchte = geoBaseEntity as? Leuchte {
            let detailMainVC=LeuchtenMainVC(nibName: "LeuchtenMainVC", bundle: nil)
            detailMainVC.title="Leuchte"
            let detailAllVC=LeuchtenAllVC(nibName: "LeuchtenAllVC", bundle: nil)
            detailAllVC.title="mehr"
            let dokumenteVC=DokumenteVC(nibName: "DokumenteVC", bundle: nil)
            dokumenteVC.title="Dokumente"
            let dokumenteNC=UINavigationController(rootViewController: dokumenteVC)
            var tbc = UITabBarController()
            tbc.setViewControllers([detailMainVC,detailAllVC,dokumenteNC], animated: true)
            (tbc.tabBar.items as [UITabBarItem])[0].image=getGlyphedImage("icon-ceilinglight")
            (tbc.tabBar.items as [UITabBarItem])[1].image=getGlyphedImage("icon-tag")
            (tbc.tabBar.items as [UITabBarItem])[2].image=getGlyphedImage("icon-document")
            selectedAnnotation=nil
            mapView.deselectAnnotation(view.annotation, animated: false)
            let popC=UIPopoverController(contentViewController: tbc)
            //popC.popoverContentSize = CGSizeMake(200, 70);
            
            popC.presentPopoverFromRect(view.frame, inView: mapView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            
        }
        else if let leitung = geoBaseEntity as? Leitung {
            let detailVC=LeitungenVC(nibName: "LeitungenVC", bundle: nil)
            detailVC.title="Leitung"
            detailVC.leitung=leitung
            
            let dokumenteVC=DokumenteVC(nibName: "DokumenteVC", bundle: nil)
            dokumenteVC.title="Dokumente"
            var dokumenteNC=UINavigationController(rootViewController: dokumenteVC)
            dokumenteVC.dmsUrls=leitung.dokumente
            
            var tbc = UITabBarController()
            tbc.setViewControllers([detailVC,dokumenteNC], animated: true)
            (tbc.tabBar.items as [UITabBarItem])[0].image=getGlyphedImage("icon-line")
            (tbc.tabBar.items as [UITabBarItem])[1].image=getGlyphedImage("icon-document")
            selectedAnnotation=nil
            mapView.deselectAnnotation(view.annotation, animated: false)
            let popC=UIPopoverController(contentViewController: tbc)
            //popC.popoverContentSize = CGSizeMake(200, 70);
            
            popC.presentPopoverFromRect(view.frame, inView: mapView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            
        }
        else if let mauerlasche = geoBaseEntity as? Mauerlasche {
            let detailVC=MauerlascheVC(nibName: "MauerlascheVC", bundle: nil)
            detailVC.title=mauerlasche.getMainTitle()
            let dokumenteVC=DokumenteVC(nibName: "DokumenteVC", bundle: nil)
            dokumenteVC.title="Dokumente"
            var dokumenteNC=UINavigationController(rootViewController: dokumenteVC)
            var detailNC=UINavigationController(rootViewController: detailVC)
            var action = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: detailVC, action:"someAction")
            
            detailVC.navigationItem.rightBarButtonItem = action
            
            
            var tbc = UITabBarController()
            tbc.setViewControllers([detailNC,dokumenteNC], animated: true)
            (tbc.tabBar.items as [UITabBarItem])[0].image=getGlyphedImage("icon-nut")
            (tbc.tabBar.items as [UITabBarItem])[1].image=getGlyphedImage("icon-document")
            selectedAnnotation=nil
            mapView.deselectAnnotation(view.annotation, animated: false)
            let popC=UIPopoverController(contentViewController: tbc)
            //popC.popoverContentSize = CGSizeMake(200, 70);
            
            popC.presentPopoverFromRect(view.frame, inView: mapView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
            
        }
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
        
        
        CidsConnector(user: "WendlingM@BELIS2", password: "boxy").search(ewktMapExtent, leuchtenEnabled: "\(isLeuchtenEnabled)", mauerlaschenEnabled: "\(isMauerlaschenEnabled)", leitungenEnabled: "\(isleitungenEnabled)") {
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
