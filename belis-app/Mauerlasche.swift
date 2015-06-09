//
//  Mauerlasche.swift
//  Experiments
//
//  Created by Thorsten Hell on 10/12/14.
//  Copyright (c) 2014 cismet. All rights reserved.
//

import Foundation
import ObjectMapper
import SwiftHTTP

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

        data["Dokumente"]=[]

        if let fotodok=foto {
            data["Dokumente"]?.append(SimpleUrlPreviewInfoCellData(title: fotodok.getTitle(), url: fotodok.getUrl()))
        }
        
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
                (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: self)

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
            (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: self)
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
    var selfEntity: BaseEntity
    
    init (yourself: BaseEntity){
        selfEntity=yourself
    }
    
    //UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        // var mediaType:String = info[UIImagePickerControllerEditedImage] as! String
        
        var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 150, 150)) as UIActivityIndicatorView
        actInd.center =  picker.view.center
        actInd.hidesWhenStopped = true;
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray;
        picker.view.addSubview(actInd)
        
        var tField: UITextField!
        
        func configurationTextField(textField: UITextField!)
        {
            println("generating the TextField")
            textField.placeholder = "Enter an item"
            tField = textField
        }
        
        
        func handleCancel(alertView: UIAlertAction!) {
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
        
        var alert = UIAlertController(title: "Bildname", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler(configurationTextField)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.Cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler:{ (UIAlertAction)in
            var imageToSave:UIImage
            
            imageToSave = info[UIImagePickerControllerOriginalImage]as! UIImage
            actInd.startAnimating();

            if picker.sourceType == UIImagePickerControllerSourceType.Camera {
                UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
                println("FotoPickerCallBacker PICKED FROM Camera")
            }
            else {
                //picked from CameraRoll
                println("FotoPickerCallBacker PICKED FROM CameraRoll")
            }

            let size = CGSizeApplyAffineTransform(imageToSave.size, CGAffineTransformMakeScale(0.3, 0.3))
            let hasAlpha = false
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
            UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
            imageToSave.drawInRect(CGRect(origin: CGPointZero, size: size))
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            var cidsConnector=CidsConnector(user: "WendlingM@BELIS2", password: "boxy")
            
            let ctm=Int64(NSDate().timeIntervalSince1970*1000)
            let pictureName=tField.text
            
//            cidsConnector.uploadAndAddImageServerAction(image: imageToSave, entity: self.selfEntity,description: tField.text, completionHandler: {(response: HTTPResponse) -> Void in
//                if let err = response.error {
//                    println("error: \(err.localizedDescription)")
//                    return //also notify app of failure as needed
//                }
//                if let resp = response.responseObject as? NSData {
//                    println(NSString(data: resp, encoding: NSUTF8StringEncoding))
//                }
//                actInd.stopAnimating()
//                actInd.removeFromSuperview()
//                picker.dismissViewControllerAnimated(true, completion: nil)
//                println("Got data with no error")
//            })

            let objectId=self.selfEntity.id
            let objectTyp=self.selfEntity.getType().tableName().lowercaseString
            
            let fileName="uplod.from.ios.for.\(objectTyp).\(objectId)-\(ctm).png"
            
            func handleProgress(progress:Float) {
                println(progress)
            }
            
            func handleCompletion(request: NSURLRequest, response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) {
                if let err = error {
                    println("error: \(err.localizedDescription)")
                }
                if let resp = data as? NSData {
                    println(NSString(data: resp, encoding: NSUTF8StringEncoding))
                    let parmas=ActionParameterContainer(params: [   "OBJEKT_ID":"\(objectId)",
                        "OBJEKT_TYP":objectTyp,
                        "DOKUMENT_URL":"http://board.cismet.de/belis/\(fileName)\n\(pictureName)"])
                    cidsConnector.executeSimpleServerAction(actionName: "AddDokument", params: parmas, handler: {() -> () in })
                    actInd.stopAnimating()
                    actInd.removeFromSuperview()
                    picker.dismissViewControllerAnimated(true, completion: nil)
                    println("Everything is going to be 200-OK")
                }
            }
            
            cidsConnector.uploadImageToWebDAV(imageToSave, fileName: fileName ,progressHandler: handleProgress, completionHandler: handleCompletion)
            
            
            
            
        }))
        picker.presentViewController(alert, animated: true, completion: {
            println("completion block")
        })
        
        
        
        
        
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
