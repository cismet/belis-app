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
import SwiftForms
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}



class Arbeitsprotokoll : GeoBaseEntity, CellInformationProviderProtocol, CellDataProvider, RightSwipeActionProvider {
    var material: String?
    var monteur: String?
    var bemerkung: String?
    var defekt: String?
    var datum: Date?
    var status: ArbeitsprotokollStatus?
    var veranlassungsnummer: String?
    var protokollnummer: Int?
    
    static var statusIcons: [String:String]=["0":"🕒","1":"✅","2":"❗️"]
    static var statusColors: [String:UIColor]=["0":UIColor(red: 253.0/255.0, green: 173.0/255.0, blue: 0.0/255.0, alpha: 1.0),
                                               "1":UIColor(red: 168.0/255.0, green: 202.0/255.0, blue: 39.0/255.0, alpha: 1.0),
                                               "2":UIColor(red: 247.0/255.0, green: 68.0/255.0, blue: 68.0/255.0, alpha: 1.0)]
    
    var standort: Standort?
    var mauerlasche: Mauerlasche?
    var leuchte: Leuchte?
    var leitung: Leitung?
    var abzweigdose: Abzweigdose?
    var schaltstelle: Schaltstelle?
    var standaloneGeom: StandaloneGeom?
    var detailObjekt:String?
    
    var aktionen: [ArbeitsprotokollAktion]=[]
    
    var attachedGeoBaseEntity: GeoBaseEntity?
    
    
    // MARK: - required init because of ObjectMapper
    required init?(map: Map) {
        super.init(map: map)
    }
    
    // MARK: - essential overrides GeoBaseEntity
    override func getAnnotationImage(_ status: String?) -> UIImage{
        if let gbe=attachedGeoBaseEntity {
            if let skey=self.status?.schluessel {
                return gbe.getAnnotationImage(skey)
            }
            else {
                return gbe.getAnnotationImage()
            }
        }
        return UIImage();
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
        return "icon-notestasks"
    }
    
    // MARK: - essential overrides BaseEntity
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
        aktionen <- map["n_aktionen"]
        
        standort <- map["fk_standort"]
        leuchte <- map["fk_leuchte"]
        mauerlasche <- map["fk_mauerlasche"]
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
        else if let gbe=mauerlasche {
            wgs84WKT=gbe.wgs84WKT
            detailObjekt="Mauerlasche"
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
    
    // MARK: - CellInformationProviderProtocol Impl
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
            else {
                return "Veranlassung wird geladen ..."
            }
        }
        else {
            return "ohne Veranlassung"
        }
        
    }
    func getTertiaryInfo() -> String{
        if let skey=status?.schluessel {
            if let icon=Arbeitsprotokoll.statusIcons[skey] {
                return icon
            }
        }
        
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
    
    // MARK: - CellDataProvider Impl
    @objc func getTitle() -> String {
        return "Protokoll"
    }
    @objc func getDetailGlyphIconString() -> String {
        return "icon-noteslist"
    }
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        var nr="?"
        if let n=protokollnummer {
            nr="\(n)"
        }
        data["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Nummer",dataLeft: nr,titleRight: "Fachobjekt",dataRight: attachedGeoBaseEntity?.getAnnotationTitle() ?? "-"))
        if (attachedGeoBaseEntity != nil && detailObjekt != nil) {
            data["main"]?.append(SimpleInfoCellDataWithDetailsDrivenByWholeObject(data: detailObjekt!,detailObject: attachedGeoBaseEntity!, showSubActions: true))
        }
        if let vnr = veranlassungsnummer {
            if let veranlassung=CidsConnector.sharedInstance().veranlassungsCache[vnr]{
                let veranlassungDetails: [String: [CellData]] = veranlassung.getAllData()
                let veranlassungSections = veranlassung.getDataSectionKeys()
                data["main"]?.append(SingleTitledInfoCellDataWithDetails(title: "Veranlassung",data: veranlassungsnummer ?? "ohne Veranlassung", details: veranlassungDetails, sections: veranlassungSections))
            }
        }
        
        if monteur != nil || status != nil || bemerkung != nil || material != nil || datum != nil {
            data["Details"]=[]
            if datum != nil || monteur != nil {
                data["Details"]?.append(DoubleTitledInfoCellData(titleLeft: "Monteur", dataLeft: monteur ?? "-", titleRight: "Datum", dataRight: datum?.toDateString() ?? "-"))
            }
            if let s=status {
                data["Details"]?.append(SingleTitledInfoCellData(title: "Status",data: s.bezeichnung ?? "-"))
            }
            if let bem=bemerkung {
                data["Details"]?.append(MemoTitledInfoCellData(title: "Bemerkung",data: bem))
            }
            if let mat=material {
                data["Details"]?.append(MemoTitledInfoCellData(title: "Material",data: mat))
            }
            
        }
        
        
        if aktionen.count>0 {
            data["Aktionen"]=[]
        }
        for aktion in aktionen {
            if let aktionstitle=aktion.aenderung {
                if let von=aktion.alt, let nach=aktion.neu {
                    var aktionDetails: [String: [CellData]] = ["main":[]]
                    aktionDetails["main"]?.append(SimpleInfoCellData(data: aktionstitle))
                    aktionDetails["main"]?.append(SingleTitledInfoCellData(title: "von",data: von))
                    aktionDetails["main"]?.append(SingleTitledInfoCellData(title: "nach",data: nach))
                    data["Aktionen"]?.append(SingleTitledInfoCellDataWithDetails(title: aktionstitle,data: nach,details: aktionDetails,sections: ["main"]))
                    
                }
                else if let von=aktion.alt{
                    data["Aktionen"]?.append(SingleTitledInfoCellData(title: aktionstitle,data: von))
                }
                else if let nach=aktion.neu{
                    data["Aktionen"]?.append(SingleTitledInfoCellData(title: aktionstitle,data: nach))
                }
                else {
                    data["Aktionen"]?.append(SingleTitledInfoCellData(title: aktionstitle,data: "-"))
                }
            }
        }
        
        data["DeveloperInfo"]=[]
        data["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))
        return data
    }
    @objc func getDataSectionKeys() -> [String] {
        return ["main","Details","Aktionen","DeveloperInfo"]
    }
    
    // MARK: - RightSwipeActionProvider Impl
    func getRightSwipeActions() -> [MGSwipeButton] {
        let status=MGSwipeButton(title: "Status", backgroundColor: UIColor(red: 255.0/255.0, green: 107.0/255.0, blue: 107.0/255.0, alpha: 1.0) ,callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            if let mainVC=CidsConnector.sharedInstance().mainVC {
                let oAction=ProtokollStatusUpdateAction(protokoll: self)
                oAction.sender=sender
                oAction.mainVC=mainVC
                oAction.arbeitsprotokoll_id=self.id
                oAction.formVC.form=oAction.getFormDescriptor()
                let detailNC=UINavigationController(rootViewController: oAction.formVC)
                
                detailNC.isModalInPopover=true
                detailNC.modalPresentationStyle = UIModalPresentationStyle.popover
                detailNC.popoverPresentationController?.sourceView = sender
                detailNC.popoverPresentationController?.sourceRect = sender.bounds
                detailNC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.left
                detailNC.preferredContentSize = oAction.getPreferredSize()
                
                mainVC.present(detailNC, animated: true, completion: nil)
                
            }
            
            return true
        })
        let actions=MGSwipeButton(title: "Aktionen", backgroundColor: UIColor(red: 78.0/255.0, green: 205.0/255.0, blue: 196.0/255.0, alpha: 1.0) ,callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            
            if let mainVC=CidsConnector.sharedInstance().mainVC {
                if let oActionProvider=self.attachedGeoBaseEntity as? ObjectActionProvider {
                    if oActionProvider.getAllObjectActions().count>0 {
                        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                        for oAction in oActionProvider.getAllObjectActions() {
                            oAction.sender=sender
                            oAction.mainVC=mainVC
                            oAction.protokoll=self
                            oAction.arbeitsprotokoll_id=self.id
                            alertController.addAction(UIAlertAction(title: oAction.title, style: oAction.style, handler: oAction.handler))
                            
                        }
                        alertController.modalPresentationStyle = .popover
                        let popover = alertController.popoverPresentationController!
                        popover.permittedArrowDirections = .left
                        popover.sourceView = sender
                        popover.sourceRect = sender.bounds
                        mainVC.present(alertController, animated: true, completion: nil)
                    }
                }
            }
            return true
            
        })
        return [status,actions]
    }
}

class ArbeitsprotokollStatus: BaseEntity {
    static let CLASSID=57
    var bezeichnung: String?
    var schluessel: String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"];
        schluessel <- map["schluessel"];
    }
    
    class func ascending(_ lhs: ArbeitsprotokollStatus, rhs: ArbeitsprotokollStatus) -> Bool {
        return lhs.schluessel < rhs.schluessel
    }
}

class ArbeitsprotokollAktion: BaseEntity {
    var aenderung: String?
    var alt: String?
    var neu: String?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        id <- map["id"];
        aenderung <- map["aenderung"];
        alt <- map["alt"];
        neu <- map["neu"];
    }
    
    
}




