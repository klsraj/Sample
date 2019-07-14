//
//  InterestedInViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 08/12/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class InterestedInViewController: AuthFormBaseViewController {

    @IBOutlet weak var menButton: ShapeButton!
    @IBOutlet weak var womenButton: ShapeButton!
    @IBOutlet weak var menWomenButton: ShapeButton!
    var selectedInterestedIn:Genders?{
        didSet{
            continueButton.isEnabled = (selectedInterestedIn != nil && !selectedInterestedIn!.isEmpty)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let rawInterestedIn = AuthService.shared.currentUser?.interestedIn{
            let interestedIn = Genders.init(rawValue: rawInterestedIn)
            
            if interestedIn == Genders.male{
                didTapMen(self)
            }else if interestedIn == Genders.female{
                didTapWomen(self)
            }else if interestedIn == Genders.maleAndFemale{
                didTapMenAndWomen(self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapMen(_ sender: Any) {
        menButton.isSelected = true
        womenButton.isSelected = false
        menWomenButton.isSelected = false
        selectedInterestedIn = Genders.male
    }

    @IBAction func didTapWomen(_ sender: Any) {
        menButton.isSelected = false
        womenButton.isSelected = true
        menWomenButton.isSelected = false
        selectedInterestedIn = Genders.female
    }
    
    @IBAction func didTapMenAndWomen(_ sender: Any) {
        menButton.isSelected = false
        womenButton.isSelected = false
        menWomenButton.isSelected = true
        selectedInterestedIn = Genders.maleAndFemale
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        guard AuthService.shared.currentUser != nil, let interestedIn = selectedInterestedIn?.rawValue else { return }
        AuthService.shared.currentUser!.interestedIn = interestedIn
        self.performSegue(withIdentifier: "toPictureViewController", sender: nil)
    }
    
    @IBAction func unwindToInterestedInSelect(sender: UIStoryboardSegue){
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
    
    
}
