//
//  UpgradeViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 06/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import MBProgressHUD
import StoreKit
import DropletIF

class UpgradeViewController: UIViewController {
    
    @IBOutlet weak var featuresScrollView: UIScrollView!
    @IBOutlet weak var featuresPageControl: UIPageControl!
    
    @IBOutlet weak var disclaimerTextView: UITextView!
    //@IBOutlet var priceButtons:[UpgradePriceButton]!
    @IBOutlet weak var loadingProductsView: UIView!
    @IBOutlet weak var monthlyButton: ShapeButton!
    @IBOutlet weak var biannuallyButton: ShapeButton!
    @IBOutlet weak var annuallyButton: ShapeButton!
    
    /*Auto-renews. Cancel any time.
    */
    
    var autoScrollTimer:Timer?
    var progressHUD:MBProgressHUD?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureDisclaimer()
        
        if StoreService.shared.shouldLoadProducts(){
            loadingProductsView.isHidden = false
            StoreService.shared.validateProductIdentifiers()
        }else{
            loadingProductsView.isHidden = true
            configurePriceButtons()
        }
        
        initAutoScrollTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        StoreService.shared.delegate = self
        configurePageControl()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        StoreService.shared.delegate = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Fix content offset issue
        disclaimerTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    func configureDisclaimer(){
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let disclaimer = NSMutableAttributedString(string: NSLocalizedString("UPGRADE_DISCLAIMER_TITLE", comment: "Upgrade popup dislcaimer title"), attributes: [
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 11.0),
            NSAttributedString.Key.foregroundColor : disclaimerTextView.textColor as Any,
            NSAttributedString.Key.paragraphStyle : paragraphStyle
        ])
        let disclaimerBodyString = String(format: NSLocalizedString("UPGRADE_DISCLAIMER_BODY", comment: "Upgrade popup dislcaimer body with terms and privacy links"), NSLocalizedString("UPGRADE_DISCLAIMER_TERMS_LINK", comment: "Terms of Service Link"), NSLocalizedString("UPGRADE_DISCLAIMER_PRIVACY_LINK", comment: "Privacy Policy Link"))
        disclaimer.append(NSAttributedString(string: disclaimerBodyString, attributes: [
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 11.0),
            NSAttributedString.Key.foregroundColor : disclaimerTextView.textColor?.withAlphaComponent(0.5) as Any,
            NSAttributedString.Key.paragraphStyle : paragraphStyle
        ]))
        
        let termsRange = (disclaimer.string as NSString).range(of: NSLocalizedString("UPGRADE_DISCLAIMER_TERMS_LINK", comment: "Terms of Service Link"))
        let privacyRange = (disclaimer.string as NSString).range(of: NSLocalizedString("UPGRADE_DISCLAIMER_PRIVACY_LINK", comment: "Privacy Policy Link"))
        disclaimer.addAttribute(NSAttributedString.Key.link, value: URL(string: "termslink") as Any, range: termsRange)
        disclaimer.addAttribute(NSAttributedString.Key.link, value: URL(string: "privacylink") as Any, range: privacyRange)
        
        disclaimerTextView.linkTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        disclaimerTextView.attributedText = disclaimer
    }
    
    func initAutoScrollTimer(){
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 4, target: self, selector: #selector(toNextPage), userInfo: nil, repeats: true)
    }
    
    func configurePageControl(){
        featuresScrollView.layoutIfNeeded()
        featuresPageControl.numberOfPages = Int(ceil(featuresScrollView.contentSize.width / featuresScrollView.bounds.size.width))
    }
    
    func configurePriceButtons(){
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        
        guard let monthly = StoreService.shared.products[Config.ProductID.monthly] as? SKProduct, let biannually = StoreService.shared.products[Config.ProductID.biannually] as? SKProduct, let annually = StoreService.shared.products[Config.ProductID.annually] as? SKProduct else { return }
        
        formatter.locale = monthly.priceLocale
        monthlyButton.setTitle(String.init(format: NSLocalizedString("UPGRADE_ONE_MONTH_PRICE_BUTTON", comment: "Monthly Upgrade Duration/Price Button"), formatter.string(from: monthly.price)!), for: .normal)
        
        formatter.locale = biannually.priceLocale
        biannuallyButton.setTitle(String.init(format: NSLocalizedString("UPGRADE_SIX_MONTHS_PRICE_BUTTON", comment: "Biannually Upgrade Duration/Price Button"), formatter.string(from: biannually.price)!), for: .normal)
        
        formatter.locale = monthly.priceLocale
        annuallyButton.setTitle(String.init(format: NSLocalizedString("UPGRADE_TWELVE_MONTHS_PRICE_BUTTON", comment: "Annually Upgrade Duration/Price Button"), formatter.string(from: annually.price)!), for: .normal)
        
        loadingProductsView.isHidden = true
    }
    
    @objc func toNextPage(){
        let toPage = featuresPageControl.currentPage + 1 < featuresPageControl.numberOfPages ? featuresPageControl.currentPage + 1 : 0
        featuresScrollView.setContentOffset(CGPoint(x: CGFloat(toPage) * featuresScrollView.bounds.size.width, y: 0), animated: true)
    }

    @IBAction func didTapOutside(_ sender: UITapGestureRecognizer) {
        let view = sender.view
        let loc = sender.location(in: view)
        if view?.hitTest(loc, with: nil) == sender.view{
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapContinue(_ sender: UIButton) {
        var product:SKProduct?
        switch(sender.tag){
        case 0:
            product = StoreService.shared.products[Config.ProductID.monthly] as? SKProduct
        case 1:
            product = StoreService.shared.products[Config.ProductID.biannually] as? SKProduct
        case 2:
            product = StoreService.shared.products[Config.ProductID.annually] as? SKProduct
        default:
            return
        }
        guard product != nil else{
            let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("UPGRADE_PRODUCT_NOT_LOADED_ERROR_ALERT_TITLE", comment: "Error Alert Title"), message: NSLocalizedString("UPGRADE_PRODUCT_NOT_LOADED_ERROR_ALERT_BODY", comment: "Cannot Connect to Itunes Store Error"))
            alert.addAction(title: NSLocalizedString("UPGRADE_PRODUCT_NOT_LOADED_ERROR_ALERT_CLOSE_BUTTON", comment: "Dismiss Button"), style: .cancel, handler: nil)
            alert.transitioningDelegate = self
            present(alert, animated: true, completion: nil)
            return
        }
        let payment = SKPayment(product: product!)
        SKPaymentQueue.default().add(payment)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toVc = (segue.destination as? UINavigationController)?.viewControllers.first as? WebViewController, let url = sender as? URL{
            toVc.url = url
        }
    }
}

extension UpgradeViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x / scrollView.bounds.size.width))
        featuresPageControl.currentPage = page
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        autoScrollTimer?.invalidate()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        initAutoScrollTimer()
    }
}

extension UpgradeViewController: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldInteractWith tappedUrl: URL, in characterRange: NSRange) -> Bool {
        if tappedUrl.absoluteString == "termslink"{
            performSegue(withIdentifier: "toWebViewController", sender: URL(string: NSLocalizedString("TERMS_OF_USE_URL", comment: "")))
            return false
        }else if tappedUrl.absoluteString == "privacylink"{
            performSegue(withIdentifier: "toWebViewController", sender: URL(string: NSLocalizedString("PRIVACY_POLICY_URL", comment: "")))
            return false
        }
        return true
    }
}

extension UpgradeViewController: StoreServiceDelegate{
    func productsLoadComplete(error: Error?) {
        if let error = error{
            print("Error loading products: \(error.localizedDescription)")
            return
        }
        configurePriceButtons()
    }
    
    func transactionInProgress() {
        progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        progressHUD!.mode = .indeterminate
        progressHUD!.label.text = nil
        progressHUD!.detailsLabel.text = nil
    }
    
    func transactionFailed(transaction: SKPaymentTransaction) {
        if let error = transaction.error{
            let alert = CustomAlertViewController.instantiate(title: NSLocalizedString("UPGRADE_PURCHASE_FAILED_ERROR_ALERT_TITLE", comment: "Error Alert Title"), message: error.localizedDescription)
            alert.addAction(title: NSLocalizedString("UPGRADE_PURCHASE_FAILED_ERROR_ALERT_CLOSE_BUTTON", comment: "Dismiss Button"), style: .cancel, handler: nil)
            alert.transitioningDelegate = self
            present(alert, animated: true, completion: nil)
        }
        if progressHUD == nil{
            progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        }else{
            progressHUD!.show(animated: true)
        }
        progressHUD!.mode = .text
        progressHUD!.label.text = NSLocalizedString("UPGRADE_HUD_PURCHASE_FAILED", comment: "Upgrade HUD Purchase Failed")
        progressHUD!.detailsLabel.text = nil
        progressHUD!.hide(animated: true, afterDelay: 2.5)
    }
    
    func validatingReceipt(transaction: SKPaymentTransaction) {
        if progressHUD == nil{
            progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        }else{
            progressHUD!.show(animated: true)
        }
        progressHUD!.mode = .indeterminate
        progressHUD!.detailsLabel.text = NSLocalizedString("UPGRADE_HUD_VALIDATING_PURCHASE", comment: "Upgrade HUD Validating")
        progressHUD!.label.text = nil
    }
    
    func transactionComplete(transaction: SKPaymentTransaction) {
        if progressHUD == nil{
            progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        }else{
            progressHUD!.show(animated: true)
        }
        progressHUD!.mode = .text
        progressHUD!.label.text = (transaction.transactionState == .restored ? NSLocalizedString("UPGRADE_HUD_RESTORE_COMPLETE", comment: "Upgrade HUD Restore Complete") : NSLocalizedString("UPGRADE_HUD_PURCHASE_COMPLETE", comment: "Upgrade HUD Purchase Complete"))
        progressHUD!.detailsLabel.text = nil
        progressHUD!.hide(animated: true, afterDelay: 2.5)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
