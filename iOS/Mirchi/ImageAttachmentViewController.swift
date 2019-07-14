//
//  ImageAttachmentViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 25/09/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import FirebaseUI
import DropletIF

class ImageAttachmentViewController: UIViewController{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureForMessage(message:Message){
        guard let attachmentRef = message.attachmentRef else { return }
        //Force load view hierarchy
        self.loadViewIfNeeded()
        //imageView.sd_setImage(with: Storage.storage().reference().child(attachmentRef))
        imageView.sd_setImage(with: Storage.storage().reference().child(attachmentRef), placeholderImage: nil) { (image, error, cacheType, ref) in
            if let imageWidth = image?.size.width{
                self.scrollView.maximumZoomScale = max(1, imageWidth / self.view.bounds.size.width)
            }
            SDImageCache.shared().removeImage(forKey: ref.fullPath, fromDisk: false, withCompletion: {
                print("Removed image from cache")
            })
        }
    }
    
    @IBAction func didTapAction(_ sender: Any) {
        guard let image = imageView.image else { return }
        let activitySheet = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(activitySheet, animated: true, completion: nil)
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension ImageAttachmentViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
