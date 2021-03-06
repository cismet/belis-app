//
//  Arbeitsauftrag.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper
import MGSwipeTableCell
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


class Arbeitsauftrag : GeoBaseEntity,CellInformationProviderProtocol, CellDataProvider, RightSwipeActionProvider, PolygonStyler {
    var angelegtVon:String?
    var angelegtAm: Date?
    var nummer: String?
    var protokolle: [Arbeitsprotokoll]?
    var zugewiesenAn: Team?
 
    // MARK: - required init because of ObjectMapper
    required init?(map: Map) {
        super.init(map: map)
    }

    // MARK: - essential overrides BaseEntity
    override func mapping(map: Map) {
        id <- map["id"];
        angelegtVon <- map["angelegt_von"]
        angelegtAm <- (map["angelegt_am"], DateTransformFromString(format: "yyyy-MM-dd"))
        nummer <- map["nummer"]
        protokolle <- map["ar_protokolle"]
        zugewiesenAn <- map["zugewiesen_an"]
        
        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <- map["ausdehnung_wgs84"]
    }
    override func getType() -> Entity {
        return Entity.ARBEITSAUFTRAEGE
    }
    
    // MARK: - essential overrides GeoBaseEntity
    override func getAnnotationTitle() -> String{
        return "\(getMainTitle()) - \(getSubTitle())"
    }
    override func canShowCallout() -> Bool{
        return true;
    }
    override func getAnnotationCalloutGlyphIconName() -> String {
        return "icon-line";
    }

    // MARK: - CellInformationProviderProtocol Impl
    func getMainTitle() -> String{
        if let nr = nummer {
            return "A\(nr)"
        }
        else {
            return "A???"
        }
    }
    func getSubTitle() -> String{
        if let dat = angelegtAm {
            return dat.toDateString()
        }
        else {
            return "-"
        }
    }
    func getTertiaryInfo() -> String{
        if let von = angelegtVon {
            return von
        }
        return "-"
    }
    func getQuaternaryInfo() -> String{
        if let prot=protokolle {
            return "\(prot.count)"
        }
        return "?"
    }
    
    // MARK: CellDataProvider Impl
    @objc func getTitle() -> String {
        return "Arbeitsauftrag"
    }
    @objc func getDetailGlyphIconString() -> String {
        return "icon-switch"
    }
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        data["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Nummer",dataLeft: getMainTitle(),titleRight: "zugewiesen an",dataRight: zugewiesenAn?.name ?? "-"))
        data["main"]?.append(DoubleTitledInfoCellData(titleLeft: "angelegt von", dataLeft: angelegtVon ?? "-", titleRight: "angelegt am", dataRight: angelegtAm?.toDateString() ?? "-"))
        
        if let prots = protokolle {
            data["Protokolle"]=[]
            for p in prots {
                let protDetails=p.getAllData()
                let protSections=p.getDataSectionKeys()
                
                data["Protokolle"]?.append(SingleTitledInfoCellDataWithDetails(title: "#\(p.protokollnummer ?? 0): \(p.attachedGeoBaseEntity?.getAnnotationTitle() ?? "-")",data: p.getSubTitle(), details: protDetails, sections: protSections))
//                data["Protokolle"]?.append(SingleTitledInfoCellData(title: "#\(p.protokollnummer!)",data: zugewiesenAn?.name ?? "-"))
            }
        }
       
        
        data["DeveloperInfo"]=[]
        data["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))
        return data
    }
    @objc func getDataSectionKeys() -> [String] {
        return ["main","Protokolle","DeveloperInfo"]
    }
    
    // MARK: RightSwipeActionProvider Impl
    func getRightSwipeActions() -> [MGSwipeButton] {
        let selC=UIColor(red: 91.0/255.0, green: 152.0/255.0, blue: 246.0/255.0, alpha: 1.0)
        
        let select=MGSwipeButton(title: "Auswählen", backgroundColor: selC ,callback: {
            (sender: MGSwipeTableCell!) -> Bool in
            if let mainVC=CidsConnector.sharedInstance().mainVC {
                mainVC.selectArbeitsauftrag(self)
            }
            
            return true
        })
        return [select]
    }
    
    //MARK:- PolygonStyler Impl
    func getStrokeColor()->UIColor {
        return UIColor(red: 196.0/255.0, green: 77.0/255.0, blue: 88.0/255.0, alpha: 0.8)
    }
    func getLineWidth()->CGFloat {
        return 10
    }
    func getFillColor()->UIColor {
        return UIColor(red: 255.0/255.0, green: 107.0/255.0, blue: 107.0/255.0, alpha: 0.8)
    }

    // MARK: - ObjectActionProvider Impl
    @objc func getAllObjectActions() -> [ObjectAction]{
        return [SonstigesAction()]
    }
 
    // MARK: - ObjectFunctions
    func getVeranlassungsnummern() -> [String] {
        var nummern: [String]=[]
        if let prots=protokolle {
            for prot in prots {
                if let vnr=prot.veranlassungsnummer{
                    if !nummern.contains(vnr){
                        nummern.append(vnr)
                    }
                }
            }
        }
        return nummern
    }
}

class Team : BaseEntity {
    var name: String?
    override func mapping(map: Map) {
        super.id <- map["id"]
        name <- map["name"]
    }
    class func ascending(_ lhs: Team, rhs: Team) -> Bool {
        return lhs.name < rhs.name
    }

}
