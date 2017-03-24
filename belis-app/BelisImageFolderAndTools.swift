//
//  BelisImageFolderAndTools.swift
//  belis-app
//
//  Created by Thorsten Hell on 14.11.16.
//  Copyright © 2016 cismet. All rights reserved.
//

import Foundation
import Photos
import ImageIO
import MobileCoreServices

class BelisPhotoAlbum {
    
    var assetCollection: PHAssetCollection!
    var albumFound : Bool = false
    var photosAsset: PHFetchResult<AnyObject>!
    var assetThumbnailSize:CGSize!
    var collection: PHAssetCollection!
    var assetCollectionPlaceholder: PHObjectPlaceholder!
    
    static let sharedInstance = BelisPhotoAlbum()
    
    init() {
        createAlbum();
    }
    
    static let albumName = "BelIS-Dokumente"
    
    func createAlbum() {
        //Get PHFetch Options
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", "\(BelisPhotoAlbum.albumName)")
        let collection : PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        //Check return value - If found, then get the first album out
        if let _: AnyObject = collection.firstObject {
            self.albumFound = true
            assetCollection = collection.firstObject! as PHAssetCollection
        } else {
            //If not found - Then create a new album
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest : PHAssetCollectionChangeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: "\(BelisPhotoAlbum.albumName)")
                self.assetCollectionPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                self.albumFound = success
                
                if (success) {
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [self.assetCollectionPlaceholder.localIdentifier], options: nil)
                    self.assetCollection = collectionFetchResult.firstObject! as PHAssetCollection
                }
            })
        }
    }
    
    func save(image: UIImage, pictureName: String, keywords: String, instructions: String, description: String, additionalInfoAsJson: String){

        let tempPath=NSTemporaryDirectory()
        print (tempPath)
        let tmpURL = NSURL.fileURL(withPath: tempPath)
        let fileURL = tmpURL.appendingPathComponent("tempfile.jpg");
       
        if let data = UIImageJPEGRepresentation(image, 0.8) {
            
            let imageSource = CGImageSourceCreateWithData(data as CFData,nil)
            let defaultAttributes = CGImageSourceCopyPropertiesAtIndex(imageSource!, 0, nil)
            let extendedAttributes = NSMutableDictionary(dictionary: defaultAttributes as! [AnyHashable : Any], copyItems: true)
            
//            let pictureName="cismet-picture-name"
//            let keywords="cismet-keywords"
//            let instructions="cismet-instructions"
//            let description="cismet-tiff-description"
//            let additionalInfoAsJson="{arbitrary-field='cismet-demo-field'}"
            
            var iptcMetaData = [String : AnyObject] ()
            iptcMetaData [kCGImagePropertyIPTCObjectName as String] = pictureName as AnyObject?
            iptcMetaData [kCGImagePropertyIPTCKeywords as String] = keywords as AnyObject?
            iptcMetaData [kCGImagePropertyIPTCSpecialInstructions as String] = instructions as AnyObject?
            
            var tiffMetaData = [String : AnyObject] ()
            tiffMetaData [kCGImagePropertyTIFFImageDescription as String] = description as AnyObject?
            
            var exifMetaData = [String : AnyObject] ()
            exifMetaData [kCGImagePropertyExifUserComment as String] = additionalInfoAsJson as AnyObject?

            let i_metadata = [kCGImagePropertyIPTCDictionary as String : iptcMetaData]
            let t_metadata = [kCGImagePropertyTIFFDictionary as String : tiffMetaData]
            let e_metadata = [kCGImagePropertyExifDictionary as String : exifMetaData]

            
            
            for item in i_metadata {
                extendedAttributes [item.0] = item.1
            }
            for item in t_metadata {
                extendedAttributes [item.0] = item.1
            }
            for item in e_metadata {
                extendedAttributes [item.0] = item.1
            }

            let outputJPGdata = NSMutableData ()
            let imageDestination = CGImageDestinationCreateWithData (outputJPGdata, kUTTypeJPEG, 1, nil)
            CGImageDestinationAddImageFromSource (imageDestination!, imageSource!, 0, extendedAttributes)
            let success = CGImageDestinationFinalize (imageDestination!)
            assert (success, "Fail!")
            let filename = fileURL
            try? outputJPGdata.write(to: filename)
        }
        
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)!
            let assetPlaceholder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: self.assetCollection)
            let enumeration: NSArray = [assetPlaceholder!]
            albumChangeRequest?.addAssets(enumeration)
        }, completionHandler: { (success, error) in
            // to-do: delete the temporary file
            log.verbose("added image to album:")
            log.verbose(error ?? "everything is ok")
        })
    }
}

