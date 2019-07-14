//
//  EditProfileViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 02/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseUI
import MobileCoreServices
import MBProgressHUD
import TOCropViewController
import AVFoundation
import Photos
import DropletIF

class EditProfileViewController: UITableViewController {
    
    
    @IBOutlet weak var tableHeaderViewContainer: UIView!
    //@IBOutlet weak var tableHeaderView: UIView!
    @IBOutlet var imageViews:[UIImageView]!
    @IBOutlet var imageButtons:[UIButton]!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var aboutCharacterCount: UILabel!
    @IBOutlet weak var workTextField: UITextField!
    @IBOutlet weak var schoolTextField: UITextField!
    @IBOutlet weak var communityTextField: UILabel!
    @IBOutlet weak var genderTextView: UILabel!
    
    let maximumCharacterCount = 500
    var imageIndexToReplace:Int? = nil
    var initialLoadComplete = false
    
    
    //var changesToSave:Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureForUser()
        AuthService.shared.currentUser?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTableHeaderViewHeight()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTableHeaderViewHeight(){
        guard let tableHeaderView = self.tableView.tableHeaderView else { return }
        var frame = tableHeaderView.frame
        frame.size.height = tableHeaderViewContainer.frame.size.height
        tableHeaderView.frame = frame
        self.tableView.tableHeaderView = tableHeaderView
    }
    
    func configureForUser(){
        guard let currentUser = AuthService.shared.currentUser as? CustomUser else { return }
        aboutTextView.text = currentUser.about
        textViewDidChange(aboutTextView)
        workTextField.text = currentUser.work
        schoolTextField.text = currentUser.school
        communityTextField.text = currentUser.community
        genderTextView.text = (AuthService.shared.currentUser?.gender == Genders.male.rawValue ? NSLocalizedString("EDIT_PROFILE_GENDER_SELECTED_MALE", comment: "User Selecting Own Gender Male") : (AuthService.shared.currentUser?.gender == Genders.female.rawValue ? NSLocalizedString("EDIT_PROFILE_GENDER_SELECTED_FEMALE", comment: "User Selecting Own Gender Female") : ""))
        refreshImageViews()
    }
    
    func refreshImageViews(){
        for i in 0..<imageViews.count{
            if let images = AuthService.shared.currentUser?.images, images.count > i{
                imageViews.first(where: {$0.tag == i})?.sd_setImage(with: Storage.storage().reference().child(images[i]))
                imageButtons.first(where: {$0.tag == i})?.setImage(UIImage(named:"CircleDeleteIcon"), for: .normal)
            }else{
                imageViews.first(where: {$0.tag == i})?.image = nil
                imageButtons.first(where: {$0.tag == i})?.setImage(UIImage(named:"CircleAddIcon"), for: .normal)
            }
        }
    }
    
    @IBAction func didTapImage(_ sender: Any) {
        guard let currentUser = AuthService.shared.currentUser else { return }
        var idx:Int
        if let imageView = (sender as? UITapGestureRecognizer)?.view{
            idx = imageView.tag
        }else if let button = sender as? UIButton{
            idx = button.tag
        }else{
            return
        }
        if currentUser.images.count > idx{
            //Tapped on ImageView of existing image, show remove menu
            showImageRemovalMenu(index: idx)
        }else{
            //Tapped on empty ImageView show select menu
            showImageSelectMenu(index: nil)
        }
    }
    
    func showImageRemovalMenu(index:Int){
        guard let images = AuthService.shared.currentUser?.images, images.count > 0 else {
            return
        }
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if index != 0{
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("EDIT_PROFILE_EXISTING_IMAGE_MENU_MAKE_MAIN_BUTTON", comment: "Edit Pictures Make Profile Image"), style: .default, handler: { (action) in
                //AuthService.shared.currentUser?.images
                guard var images = AuthService.shared.currentUser?.images else { return }
                images.insert(images.remove(at: index), at: 0)
                AuthService.shared.currentUser?.images = images
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("EDIT_PROFILE_EXISTING_IMAGE_MENU_REPLACE_BUTTON", comment: "Edit Pictures Replace Image"), style: .default, handler: { (action) in
            //self.imageIndexToReplace = index
            self.showImageSelectMenu(index: index)
        }))
        
        if images.count > 1{
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("EDIT_PROFILE_EXISTING_IMAGE_MENU_DELETE_BUTTON", comment: "Edit Pictures Delete Image"), style: .destructive, handler: { (action) in
                self.removePhotoAt(index: index)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("EDIT_PROFILE_EXISTING_IMAGE_MENU_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showImageSelectMenu(index:Int?){
        
        self.imageIndexToReplace = index
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //If camera available, show option
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            actionSheet.addAction(UIAlertAction(title: NSLocalizedString("EDIT_PROFILE_NEW_IMAGE_MENU_CAMERA_BUTTON", comment: "Edit Pictures Camera Button"), style: .default, handler: { (action) in
                self.presentImagePicker(usingCamera: true)
            }))
        }
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("EDIT_PROFILE_NEW_IMAGE_MENU_PHOTO_LIBRARY_BUTTON", comment: "Edit Pictures Photo Library Button"), style: .default, handler: { (action) in
            self.presentImagePicker(usingCamera: false)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("EDIT_PROFILE_NEW_IMAGE_MENU_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func removePhotoAt( index:Int){
        guard let imagePath = AuthService.shared.currentUser?.images[index] else { return }
        AuthService.shared.currentUser?.images.remove(at: index)
        removePhoto(refPath: imagePath)
    }
    
    func removePhoto(refPath:String){
        Storage.storage().reference().child(refPath).delete { (error) in
            if let error = error{
                print("Error deleting photo: \(error.localizedDescription)")
            }
        }
    }
    
    func presentImagePicker(usingCamera:Bool){
        
        if usingCamera{
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if  authorizationStatus == .denied || authorizationStatus == .restricted{
                let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("EDIT_PROFILE_CAMERA_PERMISSION_REQUIRED_ALERT_TITLE", comment: "Camera permission required alert title"), message: NSLocalizedString("EDIT_PROFILE_CAMERA_PERMISSION_REQUIRED_ALERT_BODY", comment: "Camera permission required alert body"))
                alert.addAction(title: NSLocalizedString("EDIT_PROFILE_CAMERA_PERMISSION_REQUIRED_ALERT_SETTINGS_BUTTON", comment: "Camera permission required alert settings button"), style: .default, handler: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.openURL(settingsUrl)
                    }
                })
                alert.addAction(title: NSLocalizedString("EDIT_PROFILE_CAMERA_PERMISSION_REQUIRED_ALERT_CANCEL_BUTTON", comment: "Camera permission required alert cancel button"), style: .cancel, handler: nil)
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
                    let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("EDIT_PROFILE_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_TITLE", comment: "Photo library permission required alert title"), message: NSLocalizedString("EDIT_PROFILE_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_BODY", comment: "Photo library permission required alert body"))
                    alert.addAction(title: NSLocalizedString("EDIT_PROFILE_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_SETTINGS_BUTTON", comment: "Photo library permission required alert settings button"), style: .default, handler: {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.openURL(settingsUrl)
                        }
                    })
                    alert.addAction(title: NSLocalizedString("EDIT_PROFILE_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_CANCEL_BUTTON", comment: "Photo library permission required alert cancel button"), style: .cancel, handler: nil)
                    alert.transitioningDelegate = self
                    present(alert, animated: true, completion: nil)
                    return
                }
            }
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = (usingCamera ? .camera : .photoLibrary)
        picker.mediaTypes = [kUTTypeImage as String]
        self.present(picker, animated: true, completion: nil)
    }
    
    func uploadImage(image:UIImage){
        
        let uploadHUD = MBProgressHUD.showAdded(to: view, animated: true)
        uploadHUD.mode = .annularDeterminate
        uploadHUD.label.text = NSLocalizedString("EDIT_PROFILE_HUD_IMAGE_UPLOADING", comment: "Image Uploading HUD")
        
        guard let currentUser = AuthService.shared.currentUser else { return }
        let storageLocation = "user_profile_images/\(currentUser.uid)/"
        
        StorageService.shared.uploadImage(image: image, toLocation: storageLocation, name: nil, createThumb: false, customMeta: nil, completion: { (ref, thumbRef) in
            guard currentUser.images.count < 7 else { return }
            
            if let idx = self.imageIndexToReplace, currentUser.images.count > idx{
                self.removePhoto(refPath: currentUser.images[idx])
                AuthService.shared.currentUser?.images[idx] = ref
            }else{
                AuthService.shared.currentUser?.images.append(ref)
            }
            
            DispatchQueue.main.async {
                uploadHUD.mode = .text
                uploadHUD.label.text = NSLocalizedString("EDIT_PROFILE_HUD_IMAGE_UPLOAD_COMPLETE", comment: "Image Uploading HUD Complete")
                uploadHUD.hide(animated: true, afterDelay: 2.0)
            }
            
        }, progress: { (progress) in
            DispatchQueue.main.async {
                uploadHUD.progress = progress
            }
            
        }, failed: {
            DispatchQueue.main.async {
                uploadHUD.mode = .text
                uploadHUD.label.text = NSLocalizedString("EDIT_PROFILE_HUD_IMAGE_UPLOAD_FAILED", comment: "Image Uploading HUD Failed")
                uploadHUD.hide(animated: true, afterDelay: 2.0)
            }
        })
    }
    
    // MARK: - Table View Data Source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func showImageCropView(picker:UIImagePickerController, image:UIImage){
        let cropViewController = TOCropViewController(croppingStyle: .default, image: image)
        cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = true
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.doneButtonTitle = NSLocalizedString("EDIT_PROFILE_IMAGE_CROP_DONE_BUTTON", comment: "Done Button")
        cropViewController.cancelButtonTitle = NSLocalizedString("EDIT_PROFILE_IMAGE_CROP_CANCEL_BUTTON", comment: "Cancel Button")
        cropViewController.delegate = self
        picker.pushViewController(cropViewController, animated: true)
    }

}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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

extension EditProfileViewController: TOCropViewControllerDelegate{
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        dismiss(animated: true, completion: nil)
        let resizedImage = StorageService.shared.resizeImage(image: image, size: CGSize(width: 1080, height: 1080))!
        uploadImage(image: resizedImage)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        if cancelled{
            //cropViewController.navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        }
    }
}

extension EditProfileViewController: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= maximumCharacterCount;
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let startHeight = textView.frame.size.height
        let calcHeight = textView.sizeThatFits(textView.frame.size).height
        if startHeight != calcHeight {
            UIView.setAnimationsEnabled(false) // Disable animations
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)  // Re-enable animations.
            self.tableView.layoutIfNeeded()
            
            var currentOffset = self.tableView.contentOffset
            currentOffset.y += calcHeight - startHeight
            self.tableView.setContentOffset(currentOffset, animated: false)
        }
        aboutCharacterCount.text = "\(max(maximumCharacterCount - textView.text.count,0))"
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == aboutTextView{
            AuthService.shared.currentUser?.about = textView.text
        }
    }
}

extension EditProfileViewController: UITextFieldDelegate{
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let currentUser = AuthService.shared.currentUser as? CustomUser else { return }
        if textField == workTextField{
            currentUser.work = textField.text
        }else if textField == schoolTextField{
            currentUser.school = textField.text
        }else if textField == communityTextField{
            currentUser.community = textField.text
        }
    }
}

extension EditProfileViewController: UserDelegate{
    func userUpdated() {
        configureForUser()
    }
}
