//
//  MainViewController.swift
//  BelIS
//
//  Created by Thorsten Hell on 08/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import UIKit;
import MapKit;
import ObjectMapper;

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var mapView: MKMapView!;
    @IBOutlet weak var tableView: UITableView!;
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!;
    @IBOutlet weak var mapToolbar: UIToolbar!;
    @IBOutlet weak var focusToggle: UISwitch!
    @IBOutlet weak var textfieldGeoSearch: UITextField!
    
    @IBOutlet weak var bbiMoreFunctionality: UIBarButtonItem!
    
    var matchingSearchItems: [MKMapItem] = [MKMapItem]()
    var matchingSearchItemsAnnotations: [MKPointAnnotation ] = [MKPointAnnotation]()
    var loginViewController: LoginViewController?
    var isLeuchtenEnabled=true;
    var isMastenEnabled=true;
    var isMauerlaschenEnabled=true;
    var isleitungenEnabled=true;
    var isSchaltstelleEnabled=true;
    var highlightedLine : HighlightedMkPolyline?;
    var selectedAnnotation : MKAnnotation?;
    var user="";
    var pass="";
    var timer = NSTimer();
    
    var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 150, 150)) as UIActivityIndicatorView
    
    var gotoUserLocationButton:MKUserTrackingBarButtonItem!;
    var locationManager: CLLocationManager!
    
    let focusRectShape = CAShapeLayer()
    static let IMAGE_PICKER=UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        locationManager=CLLocationManager();
        
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        
        locationManager.distanceFilter=100.0;
        locationManager.startUpdatingLocation();
        locationManager.requestWhenInUseAuthorization()
        
        gotoUserLocationButton=MKUserTrackingBarButtonItem(mapView:mapView);
        
        mapToolbar.items!.insert(gotoUserLocationButton,atIndex:0 );
        
        //delegate stuff
        locationManager.delegate=self;
        mapView.delegate=self;
        tableView.delegate=self;
        
        
        
        //        var tileOverlay = MyOSMMKTileOverlay()
        //        mapView.addOverlay(tileOverlay);
        
        
        let lat: CLLocationDegrees = 51.2751340785898
        let lng: CLLocationDegrees = 7.21241877946317
        let initLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
        
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
        
        //UINavigationController(rootViewController: self)
        textfieldGeoSearch.delegate=self
        bbiMoreFunctionality.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: "WebHostingHub-Glyphs", size: 16)!],
            forState: UIControlState.Normal)
        bbiMoreFunctionality.title=WebHostingGlyps.glyphs["icon-chevron-down"]
        print(UIDevice.currentDevice().identifierForVendor!.UUIDString)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "showSearchSelectionPopover") {
            let selectionVC = segue.destinationViewController as! SelectionPopoverViewController
            selectionVC.mainVC=self;
        }
        else if (segue.identifier == "showAdditionalFunctionalityPopover") {
            let additionalFuncVC = segue.destinationViewController as! AdditionalFunctionalityPopoverViewController
            additionalFuncVC.mainVC=self;
        }
        
    }
    
    @IBAction func geoSearchButtonTabbed(sender: AnyObject) {
        if textfieldGeoSearch.text! != "" {
            geoSearch()
        }
    }
    @IBAction func geoSearchInputDidEnd(sender: AnyObject) {
        geoSearch()
    }
    
    private func geoSearch(){
        if matchingSearchItems.count>0 {
            self.mapView.removeAnnotations(self.matchingSearchItemsAnnotations)
            self.matchingSearchItems.removeAll(keepCapacity: false)
            matchingSearchItemsAnnotations.removeAll(keepCapacity: false)
        }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = textfieldGeoSearch.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        
        search.startWithCompletionHandler({(responseIn:
            MKLocalSearchResponse?,
            errorIn: NSError?) in
            
            if let error = errorIn {
                print("Error occured in search: \(error.localizedDescription)")
            } else if let response=responseIn {
                if response.mapItems.count == 0 {
                    print("No matches found")
                } else {
                    print("Matches found")
                    
                    for item in response.mapItems as [MKMapItem] {
                        
                        
                        self.matchingSearchItems.append(item as MKMapItem)
                        print("Matching items = \(self.matchingSearchItems.count)")
                        
                        let annotation = MatchingSearchItemsAnnotations()
                        annotation.coordinate = item.placemark.coordinate
                        annotation.title = item.name
                        self.matchingSearchItemsAnnotations.append(annotation)
                        self.mapView.addAnnotation(annotation)
                    }
                    
                    self.mapView.showAnnotations(self.matchingSearchItemsAnnotations, animated: true)
                    
                }
            }
        })
        
    }
    
    //UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CidsConnector.sharedInstance().searchResults[Entity.byIndex(section)]?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCellWithIdentifier("firstCellPrototype")as! TableViewCell
        //        var cellInfoProvider: CellInformationProviderProtocol = NoCellInformation()
        if let obj=CidsConnector.sharedInstance().searchResults[Entity.byIndex(indexPath.section)]?[indexPath.row] {
            if let cellInfoProvider=obj as? CellInformationProviderProtocol {
                cell.lblBezeichnung.text=cellInfoProvider.getMainTitle()
                cell.lblStrasse.text=cellInfoProvider.getTertiaryInfo()
                cell.lblSubText.text=cellInfoProvider.getSubTitle()
            }
            
        }
        
        return cell
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Entity.allValues.count
    }
    
    
    //UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        print("didSelectRowAtIndexPath")
        if let obj=CidsConnector.sharedInstance().searchResults[Entity.byIndex(indexPath.section)]?[indexPath.row] {
            selectOnMap(obj)
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let array=CidsConnector.sharedInstance().searchResults[Entity.byIndex(section)]{
            if (array.count>0){
                return 25
            }
        }
        return 0.0
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title=Entity.byIndex(section).rawValue
        if let array=CidsConnector.sharedInstance().searchResults[Entity.byIndex(section)]{
            return title + " \(array.count)"
        }
        else {
            return title
            
        }
    }
    
    // CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    
    
    
    //NKMapViewDelegates
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            if overlay is GeoBaseEntityStyledMkPolylineAnnotation {
                let polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.strokeColor = UIColor(red: 228.0/255.0, green: 118.0/255.0, blue: 37.0/255.0, alpha: 0.8);
                polylineRenderer.lineWidth = 2
                return polylineRenderer
            }
            else if overlay is HighlightedMkPolyline {
                let polylineRenderer = MKPolylineRenderer(overlay: overlay)
                polylineRenderer.strokeColor =  UIColor(red: 255.0/255.0, green: 224.0/255.0, blue: 110.0/255.0, alpha: 0.8);
                polylineRenderer.lineWidth = 10
                return polylineRenderer
                
            }
        }
        else if (overlay is MKTileOverlay){
            
            let renderer =  MyDesperateMKTileOverlayRenderer(tileOverlay: overlay as! MKTileOverlay);
            return renderer;
        }
        return MKOverlayRenderer()
        
    }
    
    
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //        println(mapView.region.span.latitudeDelta);
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is GeoBaseEntityPointAnnotation){
            let gbePA=annotation as! GeoBaseEntityPointAnnotation;
            let reuseId = "belisAnnotation"
            
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: gbePA, reuseIdentifier: reuseId)
                
            }
            else {
                anView!.annotation = gbePA
            }
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            
            anView!.canShowCallout = gbePA.shouldShowCallout;
            anView!.image = UIImage(named: gbePA.imageName);
            
            
            if let label=getGlyphedLabel(gbePA.glyphName) {
                label.textColor=UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
                anView!.leftCalloutAccessoryView=label
            }
            
            
            if let btn=getGlyphedButton("icon-chevron-right"){
                btn.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), forState: UIControlState.Normal)
                anView!.rightCalloutAccessoryView=btn
            }
            anView!.alpha=0.9
            return anView
        } else if (annotation is GeoBaseEntityStyledMkPolylineAnnotation){
            let gbeSMKPA=annotation as! GeoBaseEntityStyledMkPolylineAnnotation;
            let reuseId = "belisAnnotation"
            var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: gbeSMKPA, reuseIdentifier: reuseId)
                
            }
            else {
                anView!.annotation = gbeSMKPA
            }
            
            if let label=getGlyphedLabel(gbeSMKPA.glyphName) {
                label.textColor=UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
                anView!.leftCalloutAccessoryView=label
            }
            if let btn=getGlyphedButton("icon-chevron-right"){
                btn.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), forState: UIControlState.Normal)
                anView!.rightCalloutAccessoryView=btn
            }
            
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            anView!.image = UIImage(named: gbeSMKPA.imageName);
            anView!.canShowCallout = gbeSMKPA.shouldShowCallout;
            anView!.alpha=0.9
            return anView
            
        }
        
        return nil;
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
    
    
    
    func mapView(mapView: MKMapView, didChangeUserTrackingMode mode: MKUserTrackingMode, animated: Bool) {
        print("didChangeUserTrackingMode")
    }
    
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        delay(0.0)
            {
                if !view.annotation!.isKindOfClass(MatchingSearchItemsAnnotations) {
                    if view.annotation !== self.selectedAnnotation {
                        mapView.deselectAnnotation(view.annotation, animated: false)
                        if let selAnno=self.selectedAnnotation {
                            mapView.selectAnnotation(selAnno, animated: false)
                        }
                    }
                }
                
        }
        print("didSelectAnnotationView >> \(view.annotation!.title)")
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        delay(0.0)
            {
                if view.annotation === self.selectedAnnotation {
                    if let selAnno=self.selectedAnnotation {
                        mapView.selectAnnotation(selAnno, animated: false)
                    }
                }
                
        }
        print("didDeselectAnnotationView >> \(view.annotation!.title)")
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
        //let hittedUI = mapView.hitTest(touchPt, withEvent: nil)
        //        println(hittedUI)
        print("mapTabbed")
        
        
        let buffer=CGFloat(22)
        
        var foundPolyline: GeoBaseEntityStyledMkPolylineAnnotation?
        var foundPoint: GeoBaseEntityPointAnnotation?
        
        
        
        
        
        
        for anno: AnyObject in mapView.annotations {
            if let pointAnnotation = anno as? GeoBaseEntityPointAnnotation {
                let cgPoint = mapView.convertCoordinate(pointAnnotation.coordinate, toPointToView: mapView)
                let path  = CGPathCreateMutable()
                CGPathMoveToPoint(path, nil, cgPoint.x, cgPoint.y)
                CGPathAddLineToPoint(path, nil, cgPoint.x, cgPoint.y)
                
                let fuzzyPath=CGPathCreateCopyByStrokingPath(path, nil, buffer, CGLineCap.Round, CGLineJoin.Round, 0.0)
                if (CGPathContainsPoint(fuzzyPath, nil, touchPt, false)) {
                    foundPoint = pointAnnotation
                    print("foundPoint")
                    selectOnMap(foundPoint?.getGeoBaseEntity())
                    selectInTable(foundPoint?.getGeoBaseEntity())
                    break
                }
            }
        }
        
        if (foundPoint == nil){
            
            for overlay: AnyObject in mapView.overlays {
                if let lineAnnotation  = overlay as? GeoBaseEntityStyledMkPolylineAnnotation{
                    let path  = CGPathCreateMutable()
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
                    let fuzzyPath=CGPathCreateCopyByStrokingPath(path, nil, buffer, CGLineCap.Round, CGLineJoin.Round, 0.0)
                    if (CGPathContainsPoint(fuzzyPath, nil, touchPt, false)) {
                        foundPolyline = lineAnnotation
                        break
                    }
                }
            }
            
            if let hitPolyline = foundPolyline {
                selectOnMap(hitPolyline.getGeoBaseEntity())
                selectInTable(hitPolyline.getGeoBaseEntity())
                print("selected Line with \(hitPolyline.pointCount) points")
            }
            else {
                selectOnMap(nil)
            }
        }
        
    }
    
    func selectOnMap(geoBaseEntityToSelect : GeoBaseEntity?){
        if  highlightedLine != nil {
            mapView.removeOverlay(highlightedLine!);
        }
        if (selectedAnnotation != nil){
            mapView.deselectAnnotation(selectedAnnotation, animated: false)
        }
        
        if let geoBaseEntity = geoBaseEntityToSelect{
            let mapObj=geoBaseEntity.mapObject
            
            mapView.selectAnnotation(mapObj as! MKAnnotation, animated: true);
            selectedAnnotation=mapObj as? MKAnnotation
            
            if mapObj is GeoBaseEntityPointAnnotation {
                
                
            }
            else if mapObj is GeoBaseEntityStyledMkPolylineAnnotation {
                let line = mapObj as! GeoBaseEntityStyledMkPolylineAnnotation;
                highlightedLine = HighlightedMkPolyline(points: line.points(), count: line.pointCount);
                mapView.removeOverlay(line);
                mapView.addOverlay(highlightedLine!);
                mapView.addOverlay(line); //bring the highlightedLine below the line
                
            }
        } else {
            selectedAnnotation=nil
        }
    }
    
    
    func selectInTable(geoBaseEntityToSelect : GeoBaseEntity?){
        if let geoBaseEntity = geoBaseEntityToSelect{
            let entity=geoBaseEntity.getType()
            
            //need old fashioned loop for index
            for i in 0...CidsConnector.sharedInstance().searchResults[entity]!.count-1 {
                var results : [GeoBaseEntity] = CidsConnector.sharedInstance().searchResults[entity]!
                if results[i].id == geoBaseEntity.id {
                    tableView.selectRowAtIndexPath(NSIndexPath(forRow: i, inSection: entity.index()), animated: true, scrollPosition: UITableViewScrollPosition.Top)
                    break;
                }
            }
        }
    }
    
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
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
            let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
            detailVC.sections=leuchte.getDataSectionKeys()
            detailVC.setCellData(leuchte.getAllData())
            detailVC.actions=leuchte.getAllActions()
            
            detailVC.objectToShow=leuchte
            detailVC.title="Leuchte"
            let detailNC=UINavigationController(rootViewController: detailVC)
            let action = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: detailVC, action:"moreAction")
            detailVC.navigationItem.rightBarButtonItem = action
            let icon=UIBarButtonItem()
            icon.image=getGlyphedImage("icon-ceilinglight")
            detailVC.navigationItem.leftBarButtonItem = icon
            selectedAnnotation=nil
            mapView.deselectAnnotation(view.annotation, animated: false)
            let popC=UIPopoverController(contentViewController: detailNC)
            popC.presentPopoverFromRect(view.frame, inView: mapView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
        else if let standort = geoBaseEntity as? Standort {
            let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
            detailVC.sections=standort.getDataSectionKeys()
            detailVC.setCellData(standort.getAllData())
            detailVC.actions=standort.getAllActions()
            
            detailVC.objectToShow=standort
            detailVC.title="Mast"
            let detailNC=UINavigationController(rootViewController: detailVC)
            let action = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: detailVC, action:"moreAction")
            detailVC.navigationItem.rightBarButtonItem = action
            let icon=UIBarButtonItem()
            icon.image=getGlyphedImage("icon-horizontalexpand")
            detailVC.navigationItem.leftBarButtonItem = icon
            selectedAnnotation=nil
            mapView.deselectAnnotation(view.annotation, animated: false)
            let popC=UIPopoverController(contentViewController: detailNC)
            popC.presentPopoverFromRect(view.frame, inView: mapView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
        else if let leitung = geoBaseEntity as? Leitung {
            let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
            detailVC.sections=leitung.getDataSectionKeys()
            detailVC.setCellData(leitung.getAllData())
            detailVC.actions=leitung.getAllActions()
            
            detailVC.objectToShow=leitung
            detailVC.title="Leitung"
            let detailNC=UINavigationController(rootViewController: detailVC)
            let action = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: detailVC, action:"moreAction")
            detailVC.navigationItem.rightBarButtonItem = action
            let icon=UIBarButtonItem()
            icon.image=getGlyphedImage("icon-line")
            detailVC.navigationItem.leftBarButtonItem = icon
            selectedAnnotation=nil
            mapView.deselectAnnotation(view.annotation, animated: false)
            let popC=UIPopoverController(contentViewController: detailNC)
            //popC.popoverContentSize = CGSizeMake(200, 70);
            popC.presentPopoverFromRect(view.frame, inView: mapView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
        else if let mauerlasche = geoBaseEntity as? Mauerlasche {
            let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
            detailVC.objectToShow=mauerlasche
            detailVC.sections=mauerlasche.getDataSectionKeys()
            
            detailVC.setCellData(mauerlasche.getAllData())
            detailVC.title="Mauerlasche"
            detailVC.actions=mauerlasche.getAllActions()
            let detailNC=UINavigationController(rootViewController: detailVC)
            let action = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: detailVC, action:"moreAction")
            detailVC.navigationItem.rightBarButtonItem = action
            let icon=UIBarButtonItem()
            icon.image=getGlyphedImage("icon-nut")
            detailVC.navigationItem.leftBarButtonItem = icon
            selectedAnnotation=nil
            mapView.deselectAnnotation(view.annotation, animated: false)
            let popC=UIPopoverController(contentViewController: detailNC)
            //popC.popoverContentSize = CGSizeMake(200, 70);
            popC.presentPopoverFromRect(view.frame, inView: mapView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
        else if let schaltstelle = geoBaseEntity as? Schaltstelle {
            let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
            detailVC.sections=schaltstelle.getDataSectionKeys()
            detailVC.setCellData(schaltstelle.getAllData())
            detailVC.title="Schaltstelle"
            detailVC.actions=schaltstelle.getAllActions()
            
            detailVC.objectToShow=schaltstelle
            let detailNC=UINavigationController(rootViewController: detailVC)
            let action = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: detailVC, action:"moreAction")
            detailVC.navigationItem.rightBarButtonItem = action
            let icon=UIBarButtonItem()
            icon.image=getGlyphedImage("icon-switch")
            detailVC.navigationItem.leftBarButtonItem = icon
            selectedAnnotation=nil
            mapView.deselectAnnotation(view.annotation, animated: false)
            let popC=UIPopoverController(contentViewController: detailNC)
            //popC.popoverContentSize = CGSizeMake(200, 70);
            popC.presentPopoverFromRect(view.frame, inView: mapView, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    
    
    
    //Actions
    
    @IBAction func searchButtonTabbed(sender: AnyObject) {
        for (_, entityArray) in CidsConnector.sharedInstance().searchResults{
            for obj in entityArray {
                obj.removeFromMapView(mapView);
            }
        }
        
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
        
        
        let mRegion=MKCoordinateRegionForMapRect(mRect);
        let x1=mRegion.center.longitude-(mRegion.span.longitudeDelta/2)
        let y1=mRegion.center.latitude-(mRegion.span.latitudeDelta/2)
        let x2=mRegion.center.longitude+(mRegion.span.longitudeDelta/2)
        let y2=mRegion.center.latitude+(mRegion.span.latitudeDelta/2)
        
        
        let ewktMapExtent="SRID=4326;POLYGON((\(x1) \(y1),\(x1) \(y2),\(x2) \(y2),\(x2) \(y1),\(x1) \(y1)))";
        
        
        CidsConnector.sharedInstance().search(ewktMapExtent, leuchtenEnabled: isLeuchtenEnabled, mastenEnabled: isMastenEnabled, mauerlaschenEnabled: isMauerlaschenEnabled, leitungenEnabled: isleitungenEnabled,schaltstellenEnabled: isSchaltstelleEnabled ) {
            
            assert(!NSThread.isMainThread() )
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData();
                
                for (_, objArray) in CidsConnector.sharedInstance().searchResults{
                    for obj in objArray {
                        
                        obj.addToMapView(self.mapView);
                        
                    }
                }
                self.actInd.stopAnimating();
                self.actInd.removeFromSuperview();
            }
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
                print("landscape")
            } else {
                print("portraight")
            }
            self.ensureFocusRectangleIsDisplayedWhenAndWhereItShould()
        })
        
    }
    
    
}
