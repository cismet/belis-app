//
//  Arbeitsprotokoll.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper
import MGSwipeTableCell


class Arbeitsprotokoll : GeoBaseEntity, CellInformationProviderProtocol, CellDataProvider, RightSwipeActionProvider {
    var material: String?
    var monteur: String?
    var bemerkung: String?
    var defekt: String?
    var datum: NSDate?
    var status: Status?
    var veranlassungsnummer: String?
    var protokollnummer: Int?
    
    
    var standort: Standort?
    var mauerlasche: Mauerlasche?
    var leuchte: Leuchte?
    var leitung: Leitung?
    var abzweigdose: Abzweigdose?
    var schaltstelle: Schaltstelle?
    var standaloneGeom: StandaloneGeom?
    var detailObjekt:String?
    var attachedGeoBaseEntity: GeoBaseEntity?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        material <- map["material"]
        monteur <- map["monteur"]
        bemerkung <- map["bemerkung"]
        defekt <- map["defekt"]
        datum <- (map["datum"], DateTransformFromString(format: "yyyy-MM-dd"))
        status <- map["fk_status"]
        veranlassungsnummer <- map["veranlassungsnummer"]
        protokollnummer <- map["protokollnummer"]

        mauerlasche <- map["protokollnummer"]

        standort <- map["fk_standort"]
        leuchte <- map["fk_leuchte"]
        leitung <- map["fk_leitung"]
        abzweigdose <- map["fk_abzweigdose"]
        schaltstelle <- map["fk_schaltstelle"]
        standaloneGeom <- map["fk_geometrie"]
        
        
        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        //es ist nur ein slot gefüllt
        if let gbe=standort {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Standort"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=leuchte {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Leuchte"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=leitung {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Leitung"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=abzweigdose {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Abzweigdose"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=schaltstelle {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Schaltstelle"
            attachedGeoBaseEntity=gbe
        }
        else if let gbe=standaloneGeom {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Freie Geometrie"
            attachedGeoBaseEntity=gbe
        }
       
    }

    override func getType() -> Entity {
        return Entity.PROTOKOLLE
    }
    
    // MARK: - CellInformationProviderProtocol
    
    func getMainTitle() -> String{
        var nr="?"
        if let n=protokollnummer {
            nr="\(n)"
        }
        return "#\(nr) - \(attachedGeoBaseEntity?.getAnnotationTitle() ?? "")"
    }
    func getSubTitle() -> String{
        if let vnr = veranlassungsnummer {
            if let veranlassung=CidsConnector.sharedInstance().veranlassungsCache[vnr]{
                if let vbez=veranlassung.bezeichnung {
                    return "\(vbez)"
                }
                else {
                    return "V\(vnr)"
                }
            }
        }
        return "ohne Veranlassung"
    }
    func getTertiaryInfo() -> String{
        if let st=status?.bezeichnung{
            return st
        }
        else {
            return ""
        }
        
    }
    func getQuaternaryInfo() -> String{
        return ""
    }
    
    @objc func getTitle() -> String {
        return "Protokoll"
    }
    
    @objc func getDetailGlyphIconString() -> String {
        return "icon-switch"
    }

    
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        var nr="?"
        if let n=protokollnummer {
            nr="\(n)"
        }
        data["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Nummer",dataLeft: nr,titleRight: "Fachobjekt",dataRight: attachedGeoBaseEntity?.getAnnotationTitle() ?? "-"))
        if let vnr = veranlassungsnummer {
            if let veranlassung=CidsConnector.sharedInstance().veranlassungsCache[vnr]{
                let veranlassungDetails: [String: [CellData]] = veranlassung.getAllData()
                let veranlassungSections = veranlassung.getDataSectionKeys()
                data["main"]?.append(SingleTitledInfoCellDataWithDetails(title: "Veranlassung",data: veranlassungsnummer ?? "ohne Veranlassung", details: veranlassungDetails, sections: veranlassungSections))
            }
        }
        
        data["Details"]=[]
        data["Details"]?.append(DoubleTitledInfoCellData(titleLeft: "Monteur", dataLeft: monteur ?? "-", titleRight: "Datum", dataRight: datum?.toDateString() ?? "-"))
        data["Details"]?.append(SingleTitledInfoCellData(title: "Status",data: status?.bezeichnung ?? "-"))
        data["Details"]?.append(MemoTitledInfoCellData(title: "Bemerkung",data: bemerkung ?? ""))
        data["Details"]?.append(MemoTitledInfoCellData(title: "Material",data: material ?? ""))
        data["DeveloperInfo"]=[]
        data["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))
        return data
    }
    @objc func getDataSectionKeys() -> [String] {
        return ["main","Details","DeveloperInfo"]
    }
    
    
    
    //Kartendarstellung
    override func getAnnotationImageName() -> String{
        if let gbe=attachedGeoBaseEntity {
            return gbe.getAnnotationImageName()
        }
        return "leuchte.png";
    }
    
    override func getAnnotationTitle() -> String{
        if let gbe=attachedGeoBaseEntity {
            return gbe.getAnnotationTitle()
        }
        return getMainTitle();
    }
    
    override func canShowCallout() -> Bool{
        if let gbe=attachedGeoBaseEntity {
            return gbe.canShowCallout()
        }
        return true
    }
    override func getAnnotationCalloutGlyphIconName() -> String {
        if let gbe=attachedGeoBaseEntity {
            return gbe.getAnnotationCalloutGlyphIconName()
        }
        return "icon-ceilinglight"
    }
    
    func getRightSwipeActions() -> [MGSwipeButton] {
        let status=MGSwipeButton(title: "Status", backgroundColor: UIColor(red: 255.0/255.0, green: 107.0/255.0, blue: 107.0/255.0, alpha: 1.0) ,callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            if let mainVC=CidsConnector.sharedInstance().mainVC {
//                if let protDetailView = mainVC.storyboard?.instantiateViewControllerWithIdentifier("protDetails") as? ProtokollDetailViewController {
//                        mainVC.presentViewController(protDetailView, animated: true, completion: { () -> Void in
//                            
//                        })
//                    
//                }
            }
            
            return true
        })
        let actions=MGSwipeButton(title: "Aktionen", backgroundColor: UIColor(red: 78.0/255.0, green: 205.0/255.0, blue: 196.0/255.0, alpha: 1.0) ,callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            if let mainVC=CidsConnector.sharedInstance().mainVC {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                alertController.addAction(UIAlertAction(title: "Leuchtenerneuerung", style: .Default, handler: { alertAction in
                    // Handle Take Photo here
                }))
                alertController.addAction(UIAlertAction(title: "Leuchtmittelwechsel (mit EP)", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))
                alertController.addAction(UIAlertAction(title: "Leuchtmittelwechsel", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))
                alertController.addAction(UIAlertAction(title: "Rundsteuerempfängerwechsel", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))
                alertController.addAction(UIAlertAction(title: "Sonderturnus", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))
                alertController.addAction(UIAlertAction(title: "Vorschaltgerätwechsel", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))
                alertController.addAction(UIAlertAction(title: "Sonstiges", style: .Default, handler: { alertAction in
                    // Handle Choose Existing Photo
                }))

                alertController.modalPresentationStyle = .Popover
                
                let popover = alertController.popoverPresentationController!
                popover.permittedArrowDirections = .Up
                popover.sourceView = sender
                popover.sourceRect = sender.bounds
                
                mainVC.presentViewController(alertController, animated: true, completion: nil)
            }
            
            return true
        })
        return [status,actions]
    }
    
}

class Status: BaseEntity {
    var bezeichnung: String?
    var schluessel: String?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"];
        schluessel <- map["schluessel"];
    }
}

class StandaloneGeom: GeoBaseEntity {
    var dokumente: [DMSUrl] = []
    var bezeichnung: String?
    
    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"];
        dokumente <- map["ar_dokumente"];
        wgs84WKT <- map["fk_geom.wgs84_wkt"]
    }

    
}