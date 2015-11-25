//
//  Abzweigdose.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Abzweigdose : GeoBaseEntity,CellInformationProviderProtocol, CellDataProvider, ObjectActionProvider {
    var dokumente: [DMSUrl]=[]
    
    // MARK: - required init because of ObjectMapper
    required init?(_ map: Map) {
        super.init(map)
    }
    
    // MARK: - essential overrides BaseEntity
    override func mapping(map: Map) {
        id <- map["id"];
        dokumente <- map["dokumente"];
        
        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
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
        return "icon-squarea";
    }
    
    // MARK: - CellInformationProviderProtocol Impl
    func getMainTitle() -> String{
        return "AZD \(id)"
    }
    func getSubTitle() -> String{
            return "Abzweigdose"
    }
    func getTertiaryInfo() -> String{
        return ""
    }
    func getQuaternaryInfo() -> String{
        return ""
    }
    
    // MARK: - CellDataProvider Impl
    @objc func getTitle() -> String {
        return "Mauerlasche"
    }
    @objc func getDetailGlyphIconString() -> String {
        return "icon-squarea"
    }
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]

        data["main"]?.append(SingleTitledInfoCellData(title: "Id", data: "\(id)"))
        
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
