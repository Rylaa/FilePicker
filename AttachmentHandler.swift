//
//  AttachmentHandler.swift
//  GEO-Isbank
//
//  Created by Yusuf Demirkoparan on 29.04.2020.
//  Copyright © 2020 Remzi Solmaz. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation
import Photos

/*
 Kullanım
 AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
 AttachmentHandler.shared.imagePickedBlock = { (image) in
 /* get your image here */
 }
 
 
 AttachmentHandler.shared.showAttachmentActionSheet(vc: self)
 AttachmentHandler.shared.imagePickedBlock = { (image) in
 /* get your image here */
 }
 AttachmentHandler.shared.videoPickedBlock = {(url) in
 /* get your compressed video url here */
 }
 AttachmentHandler.shared.filePickedBlock = {(filePath) in
 /* get your file path url here */
 }
 */

enum AttachmentType: String {
    case camera
    case video
    case photoLibrary
    case file
    case multipleImage
    case multipleDocument
}

enum DocumentTypes: String {
    case jpg = "public.image"
    case pdf = "public.data"
    case video = "public.movie"
    case doc = "com.microsoft.word.doc"
    case excel = "org.openxmlformats.spreadsheetml.sheet"
    case xls = "com.microsoft.excel.xls"
    
}

final class AttachmentHandler: NSObject {
    static let shared = AttachmentHandler()
    fileprivate var currentVC: UIViewController?
    
    //MARK: - Internal Properties
    var imagePickedBlock: ((UIImage, Data, URL?, PHAsset?) -> Void)?
    var videoPickedBlock: ((NSURL) -> Void)?
    var filePickedBlock: ((URL) -> Void)?
    var multiplePickBlock: ((PHAsset) -> Void)?
    var multipleImagePick: (([PHAsset]) -> Void)?
    var multipleFilePickBlock: (([URL]) -> Void)?
    var fileSize: Double = 0.0
    
    //MARK: - Constants
    
    struct Constants {
        #warning("Dil Resourcedan çekilmeli")
        static let actionFileTypeHeading = "Add a File"
        static let actionFileTypeDescription = "Choose a filetype to add..."
        static let camera = "Camera"
        static let phoneLibrary = "Phone Library"
        static let video = "Video"
        static let file = "File"
        static let alertForPhotoLibraryMessage = "App does not have access to your photos. To enable access, tap settings and turn on Photo Library Access."
        static let alertForCameraAccessMessage = "App does not have access to your camera. To enable access, tap settings and turn on Camera."
        static let alertForVideoLibraryMessage = "App does not have access to your video. To enable access, tap settings and turn on Video Library Access."
        static let settingsBtnTitle = "Settings"
        static let cancelBtnTitle = "Cancel"
        
    }
    
    //MARK: - showAttachmentActionSheet
    // This function is used to show the attachment sheet for image, video, photo and file.
    func showAttachmentActionSheet(vc: UIViewController, type: [AttachmentType]) {
        currentVC = vc
        let actionSheet = UIAlertController(title: Constants.actionFileTypeHeading, message: Constants.actionFileTypeDescription, preferredStyle: .actionSheet)
        if type.contains(.camera) {
            actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in
                self.authorisationStatus(attachmentTypeEnum: .camera, vc: self.currentVC!)
            }))
        }
        
        if type.contains(.photoLibrary) {
            actionSheet.addAction(UIAlertAction(title: Constants.phoneLibrary, style: .default, handler: { (action) -> Void in
                self.authorisationStatus(attachmentTypeEnum: .photoLibrary, vc: self.currentVC!)
            }))
        }
        
        if type.contains(.video) {
            actionSheet.addAction(UIAlertAction(title: Constants.video, style: .default, handler: { (action) -> Void in
                self.authorisationStatus(attachmentTypeEnum: .video, vc: self.currentVC!)
                
            }))
        }
        
        if type.contains(.file) {
            actionSheet.addAction(UIAlertAction(title: Constants.file, style: .default, handler: { (action) -> Void in
                self.documentPicker()
            }))
        }
        
        if type.contains(.multipleImage) {
            actionSheet.addAction(UIAlertAction(title: Constants.phoneLibrary, style: .default, handler: { (action) -> Void in
                self.multipleImagePicker()
            }))
        }
        
        if type.contains(.multipleDocument) {
            actionSheet.addAction(UIAlertAction(title: Constants.file, style: .default, handler: { (action) -> Void in
                self.multipleDocumentPicker()
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))
        
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    //MARK: - Authorisation Status
    // This is used to check the authorisation status whether user gives access to import the image, photo library, video.
    // if the user gives access, then we can import the data safely
    // if not show them alert to access from settings.
    func authorisationStatus(attachmentTypeEnum: AttachmentType, vc: UIViewController){
        currentVC = vc
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            if attachmentTypeEnum == AttachmentType.camera{
                openCamera()
            }
            if attachmentTypeEnum == AttachmentType.photoLibrary{
                photoLibrary()
            }
            if attachmentTypeEnum == AttachmentType.video{
                videoLibrary()
            }
            
        case .denied:
            log.debug("permission denied")
            self.addAlertForSettings(attachmentTypeEnum)
            
        case .notDetermined:
            log.debug("Permission Not Determined")
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == PHAuthorizationStatus.authorized{
                    // photo library access given
                    log.debug("access given")
                    if attachmentTypeEnum == AttachmentType.camera{
                        self.openCamera()
                    }
                    if attachmentTypeEnum == AttachmentType.photoLibrary{
                        self.photoLibrary()
                    }
                    if attachmentTypeEnum == AttachmentType.video{
                        self.videoLibrary()
                    }
                }else{
                    log.debug("restriced manually")
                    self.addAlertForSettings(attachmentTypeEnum)
                }
            })
        case .restricted:
            log.debug("permission restricted")
            self.addAlertForSettings(attachmentTypeEnum)
        default:
            break
        }
    }
    
    
    //MARK: - CAMERA PICKER
    func openCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            DispatchQueue.main.async {
                let myPickerController = UIImagePickerController()
                myPickerController.delegate = self
                myPickerController.sourceType = .camera
                UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.fadedBlue], for: .normal)
                UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.fadedBlue], for: .highlighted)
                self.currentVC?.present(myPickerController, animated: true, completion: nil)
            }
        }
    }
    
    //MARK: - PHOTO PICKER
    func photoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.fadedBlue], for: .normal)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.fadedBlue], for: .highlighted)
            currentVC?.present(myPickerController, animated: true, completion: nil)
            
        }
    }
    
    //MARK: - VIDEO PICKER
    func videoLibrary(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self
            myPickerController.sourceType = .photoLibrary
            myPickerController.mediaTypes = [kUTTypeMovie as String, kUTTypeVideo as String]
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.fadedBlue], for: .normal)
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.fadedBlue], for: .highlighted)
            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    //MARK: - FILE PICKER
    func documentPicker(){
        let types = [DocumentTypes.jpg.rawValue, DocumentTypes.pdf.rawValue, DocumentTypes.video.rawValue]
        let documentVC = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentVC.delegate = self
        documentVC.modalPresentationStyle = .formSheet
        currentVC?.present(documentVC, animated: true, completion: nil)
    }
    
    //MARK: - MULTİPLE IMAGE PICKER
    func multipleImagePicker() {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.settings.theme.selectionStyle = .checked
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.unselectOnReachingMax = true
        let start = Date()
        
        self.presentImagePicker(imagePicker, select: { (asset) in
            self.multiplePickBlock?(asset)
            self.fileSize += Double(asset.fileSize)
        }, deselect: { (asset) in
            log.debug("Deselected: \(asset)")
        }, cancel: { (assets) in
            log.debug("Canceled with selections: \(assets)")
        }, finish: { (assets) in
            self.multipleImagePick?(assets)
        }, completion: {
            let finish = Date()
            log.debug(finish.timeIntervalSince(start))
        })
    }
    
    func multipleDocumentPicker() {
        let types = [DocumentTypes.jpg.rawValue, DocumentTypes.pdf.rawValue, DocumentTypes.video.rawValue]
        let documentVC = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentVC.delegate = self
        if #available(iOS 11.0, *) {
            documentVC.allowsMultipleSelection = true
        }
        documentVC.delegate = self
        documentVC.modalPresentationStyle = .formSheet
        currentVC?.present(documentVC, animated: false)
    }
    
    //MARK: - SETTINGS ALERT
    func addAlertForSettings(_ attachmentTypeEnum: AttachmentType){
        var alertTitle: String = ""
        if attachmentTypeEnum == AttachmentType.camera{
            alertTitle = Constants.alertForCameraAccessMessage
        }
        if attachmentTypeEnum == AttachmentType.photoLibrary{
            alertTitle = Constants.alertForPhotoLibraryMessage
        }
        if attachmentTypeEnum == AttachmentType.video{
            alertTitle = Constants.alertForVideoLibraryMessage
        }
        
        let cameraUnavailableAlertController = UIAlertController (title: alertTitle , message: nil, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: Constants.settingsBtnTitle, style: .destructive) { (_) -> Void in
            let settingsUrl = NSURL(string:UIApplication.openSettingsURLString)
            if let url = settingsUrl {
                UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
            }
        }
        let cancelAction = UIAlertAction(title: Constants.cancelBtnTitle, style: .default, handler: nil)
        cameraUnavailableAlertController .addAction(cancelAction)
        cameraUnavailableAlertController .addAction(settingsAction)
        currentVC?.present(cameraUnavailableAlertController , animated: true, completion: nil)
    }
}

//MARK: - IMAGE PICKER DELEGATE
// This is responsible for image picker interface to access image, video and then responsibel for canceling the picker
extension AttachmentHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var img = UIImage()
        if let image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as? UIImage {
            img = image
        } else{
            log.debug("Something went wrong in  image")
        }
        var imageName = ""
        var selectedAsset: PHAsset?
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            selectedAsset = asset
            let assetResources = PHAssetResource.assetResources(for: asset)
            imageName = assetResources.first!.originalFilename
        } else {
            imageName = UUID().uuidString + ".jpg"
        }
        
        let fileManager = FileManager.default
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
        let imagePath = documentsPath?.appendingPathComponent(imageName)
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            let imageData = pickedImage.jpegData(compressionQuality: 0.75)
            try! imageData?.write(to: imagePath!)
            if let strongData = imageData {
                let data = NSData(contentsOf: imagePath!)
                fileSize += Double(data?.length ?? 0) / (1024.0*1024.0)
                imagePickedBlock?(img, strongData, imagePath, selectedAsset)
            }
            
        }
        
        if let videoUrl = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.mediaURL.rawValue)] as? NSURL{
            let data = NSData(contentsOf: videoUrl as URL)!
            fileSize += Double(data.length) / (1024.0*1024.0)
            compressWithSessionStatusFunc(videoUrl)
        }
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Video Compressing technique
    fileprivate func compressWithSessionStatusFunc(_ videoUrl: NSURL) {
        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".MOV")
        compressVideo(inputURL: videoUrl as URL, outputURL: compressedURL) { (exportSession) in
            guard let session = exportSession else {
                return
            }
            
            switch session.status {
            case .unknown:
                break
            case .waiting:
                break
            case .exporting:
                break
            case .completed:
                guard let compressedData = NSData(contentsOf: compressedURL) else {
                    return
                }
                self.fileSize += Double(compressedData.length) /  (1024.0*1024.0)
                DispatchQueue.main.async {
                    self.videoPickedBlock?(compressedURL as NSURL)
                }
                
            case .failed:
                break
            case .cancelled:
                break
            @unknown default:
                break
            }
        }
    }
    
    // Now compression is happening with medium quality, we can change when ever it is needed
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPreset1280x720) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mov
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
}

//MARK: - FILE IMPORT DELEGATE
extension AttachmentHandler:  UIDocumentPickerDelegate{
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        _ = urls.map { val in
            let data = NSData(contentsOf: val)
            self.fileSize += Double(data?.length ?? 0) / (1024.0*1024.0)
        }
        
        self.multipleFilePickBlock?(urls)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let data = NSData(contentsOf: url)
        self.fileSize += Double(data?.length ?? 0) / (1024.0*1024.0)
        self.filePickedBlock?(url)
    }
    
    //    Method to handle cancel action.
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        currentVC?.dismiss(animated: true, completion: nil)
    }
    
}

extension AttachmentHandler {
    public func presentImagePicker(_ imagePicker: ImagePickerController, animated: Bool = true, select: ((_ asset: PHAsset) -> Void)?, deselect: ((_ asset: PHAsset) -> Void)?, cancel: (([PHAsset]) -> Void)?, finish: (([PHAsset]) -> Void)?, completion: (() -> Void)? = nil) {
        authorize {
            // Set closures
            imagePicker.onSelection = select
            imagePicker.onDeselection = deselect
            imagePicker.onCancel = cancel
            imagePicker.onFinish = finish
            
            // And since we are using the blocks api. Set ourselfs as delegate
            imagePicker.imagePickerDelegate = imagePicker
            
            // Present
            self.currentVC?.present(imagePicker, animated: animated, completion: completion)
        }
    }
    
    private func authorize(_ authorized: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                DispatchQueue.main.async(execute: authorized)
            default:
                break
            }
        }
    }
}

extension PHAsset {
    var fileSize: Float {
        get {
            let resource = PHAssetResource.assetResources(for: self)
            let imageSizeByte = resource.first?.value(forKey: "fileSize") as! Float
            let imageSizeMB = imageSizeByte / (1024.0*1024.0)
            return imageSizeMB
        }
    }
}
