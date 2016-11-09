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
import JGProgressHUD

class ChooseFotoAction : BaseEntityAction {
    init(yourself: BaseEntity) {
        super.init(title: "Foto auswählen",style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction! , selfAction: BaseEntityAction, obj: BaseEntity, detailVC: UIViewController)->Void in
            let picker = MainViewController.IMAGE_PICKER
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            picker.delegate = detailVC as! DetailVC
            (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: yourself,refreshable: (detailVC as! DetailVC))
            picker.allowsEditing = true
            picker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            detailVC.present(picker, animated: true, completion: nil)
        } as! (UIAlertAction?, BaseEntityAction, BaseEntity, UIViewController) -> Void)
    }
}

class TakeFotoAction : BaseEntityAction {
    init(yourself: BaseEntity) {
        super.init(title: "Foto erstellen",style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction! , selfAction: BaseEntityAction, obj: BaseEntity, detailVC: UIViewController)->Void in
            if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
                //load the camera interface
                let picker = MainViewController.IMAGE_PICKER
                picker.sourceType = UIImagePickerControllerSourceType.camera
                picker.delegate = detailVC as! DetailVC
                (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: yourself,refreshable: (detailVC as! DetailVC))
                
                picker.allowsEditing = true
                //picker.showsCameraControls=true
                picker.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
                detailVC.present(picker, animated: true, completion: { () -> Void in  })
            }else{
                //no camera available
                let alert = UIAlertController(title: "Error", message: "There is no camera available", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: {(alertAction)in
                    alert.dismiss(animated: true, completion: nil)
                }))
                detailVC.present(alert, animated: true, completion: nil)
            }
            
        } as! (UIAlertAction?, BaseEntityAction, BaseEntity, UIViewController) -> Void)
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // var mediaType:String = info[UIImagePickerControllerEditedImage] as! String
        
        let progressHUD = JGProgressHUD(style: JGProgressHUDStyle.dark)
        progressHUD?.show(in: picker.view,animated: true)
        var tField: UITextField!
        
        func configurationTextField(_ textField: UITextField!)
        {
            print("generating the TextField")
            textField.placeholder = "Name hier eingeben"
            tField = textField
        }
        
        
        func handleCancel(_ alertView: UIAlertAction!) {
            picker.dismiss(animated: true, completion: nil)
        }
        
        var alert = UIAlertController(title: "Bildname", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
            var imageToSave:UIImage
            
            imageToSave = info[UIImagePickerControllerOriginalImage]as! UIImage
            progressHUD?.show(in: picker.view,animated: true)
            let metadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary
            
            
            let ctm=Int64(Date().timeIntervalSince1970*1000)
            let pictureName=tField.text!
            
            let objectId=self.selfEntity.id
            let objectTyp=self.selfEntity.getType().tableName().lowercased()
            
            let fileNameThumb="upload.from.ios.for.\(objectTyp).\(objectId)-\(ctm).jpg.thumbnail.jpg"
            let fileName="upload.from.ios.for.\(objectTyp).\(objectId)-\(ctm).jpg"
            
            
            
            var newMetadata : [AnyHashable: Any]
            if let md = metadata as? Dictionary<NSObject,AnyObject> {
                newMetadata=md
            }
            else {
                newMetadata=[AnyHashable: Any]()
            }
            
            var iptcMeta=[AnyHashable: Any]()
            iptcMeta.updateValue(pictureName, forKey: kCGImagePropertyIPTCObjectName as AnyHashable)
            iptcMeta.updateValue("BelIS", forKey: kCGImagePropertyIPTCKeywords as AnyHashable)
            iptcMeta.updateValue("upload to: \(fileName)", forKey: kCGImagePropertyIPTCSpecialInstructions as AnyHashable)
           // kCGImagePropertyIPTCSpecialInstructions
            
            var tiffMeta=[AnyHashable: Any]()
            tiffMeta.updateValue("http://www.cismet.de", forKey: kCGImagePropertyTIFFImageDescription as AnyHashable)
            
            
            newMetadata.updateValue(iptcMeta, forKey:kCGImagePropertyIPTCDictionary as AnyHashable )
            newMetadata.updateValue(tiffMeta, forKey:kCGImagePropertyTIFFDictionary as AnyHashable )
            
            
            
            self.library.saveImage(imageToSave, toAlbum: "BelIS-Dokumente",metadata : newMetadata, withCallback: nil)
            
            func handleProgress(_ progress:Float) {
                print(progress)
            }
            
            func handleCompletion(_ data : Data!, response : URLResponse!, error : NSError!) {
                if let err = error {
                    print("error: \(err.localizedDescription)")
                }
                if let resp = data  {
                    print(NSString(data: resp, encoding: String.Encoding.utf8.rawValue))
                    let parmas=ActionParameterContainer(params: [   "OBJEKT_ID":"\(objectId)" as AnyObject,
                        "OBJEKT_TYP":objectTyp as AnyObject,
                        "DOKUMENT_URL":"http://board.cismet.de/belis/\(fileName)\n\(pictureName)" as AnyObject])
                    CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "AddDokument", params: parmas, handler: {(success:Bool) -> () in
                        assert(!Thread.isMainThread )
                        lazyMainQueueDispatch({ () -> () in
                            picker.dismiss(animated:true , completion: nil)
                            if success {
                                print("Everything is going to be 200-OK")
                                (self.selfEntity as! DocumentContainer).addDocument(DMSUrl(name:pictureName, fileName:fileName))
                                self.refreshable.refresh()
                                progressHUD!.indicatorView=JGProgressHUDSuccessIndicatorView()
                            }
                            else {
                                progressHUD!.indicatorView=JGProgressHUDErrorIndicatorView()
                            }
                            progressHUD!.dismiss(afterDelay: TimeInterval(1), animated: true)
                            progressHUD!.indicatorView=JGProgressHUDIndeterminateIndicatorView()
                            progressHUD!.dismiss(animated: true)
                        })
                    })
                }
            }
            let ratio=imageToSave.size.height/imageToSave.size.width
//            let thumb=imageToSave.resizeToWidth(300.0)
            
            
            //let thumb=imageToSave.resize(toSize: CGSize.init(width: 300.0, height:ratio*300.0))
            //FIXME integrate AFImageHelper
            let thumb=imageToSave
            
            CidsConnector.sharedInstance().uploadImageToWebDAV(thumb, fileName: fileNameThumb , completionHandler: handleCompletion as! (Data?, URLResponse?, NSError?) -> Void as! (Data?, URLResponse?, Error?) -> Void)
            
            
            
            
        }))
        progressHUD?.dismiss()
        picker.present(alert, animated: true, completion: {
            print("completion block")
        })
        
        
        
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("FotoPickerCallBacker CANCEL")
        picker.dismiss(animated: true, completion: { () -> Void in })
        
    }
}
