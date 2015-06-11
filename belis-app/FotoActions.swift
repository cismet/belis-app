//
//  ChooseFotoAction.swift
//  belis-app
//
//  Created by Thorsten Hell on 11/06/15.
//  Copyright (c) 2015 cismet. All rights reserved.
//

import Foundation
import AssetsLibrary

class ChooseFotoAction : BaseEntityAction {
    init(yourself: BaseEntity) {
        super.init(title: "Foto auswählen",style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction! , selfAction: BaseEntityAction, con: CidsConnector , obj: BaseEntity, detailVC: UIViewController)->Void in
            let picker = (detailVC as! DetailVC).mainVC.imagePicker
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)!
            picker.delegate = detailVC as! DetailVC
            (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: yourself,detailVC: (detailVC as! DetailVC))
            picker.allowsEditing = true
            picker.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            detailVC.presentViewController(picker, animated: true, completion: nil)
        })
    }
}

typealias CompletionHandler = (success:Bool!) -> Void
class TakeFotoAction : BaseEntityAction {
    init(yourself: BaseEntity) {
        super.init(title: "Foto erstellen",style: UIAlertActionStyle.Default, handler: {
            (action: UIAlertAction! , selfAction: BaseEntityAction, con: CidsConnector , obj: BaseEntity, detailVC: UIViewController)->Void in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
                //load the camera interface
                let picker = (detailVC as! DetailVC).mainVC.imagePicker
                picker.sourceType = UIImagePickerControllerSourceType.Camera
                picker.delegate = detailVC as! DetailVC
                (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: yourself,detailVC: (detailVC as! DetailVC))
                
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
            
        })
    }
}


class FotoPickerCallBacker : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var library = ALAssetsLibrary()

    var selfEntity: BaseEntity
    var detailVC: DetailVC
    init (yourself: BaseEntity, detailVC: DetailVC){
        selfEntity=yourself
        self.detailVC=detailVC
        if let container=selfEntity as? DocumentContainer {
            
        }
        else  {
            assert(false, "Entity must be a DocumentContainer")
        }
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
            
            if picker.sourceType == UIImagePickerControllerSourceType.Camera {
                UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil)
                println("FotoPickerCallBacker PICKED FROM Camera")
            }
            else {
                //picked from CameraRoll
                println("FotoPickerCallBacker PICKED FROM CameraRoll")
                var meta:[NSObject:AnyObject]=[:]
                
//                ALAssetsLibrary().writeImageToSavedPhotosAlbum(imageToSave.CGImage, metadata: <#[NSObject : AnyObject]!#>, completionBlock: <#ALAssetsLibraryWriteImageCompletionBlock!##(NSURL!, NSError!) -> Void#>)
            }

            
            var cidsConnector=CidsConnector(user: "WendlingM@BELIS2", password: "boxy")
            let ctm=Int64(NSDate().timeIntervalSince1970*1000)
            let pictureName=tField.text
            
            let objectId=self.selfEntity.id
            let objectTyp=self.selfEntity.getType().tableName().lowercaseString
            
            let fileName="upload.from.ios.for.\(objectTyp).\(objectId)-\(ctm)_thumb.png"
            
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
                    cidsConnector.executeSimpleServerAction(actionName: "AddDokument", params: parmas, handler: {() -> () in
                        actInd.stopAnimating()
                        actInd.removeFromSuperview()
                        picker.dismissViewControllerAnimated(true, completion: nil)
                        println("Everything is going to be 200-OK")
                        (self.selfEntity as! DocumentContainer).addDocument(DMSUrl(name:pictureName, fileName:fileName))
                        self.detailVC.refresh()
                    })
                }
            }
            let thumb=imageToSave.resizeToWidth(300.0)
            cidsConnector.uploadImageToWebDAV(thumb, fileName: fileName ,progressHandler: handleProgress, completionHandler: handleCompletion)
            
            
            
            
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
