//
//  Mauerlasche.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper

class Mauerlasche : GeoBaseEntity, Mappable,CellInformationProviderProtocol, CellDataProvider,ActionProvider {
    var erstellungsjahr: Int?
    var laufendeNummer: Int?
    var material: Mauerlaschenmaterial?
    var strasse: Strasse?
    var dokumente: [DMSUrl] = []
    var pruefdatum: NSDate?
    var monteur: String?
    var bemerkung: String?
    var foto: DMSUrl?
    

    
    init(id: Int, laufendeNummer: Int, geoString: String) {
        super.init()
        self.id=id;
        self.laufendeNummer=laufendeNummer;
        self.wgs84WKT=geoString;
    }

    required init?(_ map: Map) {
        super.init(map)
    }
    
    override func getType() -> Entity {
        return Entity.MAUERLASCHEN
    }

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
        return "icon-nut";
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        strasse <- map["fk_strassenschluessel"]
        erstellungsjahr <- map["erstellungsjahr"]

        laufendeNummer <- map["laufende_nummer"]
        material <- map["fk_material"]
        strasse <- map["fk_strassenschluessel"]
        dokumente <- map["dokumente"]
        pruefdatum <- (map["pruefdatum"], DateTransformFromMillisecondsTimestamp())
        monteur <- map["monteur"]
        bemerkung <- map["bemerkung"]
        foto <- map["foto"]

        //Muss an den Schluss wegen by Value übergabe des mapObjects -.-
        wgs84WKT <- map["fk_geom.wgs84_wkt"]
        
    }
    
    @objc func getAllData() -> [String: [CellData]] {
        var data: [String: [CellData]] = ["main":[]]
        if let mat=material?.bezeichnung {
            data["main"]?.append(SingleTitledInfoCellData(title: "Material", data: mat))
        }
        data["main"]?.append(SingleTitledInfoCellData(title: "Strasse", data: strasse?.name ?? "-"))
        
        if let jj=erstellungsjahr {
            if let pruefd=pruefdatum {
                data["main"]?.append(DoubleTitledInfoCellData(titleLeft: "Montage",dataLeft: "\(jj)" ,titleRight: "Prüfung",dataRight: "\(pruefd)"))
            }
            else {
                data["main"]?.append(SingleTitledInfoCellData(title: "Montage", data: "\(jj)"))
            }
        }
        else {
            if let pruefd=pruefdatum {
                data["main"]?.append(SingleTitledInfoCellData(title: "Prüfung", data: "\(pruefd.toDateString())"))
            }
        }
        if let m=monteur {
            data["main"]?.append(SingleTitledInfoCellData(title: "Monteur", data: m))
        }
        if let bem=bemerkung {
            data["main"]?.append(MemoTitledInfoCellData(title: "Bemerkung", data: bem))
        }
        
        if let fotodok=foto {
            data["Foto"]=[]
            data["Foto"]?.append(SimpleUrlPreviewInfoCellData(title: fotodok.getTitle(), url: fotodok.getUrl()))
        }
        
        
        return data
    }
    
    // Actions 
    @objc func getAllActions() -> [BaseEntityAction] {
        

        var actions:[BaseEntityAction]=[]
        
        actions.append(BaseEntityAction(title: "Foto erstellen",style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction! , selfAction: BaseEntityAction, con: CidsConnector , obj: BaseEntity, detailVC: UIViewController)->Void in
            
            
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                //load the camera interface
                let picker = (detailVC as! DetailVC).mainVC.imagePicker
                picker.sourceType = UIImagePickerControllerSourceType.Camera
                picker.delegate = detailVC as! DetailVC
                (detailVC as! DetailVC).callBacker=FotoPickerCallBacker()

                picker.allowsEditing = true
                //picker.showsCameraControls=true
                picker.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
                detailVC.presentViewController(picker, animated: true, completion: { () -> Void in  })
            }else{
                //no camera available
                var alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                detailVC.presentViewController(alert, animated: true, completion: nil)
            }
            
        }))
        
        actions.append(BaseEntityAction(title: "Foto auswählen",style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction! , selfAction: BaseEntityAction, con: CidsConnector , obj: BaseEntity, detailVC: UIViewController)->Void in
            let picker = (detailVC as! DetailVC).mainVC.imagePicker
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
            picker.delegate = detailVC as! DetailVC
            (detailVC as! DetailVC).callBacker=FotoPickerCallBacker()
            picker.allowsEditing = true
            picker.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            detailVC.presentViewController(picker, animated: true, completion: nil)
        }))
        
        return actions
    }
    
    
    
    
    // MARK: - CellInformationProviderProtocol
    
    func getMainTitle() -> String{
        if let lfdNr = laufendeNummer {
            return "M-\(lfdNr)"
        }
        else {
            return "M"
        }
    }
    func getSubTitle() -> String{
        if let mat = material?.bezeichnung {
            return mat
        }
        else {
            return "Mauerlasche"
        }
    }
    func getTertiaryInfo() -> String{
        if let str = strasse?.name {
            return str
        }
        return "-"
    }
    func getQuaternaryInfo() -> String{
        return ""
    }
    
    
}

class Mauerlaschenmaterial : BaseEntity, Mappable{
    var bezeichnung: String?
    
    override func mapping(map: Map) {
        id <- map["id"];
        bezeichnung <- map["bezeichnung"];
    }

    
}
class FotoPickerCallBacker : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        println("FotoPickerCallBacker FINISH")
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        println("FotoPickerCallBacker CANCEL")
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }
}

//class FotoAction : BaseEntityAction, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    //UIImagePickerControllerDelegate
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
//        println("FotoAction FINISH")
//        picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
//        
//    }
//    
//    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
//        println("FotoAction CANCEL")
//        picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
//        
//    }
//}
//
