//
//  BaseLimitViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 23/01/2018.
//  Copyright © 2018 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class BaseLimitViewController: UIViewController {
    
    @IBOutlet weak var upgradeButton: ShapeButton!
    @IBOutlet weak var countdownLabel: UILabel!
    var startDate:Date?
    var timer:Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initCountdownTimer()
        updateCountdownTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        timer?.invalidate()
    }
    
    func initCountdownTimer(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdownTimer), userInfo: nil, repeats: true)
        countdownLabel.font = UIFont.monospacedDigitSystemFont(ofSize: countdownLabel.font.pointSize, weight: .medium)
    }
    
    @objc func updateCountdownTimer(){
        guard let startDate = self.startDate else { return }
        let interval = Int(startDate.timeIntervalSince(Date()))
        if(interval <= 0){
            presentingViewController?.dismiss(animated: true, completion: nil)
            self.timer?.invalidate()
            return
        }
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        countdownLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        
    }
    
    @IBAction func didTapUpgrade(_ sender: Any) {
        guard !StoreService.shared.isSubscribed() else {
            presentingViewController?.dismiss(animated: true, completion: nil)
            return
        }
        if let upgradeVC = UIStoryboard(name: "upgrade", bundle: nil).instantiateInitialViewController(), let presentingVC = presentingViewController{
            presentingVC.dismiss(animated: true, completion: {
                presentingVC.present(upgradeVC, animated: true, completion: nil)
            })
        }
    }
    
    @IBAction func didTapOutside(_ sender: UITapGestureRecognizer) {
        let view = sender.view
        let loc = sender.location(in: view)
        if view?.hitTest(loc, with: nil) == sender.view{
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("Like Limit Controller Deinit")
    }

}
