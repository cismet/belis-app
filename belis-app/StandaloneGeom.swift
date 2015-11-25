//
//  StandaloneGeom.swift
//  belis-app
//
//  Created by Thorsten Hell on 12.11.15.
//  Copyright © 2015 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class StandaloneGeom: GeoBaseEntity, ObjectActionProvider {
    var dokumente: [DMSUrl] = []
    var bezeichnung: String?
    
    // MARK: - required init because of ObjectMapper
    required init?(_ map: Map) {
        super.init(map)
    }
    
    // MARK: - essential overrides BaseEntity
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"];
        dokumente <- map["ar_dokumente"];
        wgs84WKT <- map["fk_geom.wgs84_wkt"]
    }
    override func getType() -> Entity {
        return Entity.ABZWEIGDOSEN
    }
    
    // MARK: - essential overrides GeoBaseEntity
    override func getAnnotationImageName() -> String{
        return "mauerlasche.png";
    }
    override func getAnnotationTitle() -> String{
        return getMainTitle();
    }
    override func canShowCallout() -> Bool{
        return true;
    }
    override func getAnnotationCalloutGlyphIconName() -> String {
        return "icon-polygonlasso";
    }
    
    // MARK: - CellInformationProviderProtocol Impl
    func getMainTitle() -> String{
        return "FG \(bezeichnung ?? "")"
    }
    func getSubTitle() -> String{
        return "Freie Geometrie"
    }
    func getTertiaryInfo() -> String{
        return ""
    }
    func getQuaternaryInfo() -> String{
        return ""
    }
    
    // MARK: - CellDataProvider Impl
    @objc func getTitle() -> String {
        return getMainTitle()
    }
    @objc func getDetailGlyphIconString() -> String {
        return "icon-polygonlasso"
    }
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        
        data["main"]?.append(SingleTitledInfoCellData(title: "Bezeichnung", data: bezeichnung ?? ""))
        
        if dokumente.count>0 {
            for doc in dokumente {
                data["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: doc.getTitle(), url: doc.getUrl()))
            }
        }
        
        data["DeveloperInfo"]=[]
        data["DeveloperInfo"]?.append(SingleTitledInfoCellData(title: "Key", data: "\(getType().tableName())/\(id)"))
        
        return data
    }
    @objc func getDataSectionKeys() -> [String] {
        return ["main","Dokumente","DeveloperInfo"]
    }
    
    // MARK: - ObjectActionProvider Impl
    @objc func getAllObjectActions() -> [ObjectAction]{
        return [SonstigesAction()]
    }

}