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
import AlamofireImage

class ChooseFotoAction : BaseEntityAction {
    init(yourself: BaseEntity) {
        super.init(title: "Foto auswählen",style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction? , selfAction: BaseEntityAction, obj: BaseEntity, detailVC: UIViewController)->Void in
            let picker = MainViewController.IMAGE_PICKER
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            picker.delegate = detailVC as! DetailVC
            (detailVC as! DetailVC).callBacker=FotoPickerCallBacker(yourself: yourself,refreshable: (detailVC as! DetailVC))
            picker.allowsEditing = true
            picker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            detailVC.present(picker, animated: true, completion: nil)
        } )
    }
}

class TakeFotoAction : BaseEntityAction {
    init(yourself: BaseEntity) {
        super.init(title: "Foto erstellen",style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction? , selfAction: BaseEntityAction, obj: BaseEntity, detailVC: UIViewController)->Void in
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
            
        } ) 
    }
}

class FotoPickerCallBacker : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selfEntity: BaseEntity
    var refreshable: Refreshable
    var doneTrigger: (_: DMSUrl)->()
    init (yourself: BaseEntity, refreshable: Refreshable, done: @escaping (_: DMSUrl)->() = {(_)->() in } ){
        selfEntity=yourself
        self.refreshable=refreshable
        self.doneTrigger=done
        if let _ = selfEntity as? DocumentContainer {
            
        }
        else  {
            assert(false, "Entity must be a DocumentContainer")
        }
    }
    let alert = UIAlertController(title: "Bildname", message: "", preferredStyle: UIAlertControllerStyle.alert)
    
    
    
    
    func alertTextFieldDidChange(field: UITextField){
        let alertController:UIAlertController = alert
        let textField :UITextField  = alertController.textFields![0]
        let addAction: UIAlertAction = alertController.actions[1]
        addAction.isEnabled = (textField.text?.characters.count)! >= 0
        
    }
    
    
    //UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // var mediaType:String = info[UIImagePickerControllerEditedImage] as! String
        
        let progressHUD = JGProgressHUD(style: JGProgressHUDStyle.dark)
        progressHUD?.show(in: picker.view,animated: true)
        var tField: UITextField!
        
        func getTestPrefix() -> String {
            if CidsConnector.sharedInstance().inDevEnvironment() {
                return "this.is.really.only.a.test.can.be.deleted.without.problems....";
            }
            else {
                return "";
            }
        }
        
        func handleCancel(_ alertView: UIAlertAction!) {
            picker.dismiss(animated: true, completion: nil)
        }
        
        
        alert.addTextField { (textField) in
            log.verbose("generating the TextField")
            textField.placeholder = "Name hier eingeben"
            tField = textField
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(field:)), for: UIControlEvents.editingChanged)
        }

        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler:handleCancel))
        
        let okAction=UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
            var imageToSave:UIImage
            
            imageToSave = info[UIImagePickerControllerOriginalImage]as! UIImage
            progressHUD?.show(in: picker.view,animated: true)
            let metadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary
            
            
            let ctm=Int64(Date().timeIntervalSince1970*1000)
            let pictureName=tField.text!
            
            let objectId=self.selfEntity.id
            let objectTyp=self.selfEntity.getType().tableName().lowercased()
            
            let fileNameThumb="\(getTestPrefix())upload.from.ios.for.\(objectTyp).\(objectId)-\(ctm).jpg.thumbnail.jpg"
            let fileName="\(getTestPrefix())upload.from.ios.for.\(objectTyp).\(objectId)-\(ctm).jpg"
            
            
            BelisPhotoAlbum.sharedInstance.save(image: imageToSave, pictureName: pictureName, keywords: "BelIS", instructions: "upload to: \(fileName)", description: "https://www.cismet.de", additionalInfoAsJson: "{}")
            
            func handleProgress(_ progress:Float) {
                log.verbose(progress)
            }
            
            func handleCompletion(_ data : Data?, response : URLResponse?, error : Error?) {
                if let err = error {
                    log.error("error: \(err.localizedDescription)")
                }
                if let resp = data  {
                    log.verbose(NSString(data: resp, encoding: String.Encoding.utf8.rawValue) ?? "---")
                    let parmas=ActionParameterContainer(params: [   "OBJEKT_ID":"\(objectId)" as AnyObject,
                                                                    "OBJEKT_TYP":objectTyp as AnyObject,
                                                                    "DOKUMENT_URL":"\(CidsConnector.sharedInstance().getWebDAVBaseUrl().getUrl())\(fileName)\n\(pictureName)" as AnyObject])
                    CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "AddDokument", params: parmas, handler: {(success:Bool) -> () in
                        assert(!Thread.isMainThread )
                        lazyMainQueueDispatch({ () -> () in
                            picker.dismiss(animated:true , completion: nil)
                            if success {
                                log.verbose("Everything is going to be 200-OK")
                                let dmsUrlObject=DMSUrl(name:pictureName, fileName:fileName)
                                (self.selfEntity as! DocumentContainer).addDocument(dmsUrlObject)
                                self.refreshable.refresh()
                                self.doneTrigger(dmsUrlObject)
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
            let newSize=CGSize(width: 300.0, height:ratio*300.0)
            let thumb = imageToSave.af_imageAspectScaled(toFill: newSize)
            
            
            CidsConnector.sharedInstance().uploadImageToWebDAV(thumb, fileName: fileNameThumb , completionHandler: handleCompletion)
        })
        okAction.isEnabled=false
        alert.addAction(okAction)
        progressHUD?.dismiss()
        picker.present(alert, animated: true, completion: {
            log.verbose("completion block")
        })
        
        
        
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        log.verbose("FotoPickerCallBacker CANCEL")
        picker.dismiss(animated: true, completion: { () -> Void in })
        
    }
}
