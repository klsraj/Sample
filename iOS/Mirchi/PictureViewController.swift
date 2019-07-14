//
//  PictureViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/11/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import MobileCoreServices
import MBProgressHUD
import TOCropViewController
import DropletIF
import UserNotifications
import AVFoundation
import Photos
import SDWebImage

class PictureViewController: AuthFormBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let currentUser = AuthService.shared.currentUser else {
            AuthService.shared.logout(onComplete: {
                self.navigationController?.popToRootViewController(animated: true)
            }, onError: nil)
            return
        }
        if currentUser.images.count > 0{
            profileSetupComplete()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func didTapSelectPicture(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //If camera available, show option
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("PICTURE_ENTRY_CAMERA_BUTTON", comment: "Add Picture Camera Button"), style: .default, handler: { (action) in
                self.showPicker(isCamera: true)
            }))
        }
        
        //If library available, show option
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("PICTURE_ENTRY_PHOTO_LIBRARY_BUTTON", comment: "Add Picture Photo Library Button"), style: .default, handler: { (action) in
                self.showPicker(isCamera: false)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("PICTURE_ENTRY_ACTIVITY_SHEET_CLOSE_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showPicker(isCamera:Bool){
        if isCamera{
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if  authorizationStatus == .denied || authorizationStatus == .restricted{
                let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("PICTURE_ENTRY_CAMERA_PERMISSION_REQUIRED_ALERT_TITLE", comment: "Camera permission required alert title"), message: NSLocalizedString("PICTURE_ENTRY_CAMERA_PERMISSION_REQUIRED_ALERT_BODY", comment: "Camera permission required alert body"))
                alert.addAction(title: NSLocalizedString("PICTURE_ENTRY_CAMERA_PERMISSION_REQUIRED_ALERT_SETTINGS_BUTTON", comment: "Camera permission required alert settings button"), style: .default, handler: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.openURL(settingsUrl)
                    }
                })
                alert.addAction(title: NSLocalizedString("PICTURE_ENTRY_CAMERA_PERMISSION_REQUIRED_ALERT_CANCEL_BUTTON   ", comment: "Camera permission required alert cancel button"), style: .cancel, handler: nil)
                alert.transitioningDelegate = self
                present(alert, animated: true, completion: nil)
                return
            }
        }else{
            if #available(iOS 11.0, *){
                //Photo Library permission not required in iOS 11
            }else{
                let authorizationStatus = PHPhotoLibrary.authorizationStatus()
                if  authorizationStatus == .denied || authorizationStatus == .restricted{
                    let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("PICTURE_ENTRY_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_TITLE", comment: "Photo library permission required alert title"), message: NSLocalizedString("PICTURE_ENTRY_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_BODY", comment: "Photo library permission required alert body"))
                    alert.addAction(title: NSLocalizedString("PICTURE_ENTRY_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_SETTINGS_BUTTON", comment: "Photo library permission required alert settings button"), style: .default, handler: {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.openURL(settingsUrl)
                        }
                    })
                    alert.addAction(title: NSLocalizedString("PICTURE_ENTRY_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_CANCEL_BUTTON   ", comment: "Photo library permission required alert cancel button"), style: .cancel, handler: nil)
                    alert.transitioningDelegate = self
                    present(alert, animated: true, completion: nil)
                    return
                }
            }
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = (isCamera ? .camera : .photoLibrary)
        picker.mediaTypes = [kUTTypeImage as String]
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func didTapBack(_ sender: UIButton) {
        guard let navVCs = navigationController?.viewControllers, navVCs.count > 1 else { return }
        if let _ = navVCs[navVCs.count - 2] as? InterestedInViewController{
            navigationController?.popViewController(animated: true)
        }else{
            AuthService.shared.logout(onComplete: {
                self.navigationController?.popToRootViewController(animated: true)
            }, onError: nil)
        }
    }
    
    func showImageCropView(picker:UIImagePickerController, image:UIImage){
        let cropViewController = TOCropViewController(croppingStyle: .default, image: image)
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.doneButtonTitle = NSLocalizedString("PICTURE_ENTRY_CROP_VIEW_DONE_BUTTON", comment: "Done Button")
        cropViewController.cancelButtonTitle = NSLocalizedString("PICTURE_ENTRY_CROP_VIEW_CANCEL_BUTTON", comment: "Cancel Button")
        cropViewController.delegate = self
        picker.pushViewController(cropViewController, animated: true)
    }

    func uploadImage(image:UIImage, complete:@escaping ()->Void){
        
        let uploadHUD = MBProgressHUD.showAdded(to: view, animated: true)
        uploadHUD.mode = .annularDeterminate
        uploadHUD.label.text = NSLocalizedString("PICTURE_ENTRY_IMAGE_UPLOADING", comment: "Uploading Progress HUD")
        
        guard let currentUser = AuthService.shared.currentUser else { return }
        let storageLocation = "user_profile_images/\(currentUser.uid)/"
        
        StorageService.shared.uploadImage(image: image, toLocation: storageLocation, name: nil, createThumb: false, customMeta: nil, completion: { (ref, thumbRef) in
            guard currentUser.images.count < 7 else { return }
            AuthService.shared.currentUser?.images.append(ref)
            SDImageCache.shared().store(image, imageData: nil, forKey: ref, toDisk: true, completion: nil)
            DispatchQueue.main.async {
                uploadHUD.mode = .text
                uploadHUD.label.text = NSLocalizedString("PICTURE_ENTRY_IMAGE_UPLOAD_COMPLETE", comment: "Uploading Progress HUD")
                uploadHUD.hide(animated: true, afterDelay: 2.0)
            }
            complete()
            
        }, progress: { (progress) in
            DispatchQueue.main.async {
                uploadHUD.progress = progress
            }
            
        }, failed: {
            DispatchQueue.main.async {
                uploadHUD.mode = .text
                uploadHUD.label.text = NSLocalizedString("PICTURE_ENTRY_IMAGE_UPLOAD_FAILED", comment: "Uploading Progress HUD")
                uploadHUD.hide(animated: true, afterDelay: 2.0)
            }
        })
    }
    
    func profileSetupComplete(){
        if let rootVC = UIApplication.shared.delegate?.window??.rootViewController as? RootViewController{
            AuthService.shared.delegate = rootVC
            rootVC.didLogin()
        }
    }
}

extension PictureViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        if mediaType == kUTTypeImage as String{
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage ?? info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
                showImageCropView(picker: picker, image: image)
                return
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension PictureViewController: TOCropViewControllerDelegate{
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        dismiss(animated: true, completion: nil)
        let resizedImage = StorageService.shared.resizeImage(image: image, size: CGSize(width: 1080, height: 1080))!
        uploadImage(image: resizedImage, complete: {
            self.profileSetupComplete()
        })
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        if cancelled{
            dismiss(animated: true, completion: nil)
        }
    }
}
