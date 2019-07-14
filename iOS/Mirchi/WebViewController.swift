//
//  WebViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 05/10/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    
    @IBOutlet weak var navigationCloseButton: UIBarButtonItem!
    let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
    var webView: WKWebView!
    var url:URL?
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCloseButton()
        setupLoadingIndicator()
        
        if let url = url{
            let myRequest = URLRequest(url: url)
            webView.load(myRequest)
        }
    }
    
    func configureCloseButton(){
        if self.navigationController?.restorationIdentifier != "WebViewNavigationController"{
            //self.navigationCloseButton.
            if let idx = self.navigationItem.leftBarButtonItems?.firstIndex(of: navigationCloseButton){
                self.navigationItem.leftBarButtonItems?.remove(at: idx)
            }
        }
    }
    
    func setupLoadingIndicator(){
        //activityIndicator.color = Colors.darkPurple
        self.navigationItem.titleView = activityIndicator
        activityIndicator.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WKNavigationDelegate{
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Error loading page: \(error.localizedDescription)")
    }
}
