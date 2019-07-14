//
//  ChatViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreLocation
import FirebaseUI
import MBProgressHUD
import TOCropViewController
import GoogleMobileAds
import AVFoundation
import Photos
import DropletIF

class ChatViewController: UIViewController{
    
    @IBOutlet weak var profileImageView: ShapeImageView!
    @IBOutlet weak var navProfileImageView: ShapeImageView!
    @IBOutlet weak var navNameLabel: UILabel!
    
    @IBOutlet weak var noticeBar: UIView!
    @IBOutlet weak var noticeBarLabel: UILabel!
    
    @IBOutlet weak var notificationsNotice: GradientView!
    @IBOutlet weak var notificationNoticeHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var youMatchedLabel: UILabel!
    @IBOutlet weak var matchedDateLabel: UILabel!

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewMinimumHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bannerAdView: GADBannerView!
    @IBOutlet weak var bannerAdViewHeightZeroConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerAdViewHeightVisibleConstraint: NSLayoutConstraint!
    
    var maximumCharacterCount:Int = 2000
    
    @IBOutlet weak var newMessageTextView: UITextViewPlaceholder!
    @IBOutlet weak var attachmentButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var newMessageAreaBottomConstraint: NSLayoutConstraint!
    var newMessageAreaBottomInitialConstant:CGFloat = 0
    
    @IBOutlet weak var newMessageFieldTrailingToSendButtonConstraint: NSLayoutConstraint!
    @IBOutlet weak var newMessageTextFieldTrailingToAttachmentButtonConstraint: NSLayoutConstraint!
    
    var interactionController:FauxPushInteractionController?
    
    var cellLayoutInstances = [String : MessageCell]()
    
    var shouldResetScroll = true
    
    var chat:Chat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        interactionController = FauxPushInteractionController(viewController: self)
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            flowLayout.itemSize = CGSize(width: self.view.bounds.size.width, height: 1)
        }
        collectionView.contentInset = UIEdgeInsets(top: 4.0, left: 0.0, bottom: 12.0, right: 0.0)
        
        newMessageTextView.placeholder = NSLocalizedString(newMessageTextView.placeholder, comment: "Chat new message text view placeholder")
        
        registerCellNibs()
        configureNotificationsNotice()
        configureForUser()
        setupNoMessagesView()
        configureBannerAd()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ChatService.shared.addDelegate(delegate: self)
        ConnectionService.shared.addDelegate(delegate: self)
        NotificationService.shared.currentChat = chat
        NotificationCenter.default.addObserver(self, selector: #selector(configureNotificationsNotice), name: Constants.NotificationName.notificationsSettingsChanged, object: nil)
        
        configureConnectionBanner()
        configureSendButton(animated: false)
        addKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chat.markAllMessagesRead()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationService.shared.currentChat = nil
        NotificationCenter.default.removeObserver(self, name: Constants.NotificationName.notificationsSettingsChanged, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldResetScroll{
            scrollToBottom(animated: false)
            shouldResetScroll = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureBannerAd(){
        bannerAdViewHeightVisibleConstraint.priority = .defaultLow
        bannerAdViewHeightZeroConstraint.priority = .defaultHigh
        if !Config.Features.adsEnabled{
            return
        }
        if Config.Features.adsRemovedIfSubscribed && StoreService.shared.isSubscribed() {
            return
        }
        bannerAdView.delegate = self
        bannerAdView.adUnitID = Config.AdMob.chatBannerID
        bannerAdView.rootViewController = self
        bannerAdView.adSize = kGADAdSizeSmartBannerPortrait
        bannerAdView.load(AdsService.shared.getRequest())
    }
    
    func addKeyboardObservers(){
        newMessageAreaBottomInitialConstant = newMessageAreaBottomConstraint.constant
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObservers(){
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        if let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect{
            newMessageAreaBottomConstraint.constant = frame.size.height - bottomLayoutGuide.length
            
            let shouldScrollToBottom = (collectionView.contentOffset.y >= collectionView.contentSize.height - collectionView.bounds.size.height)
            self.hideNotificationNotice(animated: true)
            UIView.animate(withDuration: notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (complete) in
                if shouldScrollToBottom{
                    self.scrollToBottom(animated: true)
                }
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        newMessageAreaBottomConstraint.constant = newMessageAreaBottomInitialConstant
        UIView.animate(withDuration: notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0, animations: {
            //self.collectionView.contentOffset = currentOffset
            self.view.layoutIfNeeded()
        })
    }
    
    func registerCellNibs(){
        collectionView.register(UINib(nibName: "MessageCellTextIncoming", bundle: nil), forCellWithReuseIdentifier: "MessageCellTextIncoming")
        collectionView.register(UINib(nibName: "MessageCellTextOutgoing", bundle: nil), forCellWithReuseIdentifier: "MessageCellTextOutgoing")
        collectionView.register(UINib(nibName: "MessageCellAttachmentIncoming", bundle: nil ), forCellWithReuseIdentifier: "MessageCellAttachmentIncoming")
        collectionView.register(UINib(nibName: "MessageCellAttachmentOutgoing", bundle: nil ), forCellWithReuseIdentifier: "MessageCellAttachmentOutgoing")
        
        cellLayoutInstances["MessageCellTextIncoming"] = MessageCellTextIncoming.instanceFromNib()
        cellLayoutInstances["MessageCellTextOutgoing"] = MessageCellTextOutgoing.instanceFromNib()
        cellLayoutInstances["MessageCellAttachmentIncoming"] = MessageCellAttachmentIncoming.instanceFromNib()
        cellLayoutInstances["MessageCellAttachmentOutgoing"] = MessageCellAttachmentOutgoing.instanceFromNib()
    }
    
    func configureForUser(){
        if let image = chat.opponent.images.first{
            navProfileImageView.sd_setImage(with: Storage.storage().reference().child(image))
        }else{
            navProfileImageView.image = nil
        }
        navNameLabel.text = chat.opponent.name
    }
    
    @objc func configureNotificationsNotice(){
        //notificationNoticeHeightConstraint.priority = .init(999)
        if NotificationService.shared.notificationsEnabled{
            hideNotificationNotice(animated: false)
        }else{
            showNotificationNotice(animated: false)
        }
    }
    
    func setupNoMessagesView(){
        if let image = chat.opponent.images.first{
            profileImageView.sd_setImage(with: Storage.storage().reference().child(image))
        }else{
            profileImageView.image = nil
        }
        if let name = chat.opponent.name{
            youMatchedLabel.text = String.init(format: NSLocalizedString("CHAT_NO_MESSAGES_MATCHED_HEADING", comment: "You Match With Text"), name)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.doesRelativeDateFormatting = true
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        matchedDateLabel.text = dateFormatter.string(from: chat.updated_at)
    }
    
    func hideAttachmentButton(animated:Bool){
        newMessageFieldTrailingToSendButtonConstraint.priority = UILayoutPriority.defaultHigh
        newMessageTextFieldTrailingToAttachmentButtonConstraint.priority = UILayoutPriority.defaultLow
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.attachmentButton.alpha = 0.0
            self.view.layoutIfNeeded()
        }
    }
    
    func showAttachmentButton(animated:Bool){
        newMessageFieldTrailingToSendButtonConstraint.priority = UILayoutPriority.defaultLow
        newMessageTextFieldTrailingToAttachmentButtonConstraint.priority = UILayoutPriority.defaultHigh
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.attachmentButton.alpha = 1.0
            self.view.layoutIfNeeded()
        }
    }
    
    func configureSendButton(animated:Bool){
        if !ConnectionService.shared.connected{
            hideAttachmentButton(animated: animated)
            sendButton.isEnabled = false
        }else if !newMessageTextView.text.isEmpty && newMessageTextView.text != newMessageTextView.placeholder{
            hideAttachmentButton(animated: animated)
            sendButton.isEnabled = true
        }else{
            showAttachmentButton(animated: animated)
            sendButton.isEnabled = false
        }
    }
    
    func configureConnectionBanner(){
        if ConnectionService.shared.connected{
            noticeBar.isHidden = true
        }else{
            noticeBarLabel.text = NSLocalizedString("CHAT_CONNECTING_NOTICE", comment: "Message shown on while chat is connecting")
            noticeBar.isHidden = false
        }
    }
    
    @IBAction func didTapProfile(_ sender: Any) {
        performSegue(withIdentifier: "toProfileViewController", sender: nil)
    }
    
    @IBAction func didTapSend(_ sender: Any) {
        guard !newMessageTextView.text.isEmpty, let currentUser = AuthService.shared.currentUser else { return }
        
        //Accept auto-correct suggestions before sending without causing keyboard flash.
        newMessageTextView.inputDelegate?.selectionWillChange(newMessageTextView)
        newMessageTextView.inputDelegate?.selectionDidChange(newMessageTextView)
        
        let message = Message(chatId: chat.chatId, senderId: currentUser.uid, senderName: currentUser.name, receiverId: chat.opponent.uid, text: newMessageTextView.text)
        newMessageTextView.text = ""
        textViewDidChange(newMessageTextView)
        chat.send(message: message)
    }
    
    @IBAction func didTapAttachment(_ sender: Any) {
        showAttachmentMenu()
    }
    
    @IBAction func didTapBack(_ sender: Any) {
        newMessageTextView.resignFirstResponder()
        ChatService.shared.removeDelegate(delegate: self)
        ConnectionService.shared.removeDelegate(delegate: self)
        removeKeyboardObservers()
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapOptions(_ sender: Any) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportText:String = {
            guard let name = chat.opponent.name else { return NSLocalizedString("CHAT_REPORT_BUTTON_NO_NAME", comment: "Report Button") }
            return String(format: NSLocalizedString("CHAT_REPORT_BUTTON_WITH_NAME", comment: "Report Button (with user's name)"), name)
        }()
        actionSheet.addAction(UIAlertAction(title: reportText, style: .destructive, handler: { (action) in
            self.performSegue(withIdentifier: "toReportViewController", sender: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("CHAT_UNMATCH_BUTTON", comment: "Unmatch Button"), style: .destructive, handler: { (action) in
            self.unmatch()
        }))
        actionSheet.addAction(UIAlertAction(title: NSLocalizedString("CHAT_ACTION_SHEET_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    func unmatch(){
        let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("CHAT_UNMATCH_ALERT_TITLE", comment: "Unmatch Alert Title"), message: NSLocalizedString("CHAT_UNMATCH_ALERT_BODY", comment: "Unmatch Alert Body"))
        alert.addAction(title: NSLocalizedString("CHAT_UNMATCH_ALERT_UNMATCH_BUTTON", comment: "Unmatch Button"), style: .destructive, handler: {
            ChatService.shared.unmatch(chat: self.chat, completion: { (error) in
                if let error = error{
                    print("Error unmatching: \(error.localizedDescription)")
                    return
                }
                self.didTapBack(self)
            })
        })
        alert.addAction(title: NSLocalizedString("CHAT_UNMATCH_ALERT_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil)
        alert.transitioningDelegate = self
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAttachmentMenu(){
        let attachmentSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        //If camera available, show option
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            attachmentSheet.addAction(UIAlertAction(title: NSLocalizedString("CHAT_ATTACHMENTS_CAMERA_BUTTON", comment: "Attachment Select Menu"), style: .default, handler: { (action) in
                self.showPicker(isCamera: true)
            }))
        }
        
        //If library available, show option
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            attachmentSheet.addAction(UIAlertAction(title: NSLocalizedString("CHAT_ATTACHMENTS_PHOTO_LIBRARY_BUTTON", comment: "Attachment Select Menu"), style: .default, handler: { (action) in
                self.showPicker(isCamera: false)
            }))
        }
        
//        attachmentSheet.addAction(UIAlertAction(title: NSLocalizedString("CHAT_ATTACHMENTS_LOCATION_BUTTON", comment: "Attachment Select Menu"), style: .default, handler: { (action) in
//            guard let location = LocationService.shared.currentLocation else { return }
//            self.performSegue(withIdentifier: "showLocationAttachmentView", sender: location)
//        }))
        attachmentSheet.addAction(UIAlertAction(title: NSLocalizedString("CHAT_ATTACHMENTS_ACTION_SHEET_CANCEL_BUTTON", comment: "Cancel Button"), style: .cancel, handler: nil))
        present(attachmentSheet, animated: true, completion: nil)
    }
    
    func showPicker(isCamera:Bool){
        if isCamera{
            let authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if  authorizationStatus == .denied || authorizationStatus == .restricted{
                let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("CHAT_ATTACHMENTS_CAMERA_PERMISSION_REQUIRED_ALERT_TITLE", comment: "Camera permission required alert title"), message: NSLocalizedString("CHAT_ATTACHMENTS_CAMERA_PERMISSION_REQUIRED_ALERT_BODY", comment: "Camera permission required alert body"))
                alert.addAction(title: NSLocalizedString("CHAT_ATTACHMENTS_CAMERA_PERMISSION_REQUIRED_ALERT_SETTINGS_BUTTON", comment: "Camera permission required alert settings button"), style: .default, handler: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.openURL(settingsUrl)
                    }
                })
                alert.addAction(title: NSLocalizedString("CHAT_ATTACHMENTS_CAMERA_PERMISSION_REQUIRED_ALERT_CANCEL_BUTTON", comment: "Camera permission required alert cancel button"), style: .cancel, handler: nil)
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
                    let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("CHAT_ATTACHMENTS_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_TITLE", comment: "Photo library permission required alert title"), message: NSLocalizedString("CHAT_ATTACHMENTS_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_BODY", comment: "Photo library permission required alert body"))
                    alert.addAction(title: NSLocalizedString("CHAT_ATTACHMENTS_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_SETTINGS_BUTTON", comment: "Photo library permission required alert settings button"), style: .default, handler: {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.openURL(settingsUrl)
                        }
                    })
                    alert.addAction(title: NSLocalizedString("CHAT_ATTACHMENTS_PHOTO_LIBRARY_PERMISSION_REQUIRED_ALERT_CANCEL_BUTTON", comment: "Photo library permission required alert cancel button"), style: .cancel, handler: nil)
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
        picker.mediaTypes = [kUTTypeImage as String]//,kUTTypeMovie as String]
        self.present(picker, animated: true, completion: nil)
    }

    func scrollToBottom(animated:Bool){
        let lastItemIdx = collectionView.numberOfItems(inSection: 0) - 1
        guard lastItemIdx > -1 else { return }
        collectionView.scrollToItem(at: IndexPath(item: lastItemIdx, section: 0), at: .bottom, animated: animated)
    }
    
    func showImageCropView(picker:UIImagePickerController, image:UIImage){
        let cropViewController = TOCropViewController(croppingStyle: .default, image: image)
        //cropViewController.aspectRatioPreset = .presetSquare
        cropViewController.aspectRatioLockEnabled = false
        cropViewController.resetAspectRatioEnabled = false
        cropViewController.aspectRatioPickerButtonHidden = true
        cropViewController.doneButtonTitle = NSLocalizedString("CHAT_ATTACHMENT_IMAGE_CROP_DONE_BUTTON", comment: "Crop Attachment Done Button")
        cropViewController.cancelButtonTitle = NSLocalizedString("CHAT_ATTACHEMENT_IMAGE_CROP_CANCEL_BUTTON", comment: "Crop Attachment Back Button")
        cropViewController.delegate = self
        picker.pushViewController(cropViewController, animated: true)
    }
    
    func sendImage(image:UIImage){
        let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD.mode = .annularDeterminate
        chat.sendImage(image: image, completion: {
            progressHUD.hide(animated: true)
            if let interstitial = AdsService.shared.getInterstitial(){
                interstitial.present(fromRootViewController: self)
            }
        }, progress: { (progress) in
            progressHUD.progress = progress
        }, error: {
            progressHUD.mode = .text
            progressHUD.detailsLabel.text = NSLocalizedString("CHAT_ATTACHEMENT_IMAGE_SEND_FAILED", comment: "Image send failed HUD message")
            progressHUD.hide(animated: true, afterDelay: 3.0)
        })
    }
    
    func cellIdentifier(for message:Message) -> String{
        var cellIdentifier = "MessageCell"
        switch(message.type){
        case .text:
            cellIdentifier += "Text"
        case .image, .location, .video:
            cellIdentifier += "Attachment"
        default:
            cellIdentifier += "Attachment"
        }
        cellIdentifier += (AuthService.shared.currentUser?.uid == message.senderId ? "Outgoing" : "Incoming")
        return cellIdentifier
    }

    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = (segue.destination as? UINavigationController)?.viewControllers.first as? LocationAttachmentViewController{
            if let message = sender as? Message{
                destVC.configureForMessage(message: message)
            }else{
                destVC.configureForCurrentLocation(delegate: self)
            }
        }else if let destVC = segue.destination as? ProfileViewController{
            destVC.transitioningDelegate = self
            destVC.user = chat.opponent as! CustomUser
        }else if let destVC = segue.destination as? ReportViewController{
            destVC.transitioningDelegate = self
            destVC.user = chat.opponent
            destVC.delegate = self
        }else if let destVC = (segue.destination as? UINavigationController)?.viewControllers.first as? ImageAttachmentViewController, let message = sender as? Message{
            destVC.configureForMessage(message: message)
        }
    }
    
    deinit {
        print("Chat deinited")
    }
    
}

extension ChatViewController{
    
    func showNotificationNotice(animated:Bool){
        DispatchQueue.main.async {
            self.notificationNoticeHeightConstraint.priority = .defaultLow
            self.view.updateConstraintsIfNeeded()
            UIView.animate(withDuration: animated ? 0.2 : 0.0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func hideNotificationNotice(animated:Bool){
        DispatchQueue.main.async {
            self.notificationNoticeHeightConstraint.priority = .init(999)
            self.view.updateConstraintsIfNeeded()
            UIView.animate(withDuration: animated ? 0.2 : 0.0) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func didTapCloseNotificationsNotice(_ sender: Any) {
        hideNotificationNotice(animated: true)
    }
    
    @IBAction func didTapEnableNotifications(_ sender: Any) {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.openURL(settingsUrl)
        }
    }
}

extension ChatViewController: UICollectionViewDataSource{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = chat.messages.count
        collectionView.isHidden = (count == 0)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = chat.getMessages()[indexPath.row] //chat.messages[indexPath.row]
        
        let cellIdentifier = self.cellIdentifier(for: message)
        var cell:MessageCell
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MessageCell
        cell.delegate = self
        cell.configureCell(message: message, user: chat.opponent)
        cell.setCellWidth(width: (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize.width)
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "olderMessagesLoadingView", for: indexPath)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let message = chat.getMessages()[indexPath.row]
        let cellIdentifier = self.cellIdentifier(for: message)
        guard let cellLayoutInstance = cellLayoutInstances[cellIdentifier] else { return CGSize.zero }
        let itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        return cellLayoutInstance.calculateCellSize(message: message, itemSize: itemSize)
    }
}

extension ChatViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = chat.getMessages()[indexPath.row]
        if message.type == .image{
            performSegue(withIdentifier: "toImageAttachmentViewController", sender: message)
        }else if message.type == .location{
            self.performSegue(withIdentifier: "showLocationAttachmentView", sender: message)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 44.0{
            chat.loadOlderMessages()
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        shouldResetScroll = false
    }
}

extension ChatViewController: UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if !chat.haveOlderMessages{
            return CGSize(width: 0.1, height: 0.1)
        }
        return (collectionViewLayout as! UICollectionViewFlowLayout).headerReferenceSize
    }
}

extension ChatViewController: MessageCellDelegate{
    func didTapProfile() {
        performSegue(withIdentifier: "toProfileViewController", sender: nil)
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        if mediaType == kUTTypeImage as String{
            guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            showImageCropView(picker: picker, image: image)
            //self.sendImage(image: image)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
}

extension ChatViewController: TOCropViewControllerDelegate{
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        dismiss(animated: true, completion: nil)
        self.sendImage(image: image)
    }
    
    func cropViewController(_ cropViewController: TOCropViewController, didFinishCancelled cancelled: Bool) {
        if cancelled{
            dismiss(animated: true) {
                if let interstitial = AdsService.shared.getInterstitial(){
                    interstitial.present(fromRootViewController: self)
                }
            }
        }
    }
}

extension ChatViewController: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        
        // Cut down text if exceeds character limit (i.e. from pasting)
        if textView.text.count > maximumCharacterCount{
            textView.text = String(textView.text.prefix(maximumCharacterCount))
        }
        
        configureSendButton(animated: true)
        
        let prevScrollEnabled = textView.isScrollEnabled
        textView.isScrollEnabled = !textViewSizeDoesFit(textView: textView)
        if textView.isScrollEnabled != prevScrollEnabled{
            textView.setNeedsUpdateConstraints()
        }
    }
    
    func textViewSizeDoesFit(textView:UITextView)->Bool{
        if collectionView.bounds.size.height <= collectionViewMinimumHeightConstraint.constant
            && textView.contentSize.height >= textView.bounds.size.height{
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let textView = textView as? UITextViewPlaceholder else { return }
        if textView.text == textView.placeholder{
            textView.text = ""
            textView.textColor = textView.defaultTextColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let textView = textView as? UITextViewPlaceholder else { return }
        if textView.text.count == 0{
            textView.text = textView.placeholder
            textView.textColor = textView.placeholderTextColor
        }
    }
}

extension ChatViewController: ConnectionServiceDelegate{
    
}

extension ChatViewController: ChatServiceDelegate {
    func chatDidLoadOldMessages(chat:Chat, count:Int){
        guard chat.chatId == self.chat.chatId else { return }
        
        if count == 0{
            collectionView.reloadData()
            return
        }
        
        let contentHeight = self.collectionView.contentSize.height
        let offsetY = self.collectionView.contentOffset.y
        let bottomOffset = contentHeight - offsetY
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        self.collectionView!.performBatchUpdates({
            var indexPaths = [IndexPath]()
            for i in 0..<count {
                let index = 0 + i
                indexPaths.append(IndexPath(item: index, section: 0))
            }
            if indexPaths.count > 0 {
                self.collectionView!.insertItems(at: indexPaths)
            }
        }, completion: {
            complete in
            self.collectionView!.contentOffset = CGPoint(x: 0, y: self.collectionView.contentSize.height - bottomOffset)
            CATransaction.commit()
        })
    }
    
    func chatDidReceiveMessage(chat: Chat, message: Message, isNew: Bool) {
        guard chat.chatId == self.chat.chatId else { return }
        chat.markAllMessagesRead()
        DispatchQueue.main.async{
            self.collectionView.reloadData()
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.layoutIfNeeded()
            if isNew{
                self.scrollToBottom(animated: false)
            }
        }
    }
    
    func didReceiveNewMatch() {
        //
    }
    
    func chatUpdated(chat: Chat, deleted: Bool) {
        if deleted{
            didTapBack(self)
        }
    }
    
    func connectionStatusChanged() {
        configureSendButton(animated: true)
        configureConnectionBanner()
    }
}

extension ChatViewController: LocationAttachmentDelegate{
    func sendLocation(location: CLLocation?) {
        if let location = location{
            chat.sendLocation(location: location)
        }
    }
}

extension ChatViewController: ReportViewControllerDelegate{
    func didCancelReport() {
        dismiss(animated: true) {
            if let interstitial = AdsService.shared.getInterstitial(){
                interstitial.present(fromRootViewController: self)
            }
        }
    }
    
    func didSendReport(user: User) {
        dismiss(animated: true) {
            if let interstitial = AdsService.shared.getInterstitial(){
                interstitial.present(fromRootViewController: self)
            }
        }
    }
}

extension ChatViewController: GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerAdViewHeightZeroConstraint.priority = .defaultLow
        bannerAdViewHeightVisibleConstraint.priority = .defaultHigh
        self.view.updateConstraintsIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
        bannerAdViewHeightZeroConstraint.priority = .defaultHigh
        bannerAdViewHeightVisibleConstraint.priority = .defaultLow
        self.view.updateConstraintsIfNeeded()
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}
