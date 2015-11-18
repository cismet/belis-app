//
//  ChooseFotoAction.swift
//  belis-app
//
//  Created by Thorsten Hell on 11/06/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import AssetsLibrary
import ImageIO

class ChooseFotoAction : BaseEntityAction {
    init(yourself: BaseEntity) {
        super.init(title: "Foto auswählen",style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction! , selfAction: BaseEntityAction, obj: BaseEntity, detailVC: UIViewController)->Void in
            let picker = MainViewController.IMAGE_PICKER
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
            picker.delegate = detailVC as! DetailVC
            (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: yourself,refreshable: (detailVC as! DetailVC))
            picker.allowsEditing = true
            picker.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            detailVC.presentViewController(picker, animated: true, completion: nil)
        })
    }
}

class TakeFotoAction : BaseEntityAction {
    init(yourself: BaseEntity) {
        super.init(title: "Foto erstellen",style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction! , selfAction: BaseEntityAction, obj: BaseEntity, detailVC: UIViewController)->Void in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                //load the camera interface
                let picker = MainViewController.IMAGE_PICKER
                picker.sourceType = UIImagePickerControllerSourceType.Camera
                picker.delegate = detailVC as! DetailVC
                (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: yourself,refreshable: (detailVC as! DetailVC))
                
                picker.allowsEditing = true
                //picker.showsCameraControls=true
                picker.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
                detailVC.presentViewController(picker, animated: true, completion: { () -> Void in  })
            }else{
                //no camera available
                let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: {(alertAction)in
                    alert.dismissViewControllerAnimated(true, completion: nil)
                }))
                detailVC.presentViewController(alert, animated: true, completion: nil)
            }
            
        })
    }
}


class FotoPickerCallBacker : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var library = ALAssetsLibrary()
    
    var selfEntity: BaseEntity
    var refreshable: Refreshable
    init (yourself: BaseEntity, refreshable: Refreshable){
        selfEntity=yourself
        self.refreshable=refreshable
        if let _ = selfEntity as? DocumentContainer {
            
        }
        else  {
            assert(false, "Entity must be a DocumentContainer")
        }
    }
    
    
    
    //UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // var mediaType:String = info[UIImagePickerControllerEditedImage] as! String
        
        var actInd : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(0,0, 150, 150)) as UIActivityIndicatorView
        actInd.center =  picker.view.center
        actInd.hidesWhenStopped = true;
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray;
        picker.view.addSubview(actInd)
        
        var tField: UITextField!
        
        func configurationTextField(textField: UITextField!)
        {
            print("generating the TextField")
            textField.placeholder = "Name hier eingeben"
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
            let metadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary
            
            
            let ctm=Int64(NSDate().timeIntervalSince1970*1000)
            let pictureName=tField.text!
            
            let objectId=self.selfEntity.id
            let objectTyp=self.selfEntity.getType().tableName().lowercaseString
            
            let fileNameThumb="upload.from.ios.for.\(objectTyp).\(objectId)-\(ctm).jpg.thumbnail.jpg"
            let fileName="upload.from.ios.for.\(objectTyp).\(objectId)-\(ctm).jpg"
            
            
            
            var newMetadata : [NSObject:AnyObject]
            if let md = metadata as? Dictionary<NSObject,AnyObject> {
                newMetadata=md
            }
            else {
                newMetadata=[NSObject:AnyObject]()
            }
            
            var iptcMeta=[NSObject:AnyObject]()
            iptcMeta.updateValue(pictureName, forKey: kCGImagePropertyIPTCObjectName)
            iptcMeta.updateValue("BelIS", forKey: kCGImagePropertyIPTCKeywords)
            iptcMeta.updateValue("upload to: \(fileName)", forKey: kCGImagePropertyIPTCSpecialInstructions)
            kCGImagePropertyIPTCSpecialInstructions
            
            var tiffMeta=[NSObject:AnyObject]()
            tiffMeta.updateValue("http://www.cismet.de", forKey: kCGImagePropertyTIFFImageDescription)
            
            
            newMetadata.updateValue(iptcMeta, forKey:kCGImagePropertyIPTCDictionary )
            newMetadata.updateValue(tiffMeta, forKey:kCGImagePropertyTIFFDictionary )
            
            
            
            self.library.saveImage(imageToSave, toAlbum: "BelIS-Dokumente",metadata : newMetadata, withCallback: nil)
            
            func handleProgress(progress:Float) {
                print(progress)
            }
            
            func handleCompletion(data : NSData!, response : NSURLResponse!, error : NSError!) {
                if let err = error {
                    print("error: \(err.localizedDescription)")
                }
                if let resp = data  {
                    print(NSString(data: resp, encoding: NSUTF8StringEncoding))
                    let parmas=ActionParameterContainer(params: [   "OBJEKT_ID":"\(objectId)",
                        "OBJEKT_TYP":objectTyp,
                        "DOKUMENT_URL":"http://board.cismet.de/belis/\(fileName)\n\(pictureName)"])
                    CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "AddDokument", params: parmas, handler: {(success:Bool) -> () in
                        assert(!NSThread.isMainThread() )
                        dispatch_async(dispatch_get_main_queue()) {
                            actInd.stopAnimating()
                            actInd.removeFromSuperview()
                            picker.dismissViewControllerAnimated(true, completion: nil)
                            if success {
                                print("Everything is going to be 200-OK")
                                (self.selfEntity as! DocumentContainer).addDocument(DMSUrl(name:pictureName, fileName:fileName))
                                self.refreshable.refresh()
                            }
                            else {
                                
                            }
                        }
                    })
                }
            }
            let thumb=imageToSave.resizeToWidth(300.0)
            CidsConnector.sharedInstance().uploadImageToWebDAV(thumb, fileName: fileNameThumb , completionHandler: handleCompletion)
            
            
            
            
        }))
        picker.presentViewController(alert, animated: true, completion: {
            print("completion block")
        })
        
        
        
        
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("FotoPickerCallBacker CANCEL")
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in })
        
    }
}
