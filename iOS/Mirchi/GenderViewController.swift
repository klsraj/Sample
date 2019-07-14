//
//  GenderViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 16/11/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class GenderViewController: AuthFormBaseViewController {
    
    @IBOutlet weak var femaleButton: ShapeButton!
    @IBOutlet weak var maleButton: ShapeButton!
    var selectedGender:Genders?{
        didSet{
            continueButton.isEnabled = (selectedGender != nil && !selectedGender!.isEmpty)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let rawGender = AuthService.shared.currentUser?.gender{
            let gender = Genders.init(rawValue: rawGender)
            
            if gender == Genders.male{
                didTapMale(self)
            }else if gender == Genders.female{
                didTapFemale(self)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapFemale(_ sender: Any) {
        femaleButton.isSelected = true
        maleButton.isSelected = false
        selectedGender = Genders.female
    }
    
    @IBAction func didTapMale(_ sender: Any) {
        femaleButton.isSelected = false
        maleButton.isSelected = true
        selectedGender = Genders.male
    }
    
    @IBAction func didTapContinue(_ sender: Any) {
        guard AuthService.shared.currentUser != nil, let gender = selectedGender?.rawValue else { return }
        AuthService.shared.currentUser!.gender = gender
        self.performSegue(withIdentifier: "toInterestedInViewController", sender: nil)
    }
    
    @IBAction func unwindToGenderSelect(sender: UIStoryboardSegue){
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
}
