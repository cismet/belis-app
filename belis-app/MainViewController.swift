//
//  MainViewController.swift
//  BelIS
//
//  Created by Thorsten Hell on 08/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import UIKit;
import MapKit;

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!;
    @IBOutlet weak var tableView: UITableView!;
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!;
    @IBOutlet weak var mapToolbar: UIToolbar!;

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
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        locationManager=CLLocationManager();
        
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        locationManager.requestAlwaysAuthorization();
        
        locationManager.distanceFilter=100.0;
        locationManager.startUpdatingLocation();
        
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
            cell.lblStrasse.text="\(mauerlasche.id!)";
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

        

        //search();
        
        //demo search
        timer=NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("demoSearch") , userInfo: nil, repeats: false);
        
    }
    
    func demoSearch(){
        var allSearchResults=DemoData.getDemoData(isLeuchtenEnabled: isLeuchtenEnabled,isMauerlaschenEnabled: isMauerlaschenEnabled,isleitungenEnabled: isleitungenEnabled);
        //        searchResults=DemoDataMauerlaschen.getDemoMauerlaschen();
        var newSearchResults : [[GeoBaseEntity]] = [
            [Leuchte](),[Mauerlasche](),[Leitung]()
        ];
        var i=0;
        for entityClass in allSearchResults{
            var goodOnes = [GeoBaseEntity]();
            
            for entity in entityClass {
                if entity.liesIn(mapView.region) {
                    newSearchResults[i].append(entity)
                }
            }
            println(i);
            i++;
            
        }
        searchResults=newSearchResults;
        
        self.tableView.reloadData();
        
        for entityClass in searchResults{
            for entity in entityClass {
                
                entity.addToMapView(mapView);
                
            }
        }
        actInd.stopAnimating();
        actInd.removeFromSuperview();
        


    }
    
    func search(){
        
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

        
//        var sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
//        sessionConfig.HTTPAdditionalHeaders = ["Accept" : "application/json"]
//        var session = NSURLSession(configuration: sessionConfig)
//        var task = session.dataTaskWithURL(url, completionHandler: {
//            (data, response, error) in
//            var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: nil) as? Dictionary<String, AnyObject>
//            var tweet = json[„text“] ...
//        })
//        task.resume();
        
//        let baseUrl=NSURL(string:"http://kif:8890/");
//        let objectManager = RKObjectManager(baseURL: baseUrl);
//        AFNetworkActivityIndicatorManager.sharedManager().enabled=true;
//        
//        
//        var formData=MultiPartForm(params: QueryParameters(list: [
//            QueryParam(key: "LeuchteEnabled", value: "true"),
//            QueryParam(key: "GeometryFromWkt", value: "POLYGON ((2582375.3331009173 5681538.290594944, 2582494.6975608254 5681538.290594944, 2582494.6975608254 5681583.652933975, 2582375.3331009173 5681583.652933975, 2582375.3331009173 5681538.290594944))"),
//            QueryParam(key: "LeuchteEnabled", value: "true"),
//            ]));
//        
//        var paramMapping=RKObjectMapping(forClass: QueryParam.self);
//        paramMapping.addAttributeMappingsFromDictionary([
//            "key":"key",
//            "value":"value"
//            ]);
//        
//        var paramsMapping=RKObjectMapping(forClass: QueryParameters.self);
////        paramsMapping.a
//  
//        var manager = RKObjectManager();
//
//        var json = "{\"key\":\"LeuchteEnabled\",\"value\":\"true\"}";
//        var fillInto = QueryParam();
//        
//        RKMapperOperation.in
//        
//        
//        var op = RKMapperOperation(representation: json, mappingsDictionary: );
//        
//        op.targetObject=fillInto;
//        var error=NSErrorPointer();
//        op.execute(error);
//        println(op.representation);
//        println(fillInto.key);
        
    
    }
        
}
