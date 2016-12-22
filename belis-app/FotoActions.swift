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


class AbstractPickerCallBacker : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    
    func getTypeString()->String {
        return self.selfEntity.getType().tableName().lowercased()
    }
    
    func getIdString()->String {
        return "\(self.selfEntity.id)"
    }
    
    
    func saveToDevice(imageToSave:UIImage, pictureName: String, fileName: String) {
         BelisPhotoAlbum.sharedInstance.save(image: imageToSave, pictureName: pictureName, keywords: "BelIS", instructions: "upload to: \(fileName)", description: "https://www.cismet.de", additionalInfoAsJson: "{}")
    }
    
    func uploadToWebDav(imageToSave:UIImage, fileName: String, completionHandler: @escaping (Data?, URLResponse?, Error?)->()) {
        CidsConnector.sharedInstance().uploadImageToWebDAV(imageToSave, fileName: fileName , completionHandler: completionHandler)

    }
    
    func storeCidsObject(pictureName: String, fileName: String, picker: UIImagePickerController,progressHUD: JGProgressHUD? ) {
        let params=ActionParameterContainer(params: [   "OBJEKT_ID":"\(getIdString())" as AnyObject,
                                                        "OBJEKT_TYP":getTypeString() as AnyObject,
                                                        "DOKUMENT_URL":"http://board.cismet.de/belis/\(fileName)\n\(pictureName)" as AnyObject])
        CidsConnector.sharedInstance().executeSimpleServerAction(actionName: "AddDokument", params: params, handler: {(success:Bool) -> () in
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
        
        let alert = UIAlertController(title: "Bildname", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Abbrechen", style: UIAlertActionStyle.cancel, handler:handleCancel))
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{ (UIAlertAction)in
            var imageToSave:UIImage
            
            imageToSave = info[UIImagePickerControllerOriginalImage]as! UIImage
            progressHUD?.show(in: picker.view,animated: true)
            let metadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary
            
            
            let ctm=Int64(Date().timeIntervalSince1970*1000)
            let pictureName=tField.text!
            
            let fileNameThumb="\(getTestPrefix())upload.from.ios.for.\(self.getTypeString()).\(self.getIdString())-\(ctm).jpg.thumbnail.jpg"
            let fileName="\(getTestPrefix())upload.from.ios.for.\(self.getTypeString()).\(self.getIdString())-\(ctm).jpg"
            
            self.saveToDevice(imageToSave: imageToSave, pictureName: pictureName, fileName: fileName)
            
            let ratio=imageToSave.size.height/imageToSave.size.width
            let newSize=CGSize(width: 300.0, height:ratio*300.0)
            let thumb = imageToSave.af_imageAspectScaled(toFill: newSize)
            
            func uploadCompletionHandler(_ data : Data?, response : URLResponse?, error : Error?) {
                if let err = error {
                    print("error: \(err.localizedDescription)")
                }
                if data != nil  {
                    self.storeCidsObject(pictureName: pictureName, fileName: fileName, picker: picker, progressHUD: progressHUD)
                }
            }
            self.uploadToWebDav(imageToSave: thumb, fileName: fileName, completionHandler: uploadCompletionHandler)
            
            
            
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





class FotoPickerCallBacker : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
            
            let fileNameThumb="\(getTestPrefix())upload.from.ios.for.\(objectTyp).\(objectId)-\(ctm).jpg.thumbnail.jpg"
            let fileName="\(getTestPrefix())upload.from.ios.for.\(objectTyp).\(objectId)-\(ctm).jpg"
            
            
            BelisPhotoAlbum.sharedInstance.save(image: imageToSave, pictureName: pictureName, keywords: "BelIS", instructions: "upload to: \(fileName)", description: "https://www.cismet.de", additionalInfoAsJson: "{}")
            
            func handleProgress(_ progress:Float) {
                print(progress)
            }
            
            func handleCompletion(_ data : Data?, response : URLResponse?, error : Error?) {
                if let err = error {
                    print("error: \(err.localizedDescription)")
                }
                if let resp = data  {
                    print(NSString(data: resp, encoding: String.Encoding.utf8.rawValue) ?? "---")
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
            let newSize=CGSize(width: 300.0, height:ratio*300.0)
            let thumb = imageToSave.af_imageAspectScaled(toFill: newSize)
            
            
            CidsConnector.sharedInstance().uploadImageToWebDAV(thumb, fileName: fileNameThumb , completionHandler: handleCompletion)
            
            
            
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
