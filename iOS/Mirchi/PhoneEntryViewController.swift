//
//  PhoneEntryViewController.swift
//  Mirchi
//
//  Created by Raj Kadiyala on 14/11/2017.
//  Copyright © 2019 Raj Kadiyala. All rights reserved.
//

import UIKit
import DropletIF

class PhoneEntryViewController: AuthFormBaseViewController {
    
    @IBOutlet weak var countryCodeButton: UIButton!
    @IBOutlet weak var countryCodeTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    var countryCodePicker:UIPickerView!
    var verificationID:String = ""
    var phoneNumber:String = ""
    var selectedCountryInfo:CountryCodeInfo = CountryCodes.shared.infoForCountryCode(countryCode: (Locale.current as NSLocale).object(forKey: .countryCode) as? String ?? "US")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCountryCodeField()
        setDefaultCountryCode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCountryCodeField(){
        countryCodePicker = UIPickerView()
        countryCodePicker.delegate = self
        countryCodePicker.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Colors.darkPurple
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(countryCodeFieldDidTapDone))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        countryCodeTextField.inputView = countryCodePicker
        countryCodeTextField.inputAccessoryView = toolBar
    }
    
    func setDefaultCountryCode(){
        //let info =
        setCountryCodeFieldVal(info: selectedCountryInfo)
    }
    
    func setCountryCodeFieldVal(info:CountryCodeInfo){
        countryCodeTextField.text = "+\(info.dialCode ?? "1")"
        if let example = info.example{
            phoneTextField.placeholder = example
        }
        countryCodeTextField.invalidateIntrinsicContentSize()
    }
    
    @objc func countryCodeFieldDidTapDone(){
        phoneTextField.becomeFirstResponder()
    }
    
    func setPickerViewSelection(){
        /*let index = CountryCodes.shared.indexForDialCode(dialCode: countryCodeTextField.text?.replacingOccurrences(of: "+", with: "")) ?? CountryCodes.shared.indexForCountryCode(countryCode: (Locale.current as NSLocale).object(forKey: .countryCode) as? String) ?? 0*/
        let index = CountryCodes.shared.indexForCountryCode(countryCode: selectedCountryInfo.countryCode) ?? CountryCodes.shared.indexForDialCode(dialCode: countryCodeTextField.text?.replacingOccurrences(of: "+", with: "")) ?? 0
        countryCodePicker.selectRow(index, inComponent: 0, animated: false)
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        loginWithPhoneNumber()
    }
    
    func loginWithPhoneNumber(){
        guard let rawPhone = textField.text, let dialCode = countryCodeTextField.text, phoneNumberIsValid(dialCode: dialCode, number: rawPhone) else { return }
        phoneNumber = "\(dialCode)\(rawPhone)"
        continueButton.loading = true
        view.isUserInteractionEnabled = false
        AuthService.shared.loginWithPhone(phoneNumber: phoneNumber) { (verificationID, error) in
            self.continueButton.loading = false
            self.view.isUserInteractionEnabled = true
            guard let veriID = verificationID, error == nil else{
                self.handleError(error: error, onDismiss: nil)
                return
            }
            self.verificationID = veriID
            self.performSegue(withIdentifier: "toCodeEntryViewController", sender: nil)
        }
    }
    
    func phoneNumberIsValid(dialCode:String, number:String) -> Bool{
        if dialCode.isEmpty{
            let alert = Utility.alertForErrorMessage(transitioningDelegate: self, title: NSLocalizedString("PHONE_ENTRY_COUNTRY_CODE_NEEDED_ERROR_TITLE", comment: "Title for missing country code error alert"), message: NSLocalizedString("PHONE_ENTRY_COUNTRY_CODE_NEEDED_ERROR_BODY", comment: "Body for missing country code error alert."), onDismiss: nil)
            present(alert, animated: true, completion: nil)
            return false
        }
        if number.isEmpty{
            let alert = Utility.alertForErrorMessage(transitioningDelegate: self, title: NSLocalizedString("PHONE_ENTRY_NUMBER_NEEDED_ERROR_TITLE", comment: "Title for missing phone number error alert."), message: NSLocalizedString("PHONE_ENTRY_NUMBER_NEEDED_ERROR_BODY", comment: "Body for missing phone number error alert."), onDismiss: nil)
            present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    @IBAction func textFieldEditChanged(_ sender: UITextField) {
        if sender == textField{
            textField.invalidateIntrinsicContentSize()
            continueButton.isEnabled = (sender.text?.count ?? 0) > 0
        }
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let toVC = segue.destination as? CodeEntryViewController{
            toVC.verificationID = self.verificationID
            toVC.phoneNumber = self.phoneNumber
        }
    }
    
    @IBAction func unwindToPhoneEntry(sender: UIStoryboardSegue){
        //let sourceViewController = sender.sourceViewController
        // Pull any data from the view controller which initiated the unwind segue.
    }
}

extension PhoneEntryViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CountryCodes.shared.countryCodesArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let resultView = view as? CountryPickerRow ?? CountryPickerRow()
        let info = CountryCodes.shared.countryCodeInfoAtIndex(index: row)
        resultView.configureCountryInfo(info: info)
        return resultView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let info = CountryCodes.shared.countryCodeInfoAtIndex(index: row)
        if info.dialCode != nil{
            selectedCountryInfo = info
            setCountryCodeFieldVal(info: selectedCountryInfo)
        }
    }
}

extension PhoneEntryViewController{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField == countryCodeTextField){
            return false
        }
        return true
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == countryCodeTextField){
            setPickerViewSelection()
        }else{
            super.textFieldDidBeginEditing(textField)
        }
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension PhoneEntryViewController: ExtraUITextFieldDelegate{
    func willDeleteBackward(textField: UITextField) {
        if textField == phoneTextField && (textField.text?.isEmpty ?? true){
            countryCodeTextField.becomeFirstResponder()
        }
    }
}
