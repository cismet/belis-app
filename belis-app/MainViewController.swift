
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
import MGSwipeTableCell
import JGProgressHUD

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate, MGSwipeTableCellDelegate {
    
    @IBOutlet weak var mapView: MKMapView!;
    @IBOutlet weak var tableView: UITableView!;
    @IBOutlet weak var mapTypeSegmentedControl: UISegmentedControl!;
    @IBOutlet weak var mapToolbar: UIToolbar!;
    @IBOutlet weak var focusToggle: UISwitch!
    @IBOutlet weak var textfieldGeoSearch: UITextField!
    @IBOutlet weak var brightenToggle: UISwitch!
    @IBOutlet weak var itemArbeitsauftrag: UIBarButtonItem!
    @IBOutlet weak var bbiMoreFunctionality: UIBarButtonItem!
    @IBOutlet weak var bbiZoomToAllObjects: UIBarButtonItem!
    
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
    var timer = Timer();
    
    let progressHUD = JGProgressHUD(style: JGProgressHUDStyle.dark)
    
    
    var gotoUserLocationButton:MKUserTrackingBarButtonItem!;
    var locationManager: CLLocationManager!
    
    let focusRectShape = CAShapeLayer()
    static let IMAGE_PICKER=UIImagePickerController()
    var brightOverlay=MyBrightOverlay()
    var shownDetails:DetailVC?
    
    
    //MARK: Standard VC functions
    override func viewDidLoad() {
        super.viewDidLoad();
        CidsConnector.sharedInstance().mainVC=self
        
        locationManager=CLLocationManager();
        
        locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        
        locationManager.distanceFilter=100.0;
        locationManager.startUpdatingLocation();
        locationManager.requestWhenInUseAuthorization()
        
        gotoUserLocationButton=MKUserTrackingBarButtonItem(mapView:mapView);
        
        mapToolbar.items!.insert(gotoUserLocationButton,at:0 );
        
        //delegate stuff
        locationManager.delegate=self;
        mapView.delegate=self;
        tableView.delegate=self;
        
        
        //var tileOverlay = MyOSMMKTileOverlay()
        //        mapView.addOverlay(tileOverlay);
        
        
        let lat: CLLocationDegrees = 51.2751340785898
        let lng: CLLocationDegrees = 7.21241877946317
        let initLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, lng)
        
        mapView.isRotateEnabled=false;
        mapView.isZoomEnabled=true;
        mapView.showsBuildings=true;
        
        mapView.setCenter(initLocation, animated: true);
        mapView.camera.altitude = 50;
        
        focusRectShape.opacity = 0.4
        focusRectShape.lineWidth = 2
        focusRectShape.lineJoin = kCALineJoinMiter
        focusRectShape.strokeColor = UIColor(red: 0.29, green: 0.53, blue: 0.53, alpha: 1).cgColor
        focusRectShape.fillColor = UIColor(red: 0.51, green: 0.76, blue: 0.6, alpha: 1).cgColor
        
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainViewController.mapTapped(_:)))
        mapView.addGestureRecognizer(tapGestureRecognizer)
        
        //UINavigationController(rootViewController: self)
        textfieldGeoSearch.delegate=self
        bbiMoreFunctionality.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: GlyphTools.glyphFontName, size: 16)!],
            for: UIControlState())
        bbiMoreFunctionality.title=WebHostingGlyps.glyphs["icon-chevron-down"]
        bbiZoomToAllObjects.setTitleTextAttributes([
            NSFontAttributeName : UIFont(name: GlyphTools.glyphFontName, size: 20)!],
            for: UIControlState())
        bbiZoomToAllObjects.title=WebHostingGlyps.glyphs["icon-world"]
        print(UIDevice.current.identifierForVendor!.uuidString)
        
        
        if let _=CidsConnector.sharedInstance().selectedTeam {
            //            let alert = UIAlertView()
            //            alert.title = "Ausgewähltes Team"
            //            alert.message = "\(t.name ?? "???")"
            //            alert.addButtonWithTitle("Ok")
            //            alert.show()
        }
        else {
            let alert = UIAlertView()
            alert.title = "Kein Team ausgewählt"
            alert.message = "Ohne ausgewähltes Team können Sie keine Arbeitsaufträge aufrufen."
            alert.addButton(withTitle: "Ok")
            alert.show()
        }
        
        itemArbeitsauftrag.title="Kein Arbeitsauftrag ausgewählt (\(CidsConnector.sharedInstance().selectedTeam?.name ?? "-"))"
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "showSearchSelectionPopover") {
            let selectionVC = segue.destination as! SelectionPopoverViewController
            selectionVC.mainVC=self;
        }
        else if (segue.identifier == "showAdditionalFunctionalityPopover") {
            let additionalFuncVC = segue.destination as! AdditionalFunctionalityPopoverViewController
            additionalFuncVC.mainVC=self;
        }
        
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        focusRectShape.removeFromSuperlayer()
        coordinator.animate(alongsideTransition: nil, completion: { context in
            if UIDevice.current.orientation.isLandscape {
                print("landscape")
            } else {
                print("portraight")
            }
            self.ensureFocusRectangleIsDisplayedWhenAndWhereItShould()
        })
        
    }
    
    //MARK: UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CidsConnector.sharedInstance().searchResults[Entity.byIndex(section)]?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCell = tableView.dequeueReusableCell(withIdentifier: "firstCellPrototype")as! TableViewCell
        //        var cellInfoProvider: CellInformationProviderProtocol = NoCellInformation()
        cell.baseEntity=CidsConnector.sharedInstance().searchResults[Entity.byIndex((indexPath as NSIndexPath).section)]?[(indexPath as NSIndexPath).row]
        
        if let obj=cell.baseEntity {
            if let cellInfoProvider=obj as? CellInformationProviderProtocol {
                cell.lblBezeichnung.text=cellInfoProvider.getMainTitle()
                cell.lblStrasse.text=cellInfoProvider.getTertiaryInfo()
                cell.lblSubText.text=cellInfoProvider.getSubTitle()
                cell.lblZusatzinfo.text=cellInfoProvider.getQuaternaryInfo()
            }
        }
        cell.delegate=self
        
        if let left=cell.baseEntity as? LeftSwipeActionProvider {
            cell.leftButtons=left.getLeftSwipeActions()
        }
        else {
            cell.leftButtons=[]
        }
        if let right=cell.baseEntity as? RightSwipeActionProvider {
            cell.rightButtons=right.getRightSwipeActions()
        }
        else {
            cell.rightButtons=[]
        }
        
        
        
        //let fav=MGSwipeButton(title: "Fav", backgroundColor: UIColor.blueColor())
        
        
        cell.leftSwipeSettings.transition = MGSwipeTransition.static
        
        //configure right buttons
        
        //        let delete=MGSwipeButton(title: "Delete", backgroundColor: UIColor.redColor())
        //        let more=MGSwipeButton(title: "More",backgroundColor: UIColor.lightGrayColor())
        //
        //        cell.rightButtons = [delete,more]
        //        cell.rightSwipeSettings.transition =  MGSwipeTransition.Static
        
        cell.leftExpansion.threshold=1.5
        cell.leftExpansion.fillOnTrigger=true
        //cell.leftExpansion.buttonIndex=0
        
        
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return Entity.allValues.count
    }
    func swipeTableCell(_ cell: MGSwipeTableCell!, shouldHideSwipeOnTap point: CGPoint) -> Bool {
        return true
    }
    func swipeTableCellWillBeginSwiping(_ cell: MGSwipeTableCell!) {
        if let myTableViewCell=cell as? TableViewCell, let gbe=myTableViewCell.baseEntity as? GeoBaseEntity {
            self.selectOnMap(gbe)
            self.selectInTable(gbe, scrollToShow: false)
        }
    }
    
    
    //MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        print("didSelectRowAtIndexPath")
        if let obj=CidsConnector.sharedInstance().searchResults[Entity.byIndex((indexPath as NSIndexPath).section)]?[(indexPath as NSIndexPath).row] {
            selectOnMap(obj)
            //          lastSelection=obj
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let array=CidsConnector.sharedInstance().searchResults[Entity.byIndex(section)]{
            if (array.count>0){
                return 25
            }
        }
        return 0.0
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title=Entity.byIndex(section).rawValue
        if let array=CidsConnector.sharedInstance().searchResults[Entity.byIndex(section)]{
            return title + " \(array.count)"
        }
        else {
            return title
            
        }
    }
    
    // MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
    }
    
    // MARK: NKMapViewDelegates
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
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
        else if let polygon = overlay as? GeoBaseEntityStyledMkPolygonAnnotation {
            let polygonRenderer = MKPolygonRenderer(overlay: polygon)
            
            if let styler = polygon.getGeoBaseEntity() as? PolygonStyler {
                polygonRenderer.strokeColor =  styler.getStrokeColor()
                polygonRenderer.lineWidth = styler.getLineWidth()
                polygonRenderer.fillColor=styler.getFillColor()
            }else {
                polygonRenderer.strokeColor =  PolygonStylerConstants.strokeColor
                polygonRenderer.lineWidth = PolygonStylerConstants.lineWidth
                polygonRenderer.fillColor=PolygonStylerConstants.fillColor
            }
            
            return polygonRenderer
            
        }
        else if (overlay is MyBrightOverlay){
            let renderer =  MyBrightOverlayRenderer(tileOverlay: overlay as! MKTileOverlay);
            return renderer;
        }
        return MKOverlayRenderer()
        
    }
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        //        println(mapView.region.span.latitudeDelta);
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is GeoBaseEntityPointAnnotation){
            let gbePA=annotation as! GeoBaseEntityPointAnnotation;
            let reuseId = "belisAnnotation"
            
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: gbePA, reuseIdentifier: reuseId)
                
            }
            else {
                anView!.annotation = gbePA
            }
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            
            anView!.canShowCallout = gbePA.shouldShowCallout;
            anView!.image = gbePA.annotationImage

            
            if let label=GlyphTools.sharedInstance().getGlyphedLabel(gbePA.glyphName) {
                label.textColor=UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
                anView!.leftCalloutAccessoryView=label
            }
            
            
            if let btn=GlyphTools.sharedInstance().getGlyphedButton("icon-chevron-right"){
                btn.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), for: UIControlState())
                anView!.rightCalloutAccessoryView=btn
            }
            anView!.alpha=0.9
            return anView
        } else if (annotation is GeoBaseEntityStyledMkPolylineAnnotation){
            let gbeSMKPA=annotation as! GeoBaseEntityStyledMkPolylineAnnotation;
            let reuseId = "belisAnnotation"
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: gbeSMKPA, reuseIdentifier: reuseId)
                
            }
            else {
                anView!.annotation = gbeSMKPA
            }
            
            if let label=GlyphTools.sharedInstance().getGlyphedLabel(gbeSMKPA.glyphName) {
                label.textColor=UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
                anView!.leftCalloutAccessoryView=label
            }
            if let btn=GlyphTools.sharedInstance().getGlyphedButton("icon-chevron-right"){
                btn.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), for: UIControlState())
                anView!.rightCalloutAccessoryView=btn
            }
            
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            anView!.image = gbeSMKPA.annotationImage;
            anView!.canShowCallout = gbeSMKPA.shouldShowCallout;
            anView!.alpha=0.9
            return anView
            
        } else if (annotation is GeoBaseEntityStyledMkPolygonAnnotation){
            let gbeSPGA=annotation as! GeoBaseEntityStyledMkPolygonAnnotation;
            let reuseId = "belisAnnotation"
            var anView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if anView == nil {
                anView = MKAnnotationView(annotation: gbeSPGA, reuseIdentifier: reuseId)
                
            }
            else {
                anView!.annotation = gbeSPGA
            }
            
            if let label=GlyphTools.sharedInstance().getGlyphedLabel(gbeSPGA.glyphName) {
                label.textColor=UIColor(red: 0.0, green: 0.48, blue: 1.0, alpha: 1.0)
                anView!.leftCalloutAccessoryView=label
            }
            if let btn=GlyphTools.sharedInstance().getGlyphedButton("icon-chevron-right"){
                btn.setTitleColor(UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), for: UIControlState())
                anView!.rightCalloutAccessoryView=btn
            }
            
            //Set annotation-specific properties **AFTER**
            //the view is dequeued or created...
            anView!.image = gbeSPGA.annotationImage;
            anView!.canShowCallout = gbeSPGA.shouldShowCallout;
            anView!.alpha=0.9
            return anView
            
        }
        
        
        
        return nil;
    }
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        print("didChangeUserTrackingMode")
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        delayed(0.0)
            {
                if !view.annotation!.isKind(of: MatchingSearchItemsAnnotations.self) {
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
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        delayed(0.0)
            {
                if view.annotation === self.selectedAnnotation {
                    if let selAnno=self.selectedAnnotation {
                        mapView.selectAnnotation(selAnno, animated: false)
                    }
                }
                
        }
        print("didDeselectAnnotationView >> \(view.annotation!.title)")
    }
    
    //MARK: - IBActions
    @IBAction func searchButtonTabbed(_ sender: AnyObject) {
        removeAllEntityObjects()
        
        self.tableView.reloadData();
        
        showWaitingHUD(text:"Objektsuche")
        var mRect : MKMapRect
        if focusToggle.isOn {
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
            
            assert(!Thread.isMainThread )
            DispatchQueue.main.async {
                CidsConnector.sharedInstance().sortSearchResults()
                self.tableView.reloadData();
                
                for (_, objArray) in CidsConnector.sharedInstance().searchResults{
                    for obj in objArray {
                        
                        obj.addToMapView(self.mapView);
                        
                    }
                }
                hideWaitingHUD()
            }
        }
        
    }
    @IBAction func itemArbeitsauftragTapped(_ sender: AnyObject) {
        if let gbe=CidsConnector.sharedInstance().selectedArbeitsauftrag {
            let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
            shownDetails=detailVC
            let cellDataProvider=gbe as CellDataProvider
            detailVC.sections=cellDataProvider.getDataSectionKeys()
            detailVC.setCellData(cellDataProvider.getAllData())
            detailVC.objectToShow=gbe
            detailVC.title=cellDataProvider.getTitle()
            
            let icon=UIBarButtonItem()
            icon.action=#selector(MainViewController.back(_:))
            //icon.image=getGlyphedImage("icon-chevron-left")
            icon.image=GlyphTools.sharedInstance().getGlyphedImage("icon-chevron-left", fontsize: 11, size: CGSize(width: 14, height: 14))
            detailVC.navigationItem.leftBarButtonItem = icon
            
            let detailNC=UINavigationController(rootViewController: detailVC)
            selectedAnnotation=nil
            
            let popC=UIPopoverController(contentViewController: detailNC)
            popC.present(from: itemArbeitsauftrag, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
        else if let indexPath=tableView.indexPathForSelectedRow , let aa = CidsConnector.sharedInstance().searchResults[Entity.byIndex((indexPath as NSIndexPath).section)]?[(indexPath as NSIndexPath).row] as? Arbeitsauftrag {
            selectArbeitsauftrag(aa)
        }
        
        
        
    }
    @IBAction func mapTypeButtonTabbed(_ sender: AnyObject) {
        switch(mapTypeSegmentedControl.selectedSegmentIndex){
            
        case 0:
            mapView.mapType=MKMapType.standard;
        case 1:
            mapView.mapType=MKMapType.hybrid;
        case 2:
            mapView.mapType=MKMapType.satellite;
        default:
            mapView.mapType=MKMapType.standard;
        }
        
    }
    @IBAction func lookUpButtonTabbed(_ sender: AnyObject) {
        if let team = CidsConnector.sharedInstance().selectedTeam {
            selectArbeitsauftrag(nil,showActivityIndicator: false)
            removeAllEntityObjects()
            showWaitingHUD(text:"Arbeitsaufträge suchen")
            CidsConnector.sharedInstance().searchArbeitsauftraegeForTeam(team) { () -> () in
                DispatchQueue.main.async {
                    CidsConnector.sharedInstance().sortSearchResults()
                    self.tableView.reloadData();
                    var annos: [MKAnnotation]=[]
                    
                    for (_, objArray) in CidsConnector.sharedInstance().searchResults{
                        for obj in objArray {
                            obj.addToMapView(self.mapView);
                            if let anno=obj.mapObject as? MKAnnotation {
                                annos.append(anno)
                            }
                        }
                    }
                    
                    hideWaitingHUD(delayedText: "Veranlassungen werden im\nHintergrund nachgeladen", delay: 1)
                    
                    DispatchQueue.main.async {
                        self.zoomToFitMapAnnotations(annos)
                    }
                }
            }
        }
        else {
            let alert = UIAlertView()
            alert.title = "Kein Team ausgewählt"
            alert.message = "Bitte wählen Sie zuerst ein Team aus"
            alert.addButton(withTitle: "Ok")
            alert.show()
        }
        
        
    }
    @IBAction func focusItemTabbed(_ sender: AnyObject) {
        focusToggle.setOn(!focusToggle.isOn, animated: true)
        focusToggleValueChanged(self)
    }
    @IBAction func focusToggleValueChanged(_ sender: AnyObject) {
        ensureFocusRectangleIsDisplayedWhenAndWhereItShould()
    }
    @IBAction func brightenItemTabbed(_ sender: AnyObject) {
        brightenToggle.setOn(!brightenToggle.isOn, animated: true)
        brightenToggleValueChanged(self)
    }
    @IBAction func brightenToggleValueChanged(_ sender: AnyObject) {
        ensureBrightOverlayIsDisplayedWhenItShould()
    }
    @IBAction func geoSearchButtonTabbed(_ sender: AnyObject) {
        if textfieldGeoSearch.text! != "" {
            geoSearch()
        }
    }
    @IBAction func geoSearchInputDidEnd(_ sender: AnyObject) {
        geoSearch()
    }
    @IBAction func zoomToAllObjectsTapped(_ sender: AnyObject) {
        var annos: [MKAnnotation]=[]
        for (_, objArray) in CidsConnector.sharedInstance().searchResults{
            for obj in objArray {
                if let anno=obj.mapObject as? MKAnnotation {
                    annos.append(anno)
                }
            }
        }
        DispatchQueue.main.async {
            self.zoomToFitMapAnnotations(annos)
        }
    }
    // MARK: - Selector functions
    func back(_ sender: UIBarButtonItem) {
        if let details=shownDetails{
            details.dismiss(animated: true, completion:
                { () -> Void in
                    CidsConnector.sharedInstance().selectedArbeitsauftrag=nil
                    self.selectArbeitsauftrag(nil)
                    self.shownDetails=nil
                    
            })
        }
    }
    
    func createFocusRect() -> MKMapRect {
        let mRect = self.mapView.visibleMapRect;
        let newSize = MKMapSize(width: mRect.size.width/3,height: mRect.size.height/3)
        let newOrigin = MKMapPoint(x: mRect.origin.x+newSize.width, y: mRect.origin.y+newSize.height)
        return MKMapRect(origin: newOrigin,size: newSize)
    }
    func zoomToFitMapAnnotations(_ annos: [MKAnnotation]) {
        if annos.count == 0 {return}
        
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        
        for annotation in annos {
            if let poly=annotation as? MKMultiPoint {
                let points=poly.points()
                for i in  0 ... poly.pointCount-1 { //last point is jwd (dono why)
                    let coord = MKCoordinateForMapPoint(points[i])
                    //print("CO: \(coord.longitude),\(coord.latitude)")
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, coord.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, coord.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, coord.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, coord.latitude)
                    //print("TL: \(topLeftCoordinate.longitude),\(topLeftCoordinate.latitude)")
                    //belis selprint("BR: \(bottomRightCoordinate.longitude),\(bottomRightCoordinate.latitude)")
                    
                }
                
            }
            else {
                
                topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
            }
            
        }
        
        let center = CLLocationCoordinate2D(latitude: topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.5, longitude: topLeftCoordinate.longitude - (topLeftCoordinate.longitude - bottomRightCoordinate.longitude) * 0.5)
        
        // Add a little extra space on the sides
        let span = MKCoordinateSpanMake(fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 1.3, fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 1.3)
        
        var region = MKCoordinateRegion(center: center, span: span)
        
        
        region = self.mapView.regionThatFits(region)
        
        self.mapView.setRegion(region, animated: true)
        
    }
    func selectArbeitsauftrag(_ arbeitsauftrag: Arbeitsauftrag?, showActivityIndicator: Bool = true) {
        let sel=selectedAnnotation
        selectedAnnotation=nil
        if let s=sel {
            mapView.deselectAnnotation(s, animated: false)
        }
        CidsConnector.sharedInstance().selectedArbeitsauftrag=arbeitsauftrag
        if showActivityIndicator {
            showWaitingHUD()
        }
        let overlays=self.mapView.overlays
        self.mapView.removeOverlays(overlays)
        for anno in self.mapView.selectedAnnotations {
            self.mapView.deselectAnnotation(anno, animated: false)
        }
        var zoomToShowAll=true
        if let aa=arbeitsauftrag {
            CidsConnector.sharedInstance().allArbeitsauftraegeBeforeCurrentSelection=CidsConnector.sharedInstance().searchResults
            fillArbeitsauftragIntoTable(aa)
        } else {
            itemArbeitsauftrag.title="Kein Arbeitsauftrag ausgewählt (\(CidsConnector.sharedInstance().selectedTeam?.name ?? "-"))"
            self.removeAllEntityObjects()
            CidsConnector.sharedInstance().searchResults=CidsConnector.sharedInstance().allArbeitsauftraegeBeforeCurrentSelection
            
            zoomToShowAll=false
            
        }
        visualizeAllSearchResultsInMap(zoomToShowAll: zoomToShowAll, showActivityIndicator: showActivityIndicator)
        
        
    }
    func fillArbeitsauftragIntoTable(_ arbeitsauftrag: Arbeitsauftrag) {
        removeAllEntityObjects()
        
        itemArbeitsauftrag.title="\(arbeitsauftrag.nummer!) (\(CidsConnector.sharedInstance().selectedTeam?.name ?? "-"))"
        
        
        if let protokolle=arbeitsauftrag.protokolle {
            for prot in protokolle {
                if let _=CidsConnector.sharedInstance().searchResults[Entity.PROTOKOLLE] {
                    CidsConnector.sharedInstance().searchResults[Entity.PROTOKOLLE]!.append(prot)
                }
                else {
                    CidsConnector.sharedInstance().searchResults.updateValue([prot], forKey: Entity.PROTOKOLLE)
                }
            }
        }
    }
    
    func visualizeAllSearchResultsInMap(zoomToShowAll: Bool,showActivityIndicator:Bool ) {
        func doIt(){
            self.selectedAnnotation=nil
            self.mapView.deselectAnnotation(selectedAnnotation, animated: false)
            
            var annos: [MKAnnotation]=[]
            for (_, objArray) in CidsConnector.sharedInstance().searchResults{
                for obj in objArray {
                    obj.addToMapView(self.mapView);
                    if let anno=obj.mapObject as? MKAnnotation {
                        annos.append(anno)
                    }
                }
            }
            if zoomToShowAll {
                self.zoomToFitMapAnnotations(annos)
                
            }
            if showActivityIndicator {
                hideWaitingHUD()
            }
        }
        if Thread.isMainThread {
            doIt()
        }
        else {
            DispatchQueue.main.async {
                doIt()
            }
        }
    }
    
    // MARK: - public functions
    func mapTapped(_ sender: UITapGestureRecognizer) {
        let touchPt = sender.location(in: mapView)
        
        //let hittedUI = mapView.hitTest(touchPt, withEvent: nil)
        //        println(hittedUI)
        print("mapTabbed")
        
        
        let buffer=CGFloat(22)
        
        var foundPolyline: GeoBaseEntityStyledMkPolylineAnnotation?
        var foundPoint: GeoBaseEntityPointAnnotation?
        var foundPolygon: GeoBaseEntityStyledMkPolygonAnnotation?
        
        
        
        
        
        for anno: AnyObject in mapView.annotations {
            if let pointAnnotation = anno as? GeoBaseEntityPointAnnotation {
                let cgPoint = mapView.convert(pointAnnotation.coordinate, toPointTo: mapView)
                let path  = CGMutablePath()
                path.move(to: cgPoint)
                path.addLine(to: cgPoint)
                
                let fuzzyPath=CGPath(__byStroking: path, transform: nil, lineWidth: buffer, lineCap: CGLineCap.round, lineJoin: CGLineJoin.round, miterLimit: 0.0)
                
                if (fuzzyPath?.contains(touchPt) == true) {
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
                    let path  = CGMutablePath()
                    for i in 0...lineAnnotation.pointCount-1 {
                        let mapPoint = lineAnnotation.points()[i]
                        
                        let cgPoint = mapView.convert(MKCoordinateForMapPoint(mapPoint), toPointTo: mapView)
                        if i==0 {
                            path.move(to: cgPoint)
                        }
                        else {
                            path.addLine(to: cgPoint);
                        }
                    }
                    let fuzzyPath=CGPath(__byStroking: path, transform: nil, lineWidth: buffer, lineCap: CGLineCap.round, lineJoin: CGLineJoin.round, miterLimit: 0.0)
                    if (fuzzyPath?.contains(touchPt) == true) {
                        foundPolyline = lineAnnotation
                        break
                    }
                }
                if let polygonAnnotation  = overlay as? GeoBaseEntityStyledMkPolygonAnnotation {
                    let path  = CGMutablePath()
                    for i in 0...polygonAnnotation.pointCount-1 {
                        let mapPoint = polygonAnnotation.points()[i]
                        
                        let cgPoint = mapView.convert(MKCoordinateForMapPoint(mapPoint), toPointTo: mapView)
                        if i==0 {
                            path.move(to: cgPoint)
                        }
                        else {
                            path.addLine(to: cgPoint)
                        }
                    }
                    if (path.contains(touchPt) == true ) {
                        foundPolygon=polygonAnnotation
                        break
                    }
                }
            }
            
            if let hitPolyline = foundPolyline {
                selectOnMap(hitPolyline.getGeoBaseEntity())
                selectInTable(hitPolyline.getGeoBaseEntity())
            }
            else if let hitPolygon=foundPolygon{
                selectOnMap(hitPolygon.getGeoBaseEntity())
                selectInTable(hitPolygon.getGeoBaseEntity())
            }
            else {
                selectOnMap(nil)
            }
        }
        
    }
    func selectOnMap(_ geoBaseEntityToSelect : GeoBaseEntity?){
        if  highlightedLine != nil {
            mapView.remove(highlightedLine!);
        }
        if (selectedAnnotation != nil){
            mapView.deselectAnnotation(selectedAnnotation, animated: false)
        }
        
        if let geoBaseEntity = geoBaseEntityToSelect{
            let mapObj=geoBaseEntity.mapObject
            
            if let mO=mapObj as? MKAnnotation {
                mapView.selectAnnotation(mO, animated: true);
                selectedAnnotation=mapObj as? MKAnnotation
            }
            
            if mapObj is GeoBaseEntityPointAnnotation {
                
                
            }
            else if mapObj is GeoBaseEntityStyledMkPolylineAnnotation {
                let line = mapObj as! GeoBaseEntityStyledMkPolylineAnnotation;
                highlightedLine = HighlightedMkPolyline(points: line.points(), count: line.pointCount);
                mapView.remove(line);
                mapView.add(highlightedLine!);
                mapView.add(line); //bring the highlightedLine below the line
                
            } else if mapObj is GeoBaseEntityStyledMkPolygonAnnotation {
                //let polygon=mapObj as! GeoBaseEntityStyledMkPolygonAnnotation
                //let annos=[polygon]
                //zoomToFitMapAnnotations(annos)
            }
        } else {
            selectedAnnotation=nil
        }
    }
    func selectInTable(_ geoBaseEntityToSelect : GeoBaseEntity?, scrollToShow: Bool=true){
        if let geoBaseEntity = geoBaseEntityToSelect{
            let entity=geoBaseEntity.getType()
            
            //need old fashioned loop for index
            for i in 0...CidsConnector.sharedInstance().searchResults[entity]!.count-1 {
                var results : [GeoBaseEntity] = CidsConnector.sharedInstance().searchResults[entity]!
                if results[i].id == geoBaseEntity.id {
                    if scrollToShow {
                        tableView.selectRow(at: IndexPath(row: i, section: entity.index()), animated: true, scrollPosition: UITableViewScrollPosition.top)
                    }
                    else {
                        tableView.selectRow(at: IndexPath(row: i, section: entity.index()), animated: true, scrollPosition: UITableViewScrollPosition.none)
                    }
                    break;
                }
            }
        }
    }
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        //var detailVC=LeuchtenDetailsViewController()
        //        var detailVC=storyboard!.instantiateViewControllerWithIdentifier("LeuchtenDetails") as UIViewController
        var geoBaseEntity: GeoBaseEntity?
        if let pointAnnotation = view.annotation as? GeoBaseEntityPointAnnotation {
            geoBaseEntity=pointAnnotation.geoBaseEntity
        }
        else if let lineAnnotation = view.annotation as? GeoBaseEntityStyledMkPolylineAnnotation {
            geoBaseEntity=lineAnnotation.geoBaseEntity
        }else if let polygonAnnotation = view.annotation as? GeoBaseEntityStyledMkPolygonAnnotation {
            geoBaseEntity=polygonAnnotation.geoBaseEntity
        }
        
        if let gbe = geoBaseEntity  {
            
            let detailVC=DetailVC(nibName: "DetailVC", bundle: nil)
            
            if let cellDataProvider=gbe as? CellDataProvider {
                detailVC.sections=cellDataProvider.getDataSectionKeys()
                detailVC.setCellData(cellDataProvider.getAllData())
                detailVC.objectToShow=gbe
                detailVC.title=cellDataProvider.getTitle()
                let icon=UIBarButtonItem()
                icon.image=GlyphTools.sharedInstance().getGlyphedImage(cellDataProvider.getDetailGlyphIconString())
                detailVC.navigationItem.leftBarButtonItem = icon
            }
            if let actionProvider=gbe as? ActionProvider {
                detailVC.actions=actionProvider.getAllActions()
                let action = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: detailVC, action:"moreAction")
                detailVC.navigationItem.rightBarButtonItem = action
            }
            
            let detailNC=UINavigationController(rootViewController: detailVC)
            selectedAnnotation=nil
            
            mapView.deselectAnnotation(view.annotation, animated: false)
            let popC=UIPopoverController(contentViewController: detailNC)
            popC.present(from: view.frame, in: mapView, permittedArrowDirections: UIPopoverArrowDirection.any, animated: true)
        }
    }
    func clearAll() {
        CidsConnector.sharedInstance().selectedArbeitsauftrag=nil
        CidsConnector.sharedInstance().allArbeitsauftraegeBeforeCurrentSelection=[Entity: [GeoBaseEntity]]()
        CidsConnector.sharedInstance().veranlassungsCache=[String:Veranlassung]()
        removeAllEntityObjects()
    }
    
    
    func removeAllEntityObjects(){
        for (_, entityArray) in CidsConnector.sharedInstance().searchResults{
            for obj in entityArray {
                DispatchQueue.main.async {
                    obj.removeFromMapView(self.mapView);
                }
            }
        }
        CidsConnector.sharedInstance().searchResults=[Entity: [GeoBaseEntity]]()
        DispatchQueue.main.async {
            self.tableView.reloadData();
        }
    }
    
    
    // MARK: - private funcs
    fileprivate func geoSearch(){
        if matchingSearchItems.count>0 {
            self.mapView.removeAnnotations(self.matchingSearchItemsAnnotations)
            self.matchingSearchItems.removeAll(keepingCapacity: false)
            matchingSearchItemsAnnotations.removeAll(keepingCapacity: false)
        }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = "Wuppertal, \(textfieldGeoSearch.text!)"
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        
        search.start(completionHandler: {(responseIn:
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
        } as! MKLocalSearchCompletionHandler)
        
    }
    fileprivate func ensureBrightOverlayIsDisplayedWhenItShould(){
        if brightenToggle.isOn {
            let overlays=mapView.overlays
            mapView.removeOverlays(overlays)
            mapView.add(brightOverlay)
            mapView.addOverlays(overlays)
        }
        else {
            mapView.remove(brightOverlay)
        }
    }
    fileprivate func ensureFocusRectangleIsDisplayedWhenAndWhereItShould(){
        focusRectShape.removeFromSuperlayer()
        if focusToggle.isOn {
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
            
            path.move(to: CGPoint(x: x1, y: y1))
            path.addLine(to: CGPoint(x: x2, y: y2))
            path.addLine(to: CGPoint(x: x3, y: y3))
            path.addLine(to: CGPoint(x: x4, y: y4))
            path.close()
            focusRectShape.path = path.cgPath
            mapView.layer.addSublayer(focusRectShape)
            
        }
        
    }
       
    //    func textFieldShouldReturn(textField: UITextField) -> Bool {
    //        self.view.endEditing(true)
    //        return false
    //    }
    
    
}
